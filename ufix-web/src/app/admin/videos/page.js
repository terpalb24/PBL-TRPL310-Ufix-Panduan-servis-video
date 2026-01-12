"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";

const API_BASE_URL = "http://localhost:3001/api";

export default function VideosPage() {
  const pathname = usePathname();
  const [videos, setVideos] = useState([]);
  const [loading, setLoading] = useState(true);             
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [deleteConfirm, setDeleteConfirm] = useState(null);
  const [selectedVideo, setSelectedVideo] = useState(null);
  const [notification, setNotification] = useState(null);
  const [userId, setUserId] = useState(null);
  const [videoDuration, setVideoDuration] = useState(0);
  const [formData, setFormData] = useState({
    title: "",
    deskripsi: "",
    video: null,
    thumbnail: null,
  });

  const menu = [
    { name: "Dashboard", href: "/admin/dashboard" },
    { name: "Manage Users", href: "/admin/users" },
    { name: "Videos", href: "/admin/videos" },
  ];

  // Fetch user and videos
  useEffect(() => {
    const user = localStorage.getItem("user");
    if (user) {
      const userData = JSON.parse(user);
      setUserId(userData.idPengguna || userData.id);
    }
    fetchVideos();
  }, []);

  const fetchVideos = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await fetch(`${API_BASE_URL}/video/new`);
      const data = await response.json();

      if (data.success && data.videos) {
        setVideos(data.videos);
      } else {
        throw new Error("Failed to fetch videos");
      }
    } catch (err) {
      console.error("Error fetching videos:", err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  // Handle form input changes
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  // Handle file input changes
  const handleFileChange = (e) => {
    const { name, files } = e.target;
    if (files && files[0]) {
      if (name === "video") {
        // Extract video duration
        const video = document.createElement("video");
        video.preload = "metadata";
        
        video.onloadedmetadata = () => {
          const duration = Math.round(video.duration);
          console.log("Video duration extracted:", duration, "seconds");
          setVideoDuration(duration);
        };
        
        video.onerror = () => {
          console.error("Failed to load video metadata");
          setVideoDuration(0);
        };
        
        video.src = URL.createObjectURL(files[0]);
      }
      setFormData((prev) => ({
        ...prev,
        [name]: files[0],
      }));
    }
  };

  // Add or Update Video
  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!formData.title.trim()) {
      showNotification("Title is required", "error");
      return;
    }

    const data = new FormData();
    data.append("title", formData.title);
    data.append("deskripsi", formData.deskripsi || "");
    data.append("idPengguna", userId || 1);
    data.append("durationSec", videoDuration);
    if (formData.video) {
      data.append("video", formData.video);
    }
    if (formData.thumbnail) {
      data.append("thumbnail", formData.thumbnail);
    }

    // Debug: log FormData
    console.log("FormData values:", {
      title: formData.title,
      deskripsi: formData.deskripsi,
      idPengguna: userId || 1,
      durationSec: videoDuration,
      hasVideo: !!formData.video,
      hasThumbnail: !!formData.thumbnail,
    });

    try {
      const url = editingId
        ? `${API_BASE_URL}/video/video/${editingId}`
        : `${API_BASE_URL}/video/video`;

      const method = editingId ? "PUT" : "POST";

      const response = await fetch(url, {
        method,
        body: data,
      });

      const result = await response.json();

      if (result.success) {
        showNotification(editingId ? "Video updated successfully" : "Video added successfully", "success");
        setShowForm(false);
        setEditingId(null);
        setVideoDuration(0);
        setFormData({ title: "", deskripsi: "", video: null, thumbnail: null });
        fetchVideos();
      } else {
        showNotification(result.message || "Error occurred", "error");
      }
    } catch (err) {
      console.error("Error submitting form:", err);
      showNotification(err.message, "error");
    }
  };

  // Delete Video
  const handleDelete = async (id) => {
    try {
      const response = await fetch(`${API_BASE_URL}/video/video/${id}`, {
        method: "DELETE",
      });

      const result = await response.json();

      if (result.success) {
        showNotification("Video deleted successfully", "success");
        setDeleteConfirm(null);
        fetchVideos();
      } else {
        showNotification(result.message || "Error occurred", "error");
      }
    } catch (err) {
      console.error("Error deleting video:", err);
      showNotification(err.message, "error");
    }
  };

  // Edit Video
  const handleEdit = (video) => {
    setEditingId(video.idVideo);
    setFormData({
      title: video.title || "",
      deskripsi: video.deskripsi || "",
      video: null,
      thumbnail: null,
    });
    setShowForm(true);
  };

  // Reset form
  const handleCancel = () => {
    setShowForm(false);
    setEditingId(null);
    setVideoDuration(0);
    setFormData({ title: "", deskripsi: "", video: null, thumbnail: null });
  };

  // View detail
  const handleViewDetail = (video) => {
    setSelectedVideo(video);
  };

  // Get thumbnail URL
  const getThumbnailUrl = (thumbnailPath) => {
    if (!thumbnailPath) {
      console.log("[getThumbnail] Path is empty/null");
      return null;
    }
    
    let url;
    // If already full URL, return as is
    if (thumbnailPath.startsWith("http")) {
      url = thumbnailPath;
    }
    // If starts with /, add host
    else if (thumbnailPath.startsWith("/")) {
      url = `http://localhost:3001${thumbnailPath}`;
    }
    // Otherwise assume relative path and add /uploads
    else {
      url = `http://localhost:3001/${thumbnailPath}`;
    }
    
    console.log(`[getThumbnail] Original: ${thumbnailPath} → Final URL: ${url}`);
    return url;
  };

  // Get video URL
  const getVideoUrl = (videoPath) => {
    if (!videoPath) {
      console.log("[getVideo] Path is empty/null");
      return null;
    }
    
    let url;
    // If already full URL, return as is
    if (videoPath.startsWith("http")) {
      url = videoPath;
    }
    // If starts with /, add host
    else if (videoPath.startsWith("/")) {
      url = `http://localhost:3001${videoPath}`;
    }
    // Otherwise assume relative path and add host
    else {
      url = `http://localhost:3001/${videoPath}`;
    }
    
    console.log(`[getVideo] Original: ${videoPath} → Final URL: ${url}`);
    return url;
  };

  // Show notification
  const showNotification = (message, type = "success") => {
    setNotification({ message, type });
    setTimeout(() => setNotification(null), 4000);
  };

  return (
    <div className="flex min-h-screen bg-gradient-to-br from-slate-50 to-slate-100">
      {/* NOTIFICATION */}
      {notification && (
        <div className="fixed top-6 right-6 z-[9999] animate-in slide-in-from-top fade-in">
          <div
            className={`px-6 py-4 rounded-xl shadow-lg flex items-center gap-3 ${
              notification.type === "success"
                ? "bg-green-500 text-white"
                : notification.type === "error"
                ? "bg-red-500 text-white"
                : "bg-blue-500 text-white"
            }`}
          >
            {notification.type === "success" && (
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fillRule="evenodd"
                  d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                  clipRule="evenodd"
                />
              </svg>
            )}
            {notification.type === "error" && (
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fillRule="evenodd"
                  d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                  clipRule="evenodd"
                />
              </svg>
            )}
            <span className="font-medium">{notification.message}</span>
          </div>
        </div>
      )}

      {/* SIDEBAR */}
      <aside className="w-64 min-h-screen bg-gradient-to-b from-slate-900 to-slate-800 text-white flex flex-col shadow-2xl">
        <div className="p-8 border-b border-slate-700/50">
          <div className="text-3xl font-black bg-gradient-to-r from-blue-400 to-cyan-400 bg-clip-text text-transparent">
            UFix
          </div>
          <p className="text-xs text-slate-400 mt-1">Admin Panel</p>
        </div>

        <nav className="flex-1 p-6 space-y-3">
          {menu.map((item) => (
            <Link
              key={item.name}
              href={item.href}
              className={`block px-4 py-3 rounded-lg transition duration-200 ${
                pathname === item.href
                  ? "bg-gradient-to-r from-blue-600 to-cyan-600 shadow-lg text-white font-semibold"
                  : "text-slate-300 hover:bg-slate-700/50"
              }`}
            >
              {item.name}
            </Link>
          ))}
        </nav>

        <div className="p-6 border-t border-slate-700/50 text-xs text-slate-500">
          © UFix 2025
        </div>
      </aside>

      {/* MAIN CONTENT */}
      <main className="flex-1 p-8">
        <div className="max-w-7xl mx-auto">
          {/* HEADER */}
          <div className="flex justify-between items-center mb-10">
            <div>
              <h1 className="text-4xl font-bold text-slate-900 mb-2">
                Manage Videos
              </h1>
              <p className="text-slate-600">Create, update, and manage your video content</p>
            </div>
            <button
              onClick={() => {
                setShowForm(!showForm);
                setEditingId(null);
                setVideoDuration(0);
                setFormData({ title: "", deskripsi: "", video: null, thumbnail: null });
              }}
              className="bg-gradient-to-r from-blue-600 to-cyan-600 hover:from-blue-700 hover:to-cyan-700 text-white px-8 py-3 rounded-xl font-semibold shadow-lg hover:shadow-xl transition duration-200 flex items-center gap-2"
            >
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path d="M10.5 1.5H3.75A2.25 2.25 0 001.5 3.75v12.5A2.25 2.25 0 003.75 18.5h12.5a2.25 2.25 0 002.25-2.25V9.5M10.5 1.5v9m0-9h9m-9 9l9-9" />
              </svg>
              {showForm ? "Cancel" : "Add New Video"}
            </button>
          </div>

          {/* ADD/EDIT FORM MODAL */}
          {showForm && (
            <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-40 p-4">
              <div className="bg-white rounded-2xl shadow-2xl p-8 max-w-2xl w-full max-h-[90vh] overflow-y-auto">
                <h2 className="text-3xl font-bold text-slate-900 mb-8">
                  {editingId ? "✏️ Edit Video" : "📹 Add New Video"}
                </h2>
                <form onSubmit={handleSubmit} className="space-y-6">
                  <div>
                    <label className="block text-sm font-semibold text-slate-700 mb-3">
                      Title <span className="text-red-500">*</span>
                    </label>
                    <input
                      type="text"
                      name="title"
                      value={formData.title}
                      onChange={handleInputChange}
                      className="w-full px-4 py-3 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-slate-50"
                      placeholder="Enter video title"
                      required
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-slate-700 mb-3">
                      Description
                    </label>
                    <textarea
                      name="deskripsi"
                      value={formData.deskripsi}
                      onChange={handleInputChange}
                      className="w-full px-4 py-3 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent bg-slate-50"
                      placeholder="Enter video description"
                      rows="4"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-slate-700 mb-3">
                      Video File {!editingId && <span className="text-red-500">*</span>}
                    </label>
                    <input
                      type="file"
                      name="video"
                      onChange={handleFileChange}
                      accept="video/*"
                      className="w-full px-4 py-3 border border-slate-300 rounded-xl bg-slate-50 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-blue-100 file:text-blue-700 hover:file:bg-blue-200"
                      required={!editingId}
                    />
                    <p className="text-xs text-slate-500 mt-2">
                      {editingId ? "Leave empty to keep current video" : "Required for new videos"}
                    </p>
                    {videoDuration > 0 && (
                      <p className="text-xs text-green-600 font-semibold mt-2">
                        ✓ Duration detected: {Math.floor(videoDuration / 60)}:{(videoDuration % 60).toString().padStart(2, '0')}
                      </p>
                    )}
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-slate-700 mb-3">
                      Thumbnail Image
                    </label>
                    <input
                      type="file"
                      name="thumbnail"
                      onChange={handleFileChange}
                      accept="image/*"
                      className="w-full px-4 py-3 border border-slate-300 rounded-xl bg-slate-50 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-green-100 file:text-green-700 hover:file:bg-green-200"
                    />
                    <p className="text-xs text-slate-500 mt-2">
                      Optional - leave empty to keep current thumbnail
                    </p>
                  </div>

                  <div className="flex gap-4 pt-8">
                    <button
                      type="submit"
                      className="flex-1 bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700 text-white px-6 py-3 rounded-xl font-semibold transition duration-200 shadow-lg hover:shadow-xl"
                    >
                      {editingId ? "Update Video" : "Add Video"}
                    </button>
                    <button
                      type="button"
                      onClick={handleCancel}
                      className="flex-1 bg-slate-300 hover:bg-slate-400 text-slate-800 px-6 py-3 rounded-xl font-semibold transition duration-200"
                    >
                      Cancel
                    </button>
                  </div>
                </form>
              </div>
            </div>
          )}

          {/* ERROR MESSAGE */}
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-6 py-4 rounded-xl mb-8 flex items-center gap-3">
              <svg className="w-5 h-5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
              </svg>
              <span>{error}</span>
            </div>
          )}

          {/* LOADING STATE */}
          {loading && (
            <div className="text-center py-16">
              <div className="inline-flex items-center gap-2">
                <div className="w-3 h-3 bg-blue-600 rounded-full animate-bounce"></div>
                <div className="w-3 h-3 bg-blue-600 rounded-full animate-bounce" style={{ animationDelay: "0.1s" }}></div>
                <div className="w-3 h-3 bg-blue-600 rounded-full animate-bounce" style={{ animationDelay: "0.2s" }}></div>
              </div>
              <p className="text-slate-600 mt-4 font-medium">Loading videos...</p>
            </div>
          )}

          {/* VIDEOS TABLE */}
          {!loading && videos.length > 0 && (
            <div className="bg-white rounded-2xl shadow-xl overflow-hidden border border-slate-200">
              <table className="w-full">
                <thead>
                  <tr className="bg-gradient-to-r from-slate-50 to-slate-100 border-b border-slate-200">
                    <th className="px-6 py-5 text-left text-sm font-bold text-slate-700">
                      Thumbnail
                    </th>
                    <th className="px-6 py-5 text-left text-sm font-bold text-slate-700">
                      ID
                    </th>
                    <th className="px-6 py-5 text-left text-sm font-bold text-slate-700">
                      Title
                    </th>
                    <th className="px-6 py-5 text-left text-sm font-bold text-slate-700">
                      Description
                    </th>
                    <th className="px-6 py-5 text-center text-sm font-bold text-slate-700">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {videos.map((video, idx) => (
                    <tr
                      key={video.idVideo}
                      className="border-b border-slate-200 hover:bg-slate-50 transition duration-150"
                    >
                      <td className="px-6 py-5 text-sm">
                        {getThumbnailUrl(video.thumbnailPath) ? (
                          <img
                            src={getThumbnailUrl(video.thumbnailPath)}
                            alt="Thumbnail"
                            className="w-16 h-12 object-cover rounded-lg border border-slate-200"
                          />
                        ) : (
                          <div className="w-16 h-12 bg-gradient-to-br from-slate-300 to-slate-400 rounded-lg flex items-center justify-center text-xs text-slate-600 font-semibold">
                            No Image
                          </div>
                        )}
                      </td>
                      <td className="px-6 py-5 text-sm text-slate-600 font-mono">
                        {video.idVideo}
                      </td>
                      <td className="px-6 py-5 text-sm text-slate-800 font-semibold max-w-xs truncate">
                        {video.title}
                      </td>
                      <td className="px-6 py-5 text-sm text-slate-600 max-w-md truncate">
                        {video.deskripsi || <span className="text-slate-400 italic">No description</span>}
                      </td>
                      <td className="px-6 py-5 text-center">
                        <div className="flex gap-2 justify-center">
                          <button
                            onClick={() => handleViewDetail(video)}
                            className="bg-blue-100 hover:bg-blue-200 text-blue-700 px-3 py-2 rounded-lg text-xs font-semibold transition duration-200"
                            title="View Details"
                          >
                            👁️ Detail
                          </button>
                          <button
                            onClick={() => handleEdit(video)}
                            className="bg-yellow-100 hover:bg-yellow-200 text-yellow-700 px-3 py-2 rounded-lg text-xs font-semibold transition duration-200"
                            title="Edit Video"
                          >
                            ✏️ Edit
                          </button>
                          <button
                            onClick={() => setDeleteConfirm(video.idVideo)}
                            className="bg-red-100 hover:bg-red-200 text-red-700 px-3 py-2 rounded-lg text-xs font-semibold transition duration-200"
                            title="Delete Video"
                          >
                            🗑️ Delete
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {/* EMPTY STATE */}
          {!loading && videos.length === 0 && (
            <div className="bg-white rounded-2xl shadow-lg p-16 text-center border border-slate-200">
              <div className="text-6xl mb-4">🎬</div>
              <p className="text-slate-600 text-lg font-medium mb-6">No videos found</p>
              <button
                onClick={() => setShowForm(true)}
                className="bg-gradient-to-r from-blue-600 to-cyan-600 hover:from-blue-700 hover:to-cyan-700 text-white px-8 py-3 rounded-xl font-semibold transition duration-200 shadow-lg hover:shadow-xl"
              >
                Create Your First Video
              </button>
            </div>
          )}

          {/* DELETE CONFIRMATION MODAL */}
          {deleteConfirm !== null && (
            <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
              <div className="bg-white rounded-2xl shadow-2xl p-8 max-w-sm w-full">
                <div className="text-center">
                  <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <span className="text-3xl">⚠️</span>
                  </div>
                  <h3 className="text-2xl font-bold text-slate-900 mb-2">
                    Delete Video?
                  </h3>
                  <p className="text-slate-600 mb-8">
                    This action cannot be undone. The video will be permanently deleted from the system.
                  </p>
                </div>
                <div className="flex gap-3">
                  <button
                    onClick={() => handleDelete(deleteConfirm)}
                    className="flex-1 bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 text-white px-4 py-3 rounded-xl font-semibold transition duration-200"
                  >
                    Delete
                  </button>
                  <button
                    onClick={() => setDeleteConfirm(null)}
                    className="flex-1 bg-slate-200 hover:bg-slate-300 text-slate-800 px-4 py-3 rounded-xl font-semibold transition duration-200"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* DETAIL MODAL */}
          {selectedVideo && (
            <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
              <div className="bg-white rounded-2xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
                <div className="p-8">
                  <div className="flex justify-between items-start mb-8">
                    <div>
                      <h2 className="text-3xl font-bold text-slate-900">
                        {selectedVideo.title}
                      </h2>
                      <p className="text-slate-500 text-sm mt-1">Video ID: {selectedVideo.idVideo}</p>
                    </div>
                    <button
                      onClick={() => setSelectedVideo(null)}
                      className="text-slate-400 hover:text-slate-600 transition text-3xl font-light"
                    >
                      ✕
                    </button>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
                    {/* Thumbnail */}
                    <div>
                      <h3 className="text-sm font-bold text-slate-700 mb-4 uppercase tracking-wide">
                        Thumbnail
                      </h3>
                      {getThumbnailUrl(selectedVideo.thumbnailPath) ? (
                        <img
                          src={getThumbnailUrl(selectedVideo.thumbnailPath)}
                          alt="Thumbnail"
                          className="w-full h-auto rounded-xl border border-slate-200 shadow-lg"
                        />
                      ) : (
                        <div className="w-full h-48 bg-gradient-to-br from-slate-300 to-slate-400 rounded-xl flex items-center justify-center text-slate-600 font-semibold">
                          No Thumbnail Available
                        </div>
                      )}
                    </div>

                    {/* Video Preview */}
                    <div>
                      <h3 className="text-sm font-bold text-slate-700 mb-4 uppercase tracking-wide">
                        Video Preview
                      </h3>
                      <video
                        controls
                        className="w-full h-auto rounded-xl border border-slate-200 shadow-lg bg-slate-900"
                      >
                        <source
                          src={getVideoUrl(selectedVideo.videoPath)}
                          type={selectedVideo.mime_type || "video/mp4"}
                        />
                        Your browser does not support the video tag.
                      </video>
                    </div>
                  </div>

                  {/* Details */}
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8 p-6 bg-slate-50 rounded-xl border border-slate-200">
                    <div>
                      <h3 className="text-sm font-bold text-slate-700 mb-2 uppercase tracking-wide">
                        Description
                      </h3>
                      <p className="text-slate-600 leading-relaxed">
                        {selectedVideo.deskripsi || <span className="text-slate-400 italic">No description provided</span>}
                      </p>
                    </div>

                    {selectedVideo.sentDate && (
                      <div>
                        <h3 className="text-sm font-bold text-slate-700 mb-2 uppercase tracking-wide">
                          Upload Date
                        </h3>
                        <p className="text-slate-600">
                          {new Date(selectedVideo.sentDate).toLocaleString("en-US", {
                            weekday: "long",
                            year: "numeric",
                            month: "long",
                            day: "numeric",
                            hour: "2-digit",
                            minute: "2-digit"
                          })}
                        </p>
                      </div>
                    )}
                  </div>

                  {/* Close Button */}
                  <button
                    onClick={() => setSelectedVideo(null)}
                    className="w-full bg-gradient-to-r from-slate-600 to-slate-700 hover:from-slate-700 hover:to-slate-800 text-white px-6 py-3 rounded-xl font-semibold transition duration-200"
                  >
                    Close
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
