import React, { useState } from "react";

export default function Recommendations({ recLoading, recError, recommendations }) {
  const [expandedIndex, setExpandedIndex] = useState(null);
  const getValue = (val) => (Array.isArray(val) ? val[0] : val);

  // Helper to convert text to Title Case
  const toTitleCase = (str) =>
    str
      ? str
          .toLowerCase()
          .split(" ")
          .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
          .join(" ")
      : "";

  if (recLoading)
    return (
      <p className="text-blue-600 animate-pulse text-center mt-6">
        Fetching recommendations…
      </p>
    );

  if (recError)
    return (
      <p className="text-red-500 font-semibold text-center mt-6">
        Error: {recError}
      </p>
    );

  if (!recommendations || recommendations.length === 0) {
    return (
      <p className="text-gray-600 text-center mt-6">
        No recommendations available.
      </p>
    );
  }

  return (
    <div className="mt-6 flex flex-col items-center">
      <h2 className="text-2xl font-bold mb-6 text-gray-800 text-center">
        🎯 Job Recommendations
      </h2>

      <div className="flex flex-col items-center w-full space-y-6">
        {recommendations.map((job, i) => {
          const score = Math.round(getValue(job.score));

          return (
            <div
              key={i}
              className="border border-gray-200 shadow-sm rounded-2xl p-5 bg-white hover:shadow-lg transition-all duration-200 w-full max-w-3xl"
            >
              {/* Job Title */}
              <h3 className="text-xl font-semibold text-gray-800 mb-2 ">
                {toTitleCase(getValue(job.title_clean))}
              </h3>

              {/* Company + Location */}
              <p className="text-sm text-gray-600 mb-3 ">
                💼 {getValue(job.company_name)} <br /> 📍{" "}
                {getValue(job.location) || "Anywhere"}
              </p>

              {/* Tags */}
              <div className="flex justify-center flex-wrap gap-2 mb-3">
                {getValue(job.remote_type) && (
                  <span className="text-xs bg-blue-100 text-blue-700 px-2 py-1 rounded-full">
                    {getValue(job.remote_type)}
                  </span>
                )}
                {getValue(job.employment_type) && (
                  <span className="text-xs bg-green-100 text-green-700 px-2 py-1 rounded-full">
                    {getValue(job.employment_type)}
                  </span>
                )}
                {getValue(job.seniority_level) && (
                  <span className="text-xs bg-yellow-100 text-yellow-700 px-2 py-1 rounded-full">
                    {getValue(job.seniority_level)}
                  </span>
                )}
              </div>

              {/* Match Score */}
              <div className="mb-3">
                <p className="text-sm font-medium">
                  🎯 Match Score:{" "}
                  <span
                    className={`font-bold ${
                      score > 70
                        ? "text-green-600"
                        : score > 40
                        ? "text-yellow-600"
                        : "text-gray-600"
                    }`}
                  >
                    {score}%
                  </span>
                </p>
              </div>

              {/* Skills */}
              {job.matched_skills && (
                <p className="text-xs text-gray-700 mb-2 ">
                  🧠 <strong>Matched Skills:</strong>{" "}
                  {Array.isArray(job.matched_skills)
                    ? job.matched_skills.join(", ")
                    : getValue(job.matched_skills)}
                </p>
              )}

              {/* Salary */}
              {job.salary_range && (
                <p className="text-xs text-gray-700 mb-2 ">
                  💰 {getValue(job.salary_range)}
                </p>
              )}

                {job.description && (() => {
                  const desc = getValue(job.description);
                  const isExpanded = expandedIndex === i;
                  const truncated = desc.length > 300 ? desc.slice(0, 300) + "..." : desc;

                  return (
                    <div className="text-xs text-gray-700 mb-3">
                      <p style={{ whiteSpace: 'pre-line' }}>
                        <strong>Description:</strong> {isExpanded ? desc : truncated}
                      </p>
                      {desc.length > 300 && (
                        <button
                          onClick={() => setExpandedIndex(isExpanded ? null : i)}
                          className="text-blue-500 mt-2 text-sm hover:underline"
                        >
                          {isExpanded ? "Show Less" : "Read More"}
                        </button>
                      )}
                    </div>
                  );
                })()}



              {/* View Details */}
              <button className="mt-3 bg-blue-600 hover:bg-blue-700 text-white text-sm px-4 py-2 rounded-lg w-full transition-colors">
                View Details
              </button>
            </div>
          );
        })}
      </div>
    </div>
  );
}
