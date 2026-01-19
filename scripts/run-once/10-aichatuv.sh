#!/bin/bash

# ==========================================
#  Universal Document Chat Installer (UV Edition)
# ==========================================

# --- CONFIGURATION ---
BASE_DIR="$HOME/Documents/doc_analyzer"
SCRIPT_NAME="analyze.py"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Initializing Document Analyzer ===${NC}"

# 1. Create Directories
echo -e "${GREEN}[+] Setting up directories in $BASE_DIR...${NC}"
mkdir -p "$BASE_DIR/court"
mkdir -p "$BASE_DIR/union"

# 2. Check for UV
USE_UV=false
if command -v uv &> /dev/null; then
    echo -e "${BLUE}[*] 'uv' detected! Optimizing script for uv execution.${NC}"
    USE_UV=true
else
    echo -e "${BLUE}[*] 'uv' not found. Defaulting to standard Python venv.${NC}"
fi

cd "$BASE_DIR"

# 3. Standard Setup (Fallback)
# Even if UV is present, we create a venv just in case the user wants to run it manually
if [ ! -d "venv" ]; then
    echo -e "${GREEN}[+] Creating standard virtual environment (fallback)...${NC}"
    python3 -m venv venv
    
    # We only auto-install via pip if we AREN'T using UV, to save time
    if [ "$USE_UV" = false ]; then
        echo -e "${GREEN}[+] Installing libraries via pip...${NC}"
        source venv/bin/activate
        pip install --upgrade pip
        pip install langchain-docling langchain-community langchain-chroma docling
    fi
fi

# 4. Generate Python Script with Dependency Header
echo -e "${GREEN}[+] Generating $SCRIPT_NAME with embedded dependency declaration...${NC}"

cat << 'EOF' > "$SCRIPT_NAME"
# /// script
# dependencies = [
#     "langchain-docling",
#     "langchain-community",
#     "langchain-chroma",
#     "docling",
# ]
# ///

import os
import sys
import glob
import shutil
from langchain_community.llms import Ollama
from langchain_community.embeddings import OllamaEmbeddings
from langchain_chroma import Chroma
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_core.documents import Document
from langchain_community.vectorstores.utils import filter_complex_metadata

# --- DOCLING CORE IMPORTS ---
from docling.document_converter import DocumentConverter, PdfFormatOption
from docling.datamodel.base_models import InputFormat
from docling.datamodel.pipeline_options import PdfPipelineOptions

# --- CONFIGURATION ---
CHAT_MODEL = "deepseek-r1:8b"
EMBED_MODEL = "nomic-embed-text"
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def get_target_topic():
    """Ask user which folder to analyze."""
    print("\n--- SELECT TOPIC ---")
    print("1. Court")
    print("2. Union")
    print("3. Custom (Type folder name)")
    
    choice = input("Enter number or name: ").strip().lower()
    
    if choice == '1' or choice == 'court':
        return 'court'
    elif choice == '2' or choice == 'union':
        return 'union'
    else:
        return choice

def load_documents_with_force_ocr(source_dir):
    """Loads PDFs using Docling with forced OCR settings."""
    pdf_files = glob.glob(os.path.join(source_dir, "*.pdf"))
    
    if not pdf_files:
        print(f"❌ No PDF files found in: {source_dir}")
        return []

    print(f"\n--- PROCESSING {len(pdf_files)} FILES FROM: {os.path.basename(source_dir)} ---")
    print("(Note: 'Nuclear' OCR is on. This will take time per file.)")
    
    # Configure Pipeline: NUCLEAR OCR (Force Render)
    pipeline_options = PdfPipelineOptions()
    pipeline_options.do_ocr = True
    pipeline_options.do_table_structure = True
    pipeline_options.table_structure_options.do_cell_matching = True
    
    # FORCE IT TO IGNORE EXISTING TEXT AND RENDER AS IMAGE FIRST
    pipeline_options.ocr_options.force_full_page_ocr = True 
    pipeline_options.images_scale = 2.0 # Scale up for better reading

    # Wrap options correctly
    converter = DocumentConverter(
        format_options={
            InputFormat.PDF: PdfFormatOption(pipeline_options=pipeline_options)
        }
    )

    all_docs = []
    
    for i, pdf_path in enumerate(pdf_files):
        print(f"[{i+1}/{len(pdf_files)}] Reading: {os.path.basename(pdf_path)}...")
        try:
            # Convert
            result = converter.convert(pdf_path)
            markdown_text = result.document.export_to_markdown()
            
            # Validation
            if len(markdown_text.strip()) < 50:
                 print(f"    ⚠️ WARNING: File seems empty even with Force OCR: {os.path.basename(pdf_path)}")

            # Create Document Object
            doc = Document(
                page_content=markdown_text,
                metadata={"source": os.path.basename(pdf_path)}
            )
            all_docs.append(doc)
            
        except Exception as e:
            print(f"    ❌ ERROR: {e}")
            
    return all_docs

