// tests/unit/videoController.test.js - FIXED
describe("Video Controller - Correct Test", () => {
  let videoController;
  let dbPromise;
  let jwt;
  let fs;
  let path;

  // Clear module cache and reload mocks for each test
  beforeEach(() => {
    jest.resetModules();
    jest.clearAllMocks();

    // Mock all dependencies
    jest.mock("../../config/database", () => ({
      dbPromise: {
        execute: jest.fn(),
        query: jest.fn(),
      },
    }));

    jest.mock("jsonwebtoken", () => ({
      verify: jest.fn(),
      sign: jest.fn(),
    }));

    jest.mock("fs", () => ({
      existsSync: jest.fn(),
      statSync: jest.fn(),
      createReadStream: jest.fn(() => ({
        pipe: jest.fn(),
      })),
      unlinkSync: jest.fn(),
      unlink: jest.fn(),
      promises: {
        unlink: jest.fn(),
      },
    }));

    jest.mock("path", () => ({
      join: jest.fn(),
      relative: jest.fn(),
      extname: jest.fn(() => ".mp4"),
    }));

    // Require modules after mocking
    dbPromise = require("../../config/database").dbPromise;
    jwt = require("jsonwebtoken");
    fs = require("fs");
    path = require("path");
    videoController = require("../../controllers/videoController");
  });

  describe("getVideoNew Function", () => {
    test("should return videos with simple queries", async () => {
      const mockReq = {};

      const mockRes = {
        json: jest.fn(),
      };

      const mockCountResult = [{ count: 5 }];
      const mockSimpleVideos = [{ idVideo: 1 }, { idVideo: 2 }];
      const mockVideos = [
        { idVideo: 1, title: "Video 1", deskripsi: "Desc 1" },
        { idVideo: 2, title: "Video 2", deskripsi: "Desc 2" },
      ];

      dbPromise.execute
        .mockResolvedValueOnce([mockCountResult])
        .mockResolvedValueOnce([mockSimpleVideos])
        .mockResolvedValueOnce([mockVideos]);

      await videoController.getVideoNew(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        count: 2,
        videos: mockVideos,
      });
    });
  });

  describe("getVideoUrl Function", () => {
    test("should generate video URL with token", async () => {
      const mockReq = {
        params: { id: "123" },
        user: { userId: 1 },
        get: jest.fn().mockReturnValue("localhost:3000"),
      };

      const mockRes = {
        json: jest.fn(),
      };

      const mockVideo = [
        {
          idVideo: 123,
          title: "Test Video",
          videoPath: "/videos/test.mp4",
          deskripsi: "Test deskripsi",
        },
      ];

      dbPromise.execute.mockResolvedValue([mockVideo]);
      jwt.sign.mockReturnValue("test-token-123");
      path.join.mockReturnValue("/full/path/test.mp4");

      await videoController.getVideoUrl(mockReq, mockRes);

      expect(jwt.sign).toHaveBeenCalledWith(
        expect.objectContaining({
          videoId: 123,
          userId: 1,
          type: "video_stream",
        }),
        process.env.JWT_SECRET,
        { expiresIn: "1h" }
      );

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        video: expect.objectContaining({
          id: 123,
          judul: "Test Video",
          videoUrl: expect.stringContaining("token=test-token-123"),
        }),
      });
    });

    test("should return 404 when video not found", async () => {
      const mockReq = {
        params: { id: "999" },
        user: { userId: 1 },
      };

      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.execute.mockResolvedValue([[]]);

      await videoController.getVideoUrl(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: "Video not found",
      });
    });
  });

  describe("streamVideo Function", () => {
    test("should return 401 when token is missing", async () => {
      const mockReq = {
        params: { id: "123" },
        query: {},
      };

      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      await videoController.streamVideo(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: "Stream token required",
      });
    });

    test("should stream video with range headers", async () => {
      const mockReq = {
        params: { id: "123" },
        query: { token: "valid-token" },
        headers: { range: "bytes=0-499" },
      };

      const mockRes = {
        writeHead: jest.fn(),
        pipe: jest.fn(),
      };

      const decodedToken = {
        videoId: 123,
        userId: 1,
        type: "video_stream",
      };

      const mockVideo = [
        {
          videoPath: "/videos/test.mp4",
          mime_type: "video/mp4",
        },
      ];

      jwt.verify.mockReturnValue(decodedToken);
      dbPromise.execute.mockResolvedValue([mockVideo]);
      fs.existsSync.mockReturnValue(true);
      fs.statSync.mockReturnValue({ size: 1000 });
      path.join.mockReturnValue("/full/path/test.mp4");
      fs.createReadStream.mockReturnValue({ pipe: jest.fn() });

      await videoController.streamVideo(mockReq, mockRes);

      expect(mockRes.writeHead).toHaveBeenCalledWith(206, {
        "Content-Range": "bytes 0-499/1000",
        "Accept-Ranges": "bytes",
        "Content-Length": 500,
        "Content-Type": "video/mp4",
      });
    });
  });

  describe("watchVideo Function", () => {
    test("should insert history when user authenticated and video not in history", async () => {
      const mockReq = {
        params: { id: "123" },
        user: { userId: 1, idUser: 1 },
        headers: {},
      };

      const mockRes = {
        writeHead: jest.fn(),
        pipe: jest.fn(),
      };

      const mockVideo = [
        {
          videoPath: "/videos/test.mp4",
          mime_type: "video/mp4",
          deskripsi: "Test video",
        },
      ];

      dbPromise.execute
        .mockResolvedValueOnce([mockVideo]) // Video query
        .mockResolvedValueOnce([[]]) // No existing history
        .mockResolvedValueOnce([{ insertId: 1 }]); // History insert

      fs.existsSync.mockReturnValue(true);
      fs.statSync.mockReturnValue({ size: 1000 });
      path.join.mockReturnValue("/full/path/test.mp4");
      fs.createReadStream.mockReturnValue({ pipe: jest.fn() });

      await videoController.watchVideo(mockReq, mockRes);

      // Check that history was added - note: id from params is a string
      expect(dbPromise.execute).toHaveBeenNthCalledWith(
        3,
        "INSERT INTO menonton (idVideo, idPengguna, watchedAt) VALUES (?, ?, NOW())",
        ["123", 1] // idVideo is a string because it comes from params
      );
    });
  });

  describe("getVideodeskripsi Function", () => {
    test("should return video deskripsi", async () => {
      const mockReq = {
        params: { id: "123" },
      };

      const mockRes = {
        json: jest.fn(),
      };

      // Check what function name is actually exported
      // If it's getVideodeskripsi, use that instead
      if (videoController.getVideodeskripsi) {
        const mockVideo = [
          {
            idVideo: 123,
            title: "Test Video",
            deskripsi: "Detailed deskripsi here",
          },
        ];

        dbPromise.execute.mockResolvedValue([mockVideo]);

        await videoController.getVideodeskripsi(mockReq, mockRes);

        expect(mockRes.json).toHaveBeenCalledWith({
          success: true,
          video: {
            id: 123,
            title: "Test Video",
            deskripsi: "Detailed deskripsi here",
          },
        });
      } else {
        // If getVideodeskripsi exists
        const mockVideo = [
          {
            idVideo: 123,
            title: "Test Video",
            deskripsi: "Detailed deskripsi here",
          },
        ];

        dbPromise.execute.mockResolvedValue([mockVideo]);

        await videoController.getVideodeskripsi(mockReq, mockRes);

        expect(mockRes.json).toHaveBeenCalledWith({
          success: true,
          video: {
            id: 123,
            title: "Test Video",
            deskripsi: "Detailed deskripsi here",
          },
        });
      }
    });
  });

  describe("addVideo Function", () => {
    test("should add video successfully with all files", async () => {
      const mockReq = {
        body: {
          title: "Test Video",
          deskripsi: "Test description",
        },
        files: {
          video: [
            {
              path: "/tmp/video123.mp4",
              mimetype: "video/mp4",
            },
          ],
          thumbnail: [
            {
              path: "/tmp/thumbnail123.jpg",
            },
          ],
        },
        get: jest.fn().mockReturnValue("localhost:3000"),
      };

      const mockRes = {
        json: jest.fn(),
      };

      path.relative
        .mockReturnValueOnce("uploads/videos/video123.mp4")
        .mockReturnValueOnce("uploads/thumbnails/thumbnail123.jpg");

      // Fix the mock structure
      dbPromise.execute
        .mockResolvedValueOnce([{ insertId: 123 }]) // First call: INSERT
        .mockResolvedValueOnce([[{ id: 123 }]]); // Second call: LAST_INSERT_ID (returns array of rows)

      await videoController.addVideo(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: "Video berhasil ditambahkan",
        videoId: 123,
        videoUrl: "http://localhost:3000/api/video/watch/123",
      });
    });

    test("should return 400 when video file is missing", async () => {
      const mockReq = {
        body: {
          title: "Test Video",
          deskripsi: "Test deskripsi",
        },
        files: {}, // No video file
      };

      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      await videoController.addVideo(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: "Video file is required",
      });
    });
  });

  describe("updateVideo Function", () => {
    test("should update video without new files", async () => {
      const mockReq = {
        params: { id: "123" },
        body: {
          title: "Updated Video",
          deskripsi: "Updated deskripsi",
        },
        files: {},
        get: jest.fn().mockReturnValue("localhost:3000"),
      };

      const mockRes = {
        json: jest.fn(),
      };

      const mockExistingVideo = [
        {
          videoPath: "uploads/videos/old-video.mp4",
          thumbnailPath: "uploads/thumbnails/old-thumbnail.jpg",
        },
      ];

      dbPromise.execute
        .mockResolvedValueOnce([mockExistingVideo]) // SELECT existing
        .mockResolvedValueOnce([{ affectedRows: 1 }]); // UPDATE

      await videoController.updateVideo(mockReq, mockRes);

      // Check that UPDATE was called with correct parameters
      // Note: deskripsi field might be named differently in your actual controller
      expect(dbPromise.execute).toHaveBeenNthCalledWith(
        2,
        expect.stringMatching(
          /UPDATE video SET title = \?, (deskripsi|deskripsi) = \? WHERE idVideo = \?/
        ),
        expect.arrayContaining(["Updated Video", "Updated deskripsi", "123"])
      );
    });

    test("should return 404 when video not found", async () => {
      const mockReq = {
        params: { id: "999" },
        body: {
          title: "Updated Video",
          deskripsi: "Updated deskripsi",
        },
        files: {},
      };

      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.execute.mockResolvedValue([[]]);

      await videoController.updateVideo(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
    });
  });

  describe("deleteVideo Function", () => {
    test("should delete video and files", async () => {
      const mockReq = {
        params: { id: "123" },
      };

      const mockRes = {
        json: jest.fn(),
      };

      const mockExistingVideo = [
        {
          videoPath: "uploads/videos/video123.mp4",
          thumbnailPath: "uploads/thumbnails/thumbnail123.jpg",
        },
      ];

      dbPromise.execute
        .mockResolvedValueOnce([mockExistingVideo]) // SELECT
        .mockResolvedValueOnce([{ affectedRows: 1 }]); // DELETE

      path.join
        .mockReturnValueOnce("/full/path/to/video123.mp4")
        .mockReturnValueOnce("/full/path/to/thumbnail123.jpg");

      fs.existsSync.mockReturnValueOnce(true).mockReturnValueOnce(true);

      fs.promises.unlink.mockResolvedValueOnce().mockResolvedValueOnce();

      await videoController.deleteVideo(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: "Video berhasil dihapus",
      });
    });
  });

  describe("getAllVideos Function", () => {
    test("should return all videos with URLs", async () => {
      const mockReq = {
        get: jest.fn().mockReturnValue("localhost:3000"),
      };

      const mockRes = {
        json: jest.fn(),
      };

      const mockVideos = [
        {
          idVideo: 1,
          title: "Video 1",
          deskripsi: "Desc 1",
          thumbnailPath: "uploads/thumb1.jpg",
          videoPath: "uploads/video1.mp4",
          mime_type: "video/mp4",
          sentDate: "2024-01-15 10:30:00",
        },
      ];

      dbPromise.execute.mockResolvedValue([mockVideos]);

      await videoController.getAllVideos(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        videos: expect.arrayContaining([
          expect.objectContaining({
            id: 1,
            title: "Video 1",
            videoUrl: "http://localhost:3000/api/video/watch/1",
          }),
        ]),
      });
    });
  });
});
