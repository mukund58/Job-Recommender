import React, { useState } from "react";

export default function Recommendations({ recLoading, recError, recommendations }) {
  const [expandedIndex, setExpandedIndex] = useState(null);
  const getValue = (val) => (Array.isArray(val) ? val[0] : val);

  // Convert text to Title Case
  const toTitleCase = (str) =>
    str
      ? str
          .toLowerCase()
          .split(" ")
          .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
          .join(" ")
      : "";

  // Calculate time ago from posted date
  const timeAgo = (dateString) => {
    if (!dateString) return '';
    const postedDate = new Date(dateString);
    const now = new Date();
    const diffTime = now - postedDate;
    if (diffTime < 0) return 'In the future';
    const diffMinutes = Math.floor(diffTime / (1000 * 60));
    if (diffMinutes < 1) return 'Just now';
    if (diffMinutes < 60) return `${diffMinutes} minute${diffMinutes > 1 ? 's' : ''} ago`;
    const diffHours = Math.floor(diffMinutes / 60);
    if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`;
    const diffDays = Math.floor(diffHours / 24);
    const diffYears = Math.floor(diffDays / 365);
    if (diffYears > 0) return `${diffYears} year${diffYears > 1 ? 's' : ''} ago`;
    const diffMonths = Math.round(diffDays / 30);
    if (diffMonths > 0) return `${diffMonths} month${diffMonths > 1 ? 's' : ''} ago`;
    const diffWeeks = Math.floor(diffDays / 7);
    if (diffWeeks > 0) return `${diffWeeks} week${diffWeeks > 1 ? 's' : ''} ago`;
    return `${diffDays} day${diffDays > 1 ? 's' : ''} ago`;
  };

  if (recLoading)
    return (
      <p className="text-blue-600 animate-pulse text-center mt-6">
        Fetching recommendations...
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
        Job Recommendations
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
              <h3 className="text-xl font-semibold text-gray-800 mb-2">
                <strong>Job Title:</strong> {toTitleCase(getValue(job.title_clean))}
              </h3>

              {/* Company and Location */}
              <p className="text-sm text-gray-600 mb-3">
                <strong>Company:</strong> {getValue(job.company_name)} <br />
                <strong>Location:</strong> {getValue(job.location) || "Location not specified"}
              </p>

              {/* Posted Date */}
              {job.posted_date && (
                <p className="text-xs text-gray-500 mb-2">
                  <strong>Posted:</strong> {timeAgo(getValue(job.posted_date))}
                </p>
              )}

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
                  <strong>Match Score:</strong>{" "}
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

              {/* Matched Skills */}
              {job.matched_skills && (
                <p className="text-xs text-gray-700 mb-2">
                  <strong>Matched Skills:</strong>{" "}
                  {Array.isArray(job.matched_skills)
                    ? job.matched_skills.join(", ")
                    : getValue(job.matched_skills)}
                </p>
              )}

              {/* Salary */}
              {job.salary_range && (
                <p className="text-xs text-gray-700 mb-2">
                  <strong>Salary Range:</strong> {getValue(job.salary_range)}
                </p>
              )}

              {/* Description */}
              {job.description && (() => {
                const desc = getValue(job.description);
                const isExpanded = expandedIndex === i;
                const truncated =
                  desc.length > 300 ? desc.slice(0, 300) + "..." : desc;

                // Function to format description text
                const formatDescription = (text) => {
                  // If text already has line breaks, preserve them
                  if (text.includes('\n')) {
                    return text;
                  }

                  // For continuous text, add basic formatting
                  let formatted = text;

                  // Split on periods followed by spaces and capitalize next word
                  formatted = formatted.replace(/\. ([A-Z])/g, '.\n\n$1');

                  // Look for common section headers
                  formatted = formatted.replace(/(responsibilities|requirements|qualifications|skills|experience|education|benefits|about us|job summary|what you'll do|what we offer)(:)/gi, '\n\n$1$2');

                  // Look for "we are", "we need", "looking for" patterns
                  formatted = formatted.replace(/(we are|we need|looking for|join us|about the role|in this role)(\s)/gi, '\n\n$1$2');

                  // Look for bullet point indicators
                  formatted = formatted.replace(/•/g, '\n•');

                  // Look for numbered lists
                  formatted = formatted.replace(/(\d+)\./g, '\n$1.');

                  // Clean up excessive whitespace
                  formatted = formatted.replace(/\n\s+/g, '\n');
                  formatted = formatted.replace(/\n{3,}/g, '\n\n');

                  // If still no line breaks after processing, add some basic paragraph breaks
                  if (!formatted.includes('\n') && formatted.length > 200) {
                    const words = formatted.split(' ');
                    const result = [];
                    let charCount = 0;

                    for (const word of words) {
                      result.push(word);
                      charCount += word.length + 1;

                      if (charCount > 80 && /[.,;:]$/.test(word)) {
                        result.push('\n\n');
                        charCount = 0;
                      }
                    }

                    formatted = result.join(' ');
                  }

                  return formatted;
                };

                const formattedDesc = formatDescription(desc);
                const formattedTruncated = formatDescription(truncated);

                return (
                  <div className="text-xs text-gray-700 mb-3">
                    <p style={{ whiteSpace: "pre-line" }}>
                      <strong>Description:</strong>{" "}
                      {isExpanded ? formattedDesc : formattedTruncated}
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

              {/* View Details Button */}
              {/* <button className="mt-3 bg-blue-600 hover:bg-blue-700 text-white text-sm px-4 py-2 rounded-lg w-full transition-colors">
                View Details
              </button> */}
            </div>
          );
        })}
      </div>
    </div>
  );
}
