import { useState, useEffect } from "react";
import skills from "./skills.json";
import ResumeUploader from "./components/ResumeUploader";
import Recommendations from "./components/Recommendations";

export default function App() {
  const [text, setText] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [foundSkills, setFoundSkills] = useState([]);
  const [skillsList, setSkillsList] = useState(skills);
  const [recommendations, setRecommendations] = useState(null);
  const [recLoading, setRecLoading] = useState(false);
  const [recError, setRecError] = useState(null);

  // Handle resume extraction
  const handleExtract = ({ text: extractedText, found }) => {
    setError(null);
    setText(extractedText || "");
    setFoundSkills(found || []);
    if (found && found.length > 0) fetchRecommendations(found);
    else setRecommendations(null);
  };

  // Load runtime-editable skills (optional)
  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        const res = await fetch("/skills.json");
        if (!res.ok) return;
        const json = await res.json();
        if (mounted && Array.isArray(json)) setSkillsList(json);
      } catch (e) {
        console.debug("Could not load /skills.json:", e.message);
      }
    })();
    return () => {
      mounted = false;
    };
  }, []);

  async function fetchRecommendations(found) {
    setRecLoading(true);
    setRecError(null);
    setRecommendations(null);
    try {
      const res = await fetch("/recommend", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ skills: found }),
      });
      if (!res.ok) {
        const text = await res.text().catch(() => "");
        throw new Error(`Server responded ${res.status}: ${text}`);
      }
      const data = await res.json();
      setRecommendations(data.results || []);
    } catch (e) {
      console.error("Recommendation API error:", e);
      setRecError(e.message || "Failed to fetch recommendations");
    } finally {
      setRecLoading(false);
    }
  }

  return (
    <div className="flex flex-col items-center p-6 font-sans bg-gray-50 min-h-screen">
      <div className="w-full max-w-4xl bg-white shadow-md rounded-2xl p-8">
        <h1 className="text-3xl font-bold text-center text-gray-800 mb-2">
          Job Recommendation System
        </h1>
        <p className="text-center text-gray-600 mb-6">
          Upload your resume to extract skills and get AI-powered job recommendations.
        </p>

        <ResumeUploader skillsList={skillsList} onExtract={handleExtract} onError={setError} />

        {loading && <p className="text-gray-500 text-center mt-3">Extracting text…</p>}
        {error && <p className="text-red-600 font-semibold mt-3 text-center">{error}</p>}

        {foundSkills.length > 0 && (
          <div className="mt-6">
            <h2 className="font-semibold text-lg text-gray-700 mb-2">Detected Skills:</h2>
            <div className="flex flex-wrap gap-2">
              {foundSkills.map((s) => (
                <span
                  key={s}
                  className="bg-blue-100 text-blue-700 px-3 py-1 text-sm rounded-full"
                >
                  {s}
                </span>
              ))}
            </div>
          </div>
        )}

        <div className="mt-4">
          <Recommendations
            recLoading={recLoading}
            recError={recError}
            recommendations={recommendations}
          />
        </div>

        <div className="mt-8">
          <h2 className="font-semibold text-lg text-gray-700 mb-2">Extracted Text (Preview):</h2>
          <textarea
            value={text}
            readOnly
            rows={10}
            className="w-full border border-gray-300 rounded-lg p-3 text-sm text-gray-700 bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
        </div>
      </div>
    </div>
  );
}
