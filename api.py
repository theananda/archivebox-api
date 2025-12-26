from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel, HttpUrl
from typing import List, Dict, Optional
import asyncio
import subprocess
import uuid
from datetime import datetime

app = FastAPI(title="ArchiveBox Railway API")
jobs: Dict[str, Dict] = {}

class ArchiveRequest(BaseModel):
    url: HttpUrl
    tags: List[str] = []

async def archive_url_task(job_id: str, url: str, tags: List[str]):
    try:
        # Construct the command to run directly
        cmd = ["archivebox", "add", str(url)]
        if tags:
            cmd.extend(["--tag", ",".join(tags)])
        
        process = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            cwd="/data" # ArchiveBox data directory
        )
        stdout, stderr = await process.communicate()
        
        jobs[job_id].update({
            "status": "completed" if process.returncode == 0 else "failed",
            "output": stdout.decode(),
            "error": stderr.decode() if process.returncode != 0 else None
        })
    except Exception as e:
        jobs[job_id].update({"status": "failed", "error": str(e)})

@app.post("/archive")
async def start_archive(request: ArchiveRequest, background_tasks: BackgroundTasks):
    job_id = str(uuid.uuid4())
    jobs[job_id] = {"job_id": job_id, "status": "in_progress", "url": str(request.url)}
    background_tasks.add_task(archive_url_task, job_id, str(request.url), request.tags)
    return jobs[job_id]

@app.get("/status/{job_id}")
async def get_status(job_id: str):
    return jobs.get(job_id, {"error": "Not found"})
