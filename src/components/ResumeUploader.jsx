import * as pdfjsLib from "pdfjs-dist";
import pdfWorkerUrl from "pdfjs-dist/build/pdf.worker.min.mjs?url";
import { useState } from "react";

pdfjsLib.GlobalWorkerOptions.workerSrc = pdfWorkerUrl;

export default function ResumeUploader({ skillsList = [], onExtract, onError }) {
  const [loading, setLoading] = useState(false);
  const [fileName, setFileName] = useState("");

  const handleFile = async (event) => {
    onError && onError(null);
    const file = event.target.files && event.target.files[0];
    if (!file) return;
    if (file.type !== "application/pdf") {
      onError && onError("Please upload a PDF file.");
      return;
    }

    setLoading(true);
    setFileName(file.name);

    try {
      const reader = new FileReader();
      reader.onload = async () => {
        try {
          const typedarray = new Uint8Array(reader.result);
          const pdf = await pdfjsLib.getDocument(typedarray).promise;
          let fullText = "";

          for (let i = 1; i <= pdf.numPages; i++) {
            const page = await pdf.getPage(i);
            const textContent = await page.getTextContent();
            const pageText = textContent.items.map((item) => item.str).join(" ");
            fullText += pageText + "\n\n";
          }

          const lowered = fullText.toLowerCase();
          const found = (skillsList || []).filter((skill) =>
            lowered.includes(skill.toLowerCase())
          );

          onExtract && onExtract({ text: fullText, found });
        } catch (e) {
          console.error(e);
          onError && onError("Failed to parse PDF.");
        } finally {
          setLoading(false);
        }
      };

      reader.onerror = (e) => {
        console.error(e);
        onError && onError("Failed to read file.");
        setLoading(false);
      };

      reader.readAsArrayBuffer(file);
    } catch (e) {
      console.error(e);
      onError && onError("Unexpected error.");
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col items-center justify-center border-2 border-dashed border-gray-300 rounded-xl p-6 bg-gray-50 hover:bg-gray-100 transition-colors duration-200">
      <label
        htmlFor="resume-upload"
        className="flex flex-col items-center cursor-pointer w-full"
      >
        <svg
          className="w-12 h-12 text-blue-500 mb-2"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.5"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M12 16v-8m0 0l-3 3m3-3l3 3m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
          />
        </svg>
        <p className="text-gray-700 font-medium text-center">
          Click to upload or drag & drop your PDF resume
        </p>
        <p className="text-sm text-gray-500 mt-1">Only PDF files are supported</p>
      </label>

      <input
        id="resume-upload"
        type="file"
        onChange={handleFile}
        accept="application/pdf"
        className="hidden"
      />

      {fileName && !loading && (
        <p className="mt-3 text-sm text-gray-600 italic">📄 {fileName}</p>
      )}

      {loading && (
        <div className="flex items-center gap-2 mt-3 text-blue-600">
          <svg
            className="animate-spin h-5 w-5 text-blue-600"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle
              className="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              strokeWidth="4"
            />
            <path
              className="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"
            />
          </svg>
          <p>Extracting text… please wait</p>
        </div>
      )}
    </div>
  );
}
