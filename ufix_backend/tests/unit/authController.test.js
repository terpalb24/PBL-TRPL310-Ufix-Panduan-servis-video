// tests/unit/authController.test.js - FIXED
// Clear module cache
delete require.cache[require.resolve('../../config/database')];
delete require.cache[require.resolve('jsonwebtoken')];
delete require.cache[require.resolve('crypto')];
delete require.cache[require.resolve('../../controllers/authController')];

// Mock all dependencies
jest.mock('../../config/database', () => ({
  dbPromise: {
    query: jest.fn(),
    execute: jest.fn(),
  },
}));

jest.mock('jsonwebtoken', () => ({
  sign: jest.fn(),
}));

jest.mock('crypto', () => ({
  createHash: jest.fn(),
}));

const { dbPromise } = require('../../config/database');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const authController = require('../../controllers/authController');

describe('Auth Controller - Correct Test', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    
    // Default crypto mock
    crypto.createHash.mockReturnValue({
      update: jest.fn().mockReturnThis(),
      digest: jest.fn().mockReturnValue('hashed_password_123'),
    });
  });

  describe('signUp Function', () => {
    test('should successfully register a new user', async () => {
      const mockReq = {
        body: {
          email: 'test@example.com',
          displayName: 'Test User',
          PASSWORD: 'password123',
        },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      // Mock database calls
      dbPromise.query
        .mockResolvedValueOnce([[]]) // No existing user
        .mockResolvedValueOnce([{ insertId: 123 }]); // Insert successful

      await authController.signUp(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'User berhasil didaftarkan',
        user: expect.any(Object),
      });
    });

    test('should return 400 when required fields are missing', async () => {
      const mockReq = {
        body: { email: 'test@example.com' }, // Missing other fields
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      await authController.signUp(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Masukkan Email, Display Name, dan Password',
      });
    });

    test('should return 400 when email already exists', async () => {
      const mockReq = {
        body: {
          email: 'existing@example.com',
          displayName: 'Test User',
          PASSWORD: 'password123',
        },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      // Mock existing user
      dbPromise.query.mockResolvedValueOnce([[{ id: 1, email: 'existing@example.com' }]]);

      await authController.signUp(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Email sudah terdaftar',
      });
    });
  });

  describe('login Function', () => {
    test('should login successfully with correct credentials', async () => {
      const mockReq = {
        body: {
          email: 'user@example.com',
          password: 'password123',
        },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      const mockUser = [
        {
          idPengguna: 1,
          email: 'user@example.com',
          displayName: 'Test User',
          role: 'appuser',
          PASSWORD: 'hashed_password_123',
        },
      ];

      dbPromise.execute.mockResolvedValueOnce([mockUser]);
      jwt.sign.mockReturnValue('mock_jwt_token');

      await authController.login(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Login berhasil',
        token: 'mock_jwt_token',
        user: expect.any(Object),
      });
    });

    test('should return 401 with invalid credentials', async () => {
      const mockReq = {
        body: {
          email: 'wrong@example.com',
          password: 'wrongpass',
        },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.execute.mockResolvedValueOnce([[]]); // No user found

      await authController.login(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Email atau password salah',
      });
    });
  });

  describe('loginAdmin Function', () => {
    test('should login admin successfully', async () => {
      const mockReq = {
        body: {
          email: 'admin@example.com',
          password: 'admin123',
        },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      const mockAdmin = [
        {
          idPengguna: 1,
          email: 'admin@example.com',
          displayName: 'Admin User',
          role: 'admin',
          PASSWORD: 'hashed_password_123',
        },
      ];

      dbPromise.query.mockResolvedValueOnce([mockAdmin]);
      jwt.sign.mockReturnValue('mock_jwt_token');

      await authController.loginAdmin(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Login admin berhasil',
        token: 'mock_jwt_token',
        user: expect.any(Object),
      });
    });

    test('should return 401 when no admin found', async () => {
      const mockReq = {
        body: {
          email: 'user@example.com',
          password: 'password123',
        },
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.query.mockResolvedValueOnce([[]]); // No admin found

      await authController.loginAdmin(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Admin tidak ditemukan atau email tidak terdaftar sebagai admin',
      });
    });
  });

  describe('getProfile Function', () => {
    test('should return user profile', async () => {
      const mockReq = {
        userId: 1,
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      const mockUser = [
        {
          idPengguna: 1,
          displayName: 'Test User',
          email: 'test@example.com',
          role: 'appuser',
        },
      ];

      dbPromise.query.mockResolvedValueOnce([mockUser]);

      await authController.getProfile(mockReq, mockRes);

      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        user: mockUser[0],
      });
    });

    test('should return 404 when user not found', async () => {
      const mockReq = {
        userId: 999,
      };
      
      const mockRes = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn(),
      };

      dbPromise.query.mockResolvedValueOnce([[]]); // No user found

      await authController.getProfile(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Pengguna tidak terdaftar',
      });
    });
  });
});