def main():
    # 1. Determine Topic
    if len(sys.argv) > 1:
        topic = sys.argv[1]
    else:
        topic = get_target_topic()

    docs_path = os.path.join(BASE_DIR, topic)
    db_path = os.path.join(BASE_DIR, f"db_{topic}") 

    if not os.path.isdir(docs_path):
        print(f"Error: Directory '{docs_path}' does not exist.")
        return

    # 2. Check if DB exists or needs update
    db_exists = os.path.exists(db_path)
    
    embeddings = OllamaEmbeddings(model=EMBED_MODEL)
    llm = Ollama(model=CHAT_MODEL)

    if db_exists:
        print(f"\nFound existing database for '{topic}'. Using it.")
        rebuild = input("Do you want to rebuild the database? (y/N): ").lower()
        if rebuild == 'y':
            shutil.rmtree(db_path)
            db_exists = False
    
    if not db_exists:
        # Load and Embed
        raw_docs = load_documents_with_force_ocr(docs_path)
        if not raw_docs:
            return

        print(f"\n--- OPTIMIZING TEXT ---")
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
        chunks = text_splitter.split_documents(raw_docs)
        chunks = filter_complex_metadata(chunks) 

        print(f"--- SAVING TO DATABASE ({db_path}) ---")
        vectorstore = Chroma(embedding_function=embeddings, persist_directory=db_path)
        
        # Batch process
        batch_size = 5
        total = len(chunks)
        for i in range(0, total, batch_size):
            batch = chunks[i:i+batch_size]
            print(f"   Embedding batch {i//batch_size + 1}...")
            vectorstore.add_documents(batch)
        print("✅ Database ready.")
    else:
        vectorstore = Chroma(persist_directory=db_path, embedding_function=embeddings)

    # 3. Chat Interface
    retriever = vectorstore.as_retriever(search_kwargs={"k": 7})
    
    print("\n" + "="*50)
    print(f"   ANALYZING: {topic.upper()} | MODEL: {CHAT_MODEL}")
    print("   (Type 'exit' to quit)")
    print("="*50)

    while True:
        query = input("\nQuery: ")
        if query.lower() in ["exit", "quit"]:
            break

        print("Searching...")
        docs = retriever.invoke(query)
        
        if not docs:
            print("No relevant info found.")
            continue
            
        sources = list(set([d.metadata.get('source', 'Unknown') for d in docs]))
        print(f"[Sources: {', '.join(sources)}]")
        
        context = "\n\n".join([d.page_content for d in docs])
        
        prompt = (
            f"You are a helpful assistant specialized in analyzing documents.\n"
            f"Answer the question based ONLY on the context below.\n\n"
            f"Context:\n{context}\n\n"
            f"Question: {query}\n"
            f"Answer:"
        )
        
        print("Thinking...")
        try:
            for chunk in llm.stream(prompt):
                print(chunk, end="", flush=True)
            print("\n")
        except Exception as e:
            print(f"Ollama Error: {e}")

if __name__ == "__main__":
    main()
EOF

# 6. Final Instructions
echo -e "${BLUE}=== Setup Complete! ===${NC}"
echo -e "Your environment is ready at: $BASE_DIR"
echo -e ""
echo -e "${GREEN}OPTION 1 (Recommended): Using 'uv'${NC}"
echo -e "  Run anywhere: ${BLUE}uv run $BASE_DIR/$SCRIPT_NAME${NC}"
echo -e ""
echo -e "${GREEN}OPTION 2: Standard Python${NC}"
echo -e "  cd $BASE_DIR"
echo -e "  source venv/bin/activate"
echo -e "  python $SCRIPT_NAME"
