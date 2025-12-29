// tests/unit/commentsController.test.js - FIXED
// Clear module cache
delete require.cache[require.resolve('../../config/database')];
delete require.cache[require.resolve('../../controllers/commentsController')];

// Mock the database
jest.mock('../../config/database', () => ({
  dbPromise: {
    execute: jest.fn(),
    query: jest.fn(),
  },
}));

const { dbPromise } = require('../../config/database');
const commentsController = require('../../controllers/commentsController');

describe('Comments Controller - Correct Test', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getCommentsByVideo Function', () => {
    test('should return comments for a video', async () => {
      const mockReq = {
        params: { id: '123' },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      const mockComments = [
        {
          idKomentar: 1,
          sentDate: '2024-01-15 10:30:00',
          isi: 'Great video!',
          idPengomentar: 456,
          idVideo: 123,
          pengomentarId: 456,
          pengomentarName: 'John Doe',
        },
      ];

      // Mock primary key detection and query
      dbPromise.execute
        .mockResolvedValueOnce([[{ COLUMN_NAME: 'idPengguna', COLUMN_TYPE: 'int(11)' }]])
        .mockResolvedValueOnce([mockComments]);

      await commentsController.getCommentsByVideo(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        count: 1,
        comments: mockComments,
      });
    });

    test('should return 400 when videoId is missing', async () => {
      const mockReq = {
        params: { id: '' },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      await commentsController.getCommentsByVideo(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'idVideo is required',
      });
    });

    test('should handle empty result set', async () => {
      const mockReq = {
        params: { id: '999' },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.execute
        .mockResolvedValueOnce([[{ COLUMN_NAME: 'idPengguna', COLUMN_TYPE: 'int(11)' }]])
        .mockResolvedValueOnce([[]]);

      await commentsController.getCommentsByVideo(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        count: 0,
        comments: [],
      });
    });
  });

  describe('addComment Function', () => {
    test('should create a new comment', async () => {
      const mockReq = {
        body: {
          isi: 'This is a test comment',
          idVideo: 123,
          idPengomentar: 456,
        },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      const mockInsertResult = { insertId: 789 };
      const mockComment = {
        idKomentar: 789,
        sentDate: '2024-01-15 10:30:00',
        isi: 'This is a test comment',
        idPengomentar: 456,
        idVideo: 123,
      };

      dbPromise.execute
        .mockResolvedValueOnce([mockInsertResult])
        .mockResolvedValueOnce([[mockComment]]);

      await commentsController.addComment(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Komentar berhasil ditambahkan',
        idKomentar: 789,
        comment: mockComment,
      });
    });

    test('should return 400 when required fields are missing', async () => {
      const mockReq = {
        body: { idVideo: 123 }, // Missing isi
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      await commentsController.addComment(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Fields "isi" and "idVideo" are required',
      });
    });
  });

  describe('updateComment Function', () => {
    test('should update comment successfully', async () => {
      const mockReq = {
        params: { id: '1' },
        body: { isi: 'Updated comment content' },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.execute.mockResolvedValueOnce([{ affectedRows: 1 }]);

      await commentsController.updateComment(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Komentar berhasil diperbarui',
      });
    });

    test('should return 404 when comment not found', async () => {
      const mockReq = {
        params: { id: '999' },
        body: { isi: 'Updated content' },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.execute.mockResolvedValueOnce([{ affectedRows: 0 }]);

      await commentsController.updateComment(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Comment not found',
      });
    });
  });

  describe('deleteComment Function', () => {
    test('should delete comment successfully', async () => {
      const mockReq = {
        params: { id: '1' },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.execute.mockResolvedValueOnce([{ affectedRows: 1 }]);

      await commentsController.deleteComment(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Komentar berhasil dihapus',
      });
    });

    test('should return 404 when comment not found', async () => {
      const mockReq = {
        params: { id: '999' },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.execute.mockResolvedValueOnce([{ affectedRows: 0 }]);

      await commentsController.deleteComment(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Comment not found',
      });
    });
  });

  describe('Reply Functions', () => {
    test('getRepliesByComment should return replies', async () => {
      const mockReq = {
        params: { id: '1' },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      const mockReplies = [
        {
          idReply: 1,
          sentDate: '2024-01-15 11:00:00',
          isi: 'This is a reply',
          idPengirim: 456,
          idKomentar: 1,
          parentReplyId: null,
        },
      ];

      dbPromise.execute
        .mockResolvedValueOnce([[{ COLUMN_NAME: 'idPengguna', COLUMN_TYPE: 'int(11)' }]])
        .mockResolvedValueOnce([mockReplies]);

      await commentsController.getRepliesByComment(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        count: 1,
        replies: mockReplies,
      });
    });

    test('addReply should create a reply', async () => {
      const mockReq = {
        params: { id: '1' },
        body: {
          isi: 'This is a reply',
          idPengirim: 456,
          parentReplyId: null,
        },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.execute
        .mockResolvedValueOnce([[{ COLUMN_NAME: 'parentReplyId' }]]) // Column exists
        .mockResolvedValueOnce([{ insertId: 50 }]) // INSERT
        .mockResolvedValueOnce([[]]); // SELECT

      await commentsController.addReply(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Reply added',
        idReply: 50,
        reply: null,
      });
    });
  });
});