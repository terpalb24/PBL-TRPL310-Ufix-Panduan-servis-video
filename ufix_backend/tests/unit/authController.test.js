// tests/unit/authController.test.js
const authController = require('../../lib/controllers/authController');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');

// Mock all external dependencies
jest.mock('crypto');
jest.mock('jsonwebtoken');

// Create mock response object
const createMockRes = () => ({
  status: jest.fn().mockReturnThis(),
  json: jest.fn().mockReturnThis(),
});

describe('Auth Controller - Unit Tests', () => {
  let mockDbPromise;
  
  beforeEach(() => {
    // Reset all mocks
    jest.clearAllMocks();
    
    // Create mock database instance
    mockDbPromise = {
      query: jest.fn(),
      execute: jest.fn(),
    };
    
    // Replace the actual dbPromise with our mock
    jest.mock('../../lib/config/database', () => ({
      dbPromise: mockDbPromise,
    }));
    
    // Reload the controller to use the mock
    jest.resetModules();
    authController = require('../../lib/controllers/authController');
    
    // Mock crypto
    crypto.createHash.mockReturnValue({
      update: jest.fn().mockReturnThis(),
      digest: jest.fn().mockReturnValue('hashed_password_123'),
    });
    
    // Mock JWT
    jwt.sign.mockReturnValue('mock_jwt_token');
  });

  describe('signUp Function', () => {
    test('should return 400 when required fields are missing', async () => {
      const mockReq = { body: { email: 'test@example.com' } }; // Missing displayName and password
      const mockRes = createMockRes();
      
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
      const mockRes = createMockRes();
      
      // Mock database query to return existing user
      mockDbPromise.query
        .mockResolvedValueOnce([[{ id: 1, email: 'existing@example.com' }]]); // SELECT query
      
      await authController.signUp(mockReq, mockRes);
      
      expect(mockDbPromise.query).toHaveBeenCalledWith(
        'SELECT * FROM users WHERE email = ?',
        ['existing@example.com']
      );
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Email sudah terdaftar',
      });
    });

    test('should successfully register a new user with default role', async () => {
      const mockReq = {
        body: {
          email: 'newuser@example.com',
          displayName: 'New User',
          PASSWORD: 'password123',
        },
      };
      const mockRes = createMockRes();
      
      // Mock database calls
      mockDbPromise.query
        .mockResolvedValueOnce([[]]) // SELECT returns empty (no existing user)
        .mockResolvedValueOnce([{ insertId: 123 }]); // INSERT returns new ID
      
      await authController.signUp(mockReq, mockRes);
      
      expect(crypto.createHash).toHaveBeenCalledWith('sha256');
      expect(mockDbPromise.query).toHaveBeenCalledTimes(2);
      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'User berhasil didaftarkan',
        user: {
          id: 123,
          displayName: 'New User',
          email: 'newuser@example.com',
          role: 'appuser',
        },
      });
    });

    test('should register with custom role when provided', async () => {
      const mockReq = {
        body: {
          email: 'admin@example.com',
          displayName: 'Admin User',
          PASSWORD: 'admin123',
          role: 'admin',
        },
      };
      const mockRes = createMockRes();
      
      mockDbPromise.query
        .mockResolvedValueOnce([[]])
        .mockResolvedValueOnce([{ insertId: 456 }]);
      
      await authController.signUp(mockReq, mockRes);
      
      expect(mockDbPromise.query).toHaveBeenCalledWith(
        'INSERT INTO users (email, displayName, PASSWORD, role) VALUES (?, ?, ?, ?)',
        ['admin@example.com', 'Admin User', 'hashed_password_123', 'admin']
      );
      expect(mockRes.json).toHaveBeenCalledWith(expect.objectContaining({
        user: expect.objectContaining({ role: 'admin' }),
      }));
    });

    test('should handle database errors gracefully', async () => {
      const mockReq = {
        body: {
          email: 'test@example.com',
          displayName: 'Test User',
          PASSWORD: 'password123',
        },
      };
      const mockRes = createMockRes();
      
      // Mock database to throw an error
      mockDbPromise.query.mockRejectedValueOnce(new Error('Database connection failed'));
      
      await authController.signUp(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Server error: Database connection failed',
      });
    });
  });

  describe('login Function', () => {
    test('should return 400 when email or password is missing', async () => {
      const mockReq = { body: { email: 'test@example.com' } }; // Missing password
      const mockRes = createMockRes();
      
      await authController.login(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Masukkan email dan password',
      });
    });

    test('should return 401 when credentials are invalid', async () => {
      const mockReq = {
        body: { email: 'wrong@example.com', password: 'wrongpass' },
      };
      const mockRes = createMockRes();
      
      mockDbPromise.execute.mockResolvedValueOnce([[]]); // Empty result
      
      await authController.login(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Email atau password salah',
      });
    });

    test('should return token and user data when login is successful', async () => {
      const mockReq = {
        body: { email: 'user@example.com', password: 'correctpass' },
      };
      const mockRes = createMockRes();
      
      const mockUser = {
        idPengguna: 1,
        email: 'user@example.com',
        displayName: 'Test User',
        role: 'appuser',
        PASSWORD: 'hashed_password_123',
      };
      
      mockDbPromise.execute.mockResolvedValueOnce([[mockUser]]);
      
      await authController.login(mockReq, mockRes);
      
      expect(jwt.sign).toHaveBeenCalledWith(
        {
          userId: 1,
          email: 'user@example.com',
          role: 'appuser',
        },
        'default_secret',
        { expiresIn: '24h' }
      );
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        message: 'Login berhasil',
        token: 'mock_jwt_token',
        user: {
          id: 1,
          email: 'user@example.com',
          role: 'appuser',
        },
      });
    });
  });

  describe('loginAdmin Function', () => {
    test('should return 401 when no admin found with the email', async () => {
      const mockReq = {
        body: { email: 'notadmin@example.com', password: 'anypass' },
      };
      const mockRes = createMockRes();
      
      mockDbPromise.query.mockResolvedValueOnce([[]]); // No admin found
      
      await authController.loginAdmin(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Admin tidak ditemukan atau email tidak terdaftar sebagai admin',
      });
    });

    test('should return 401 when password is incorrect', async () => {
      const mockReq = {
        body: { email: 'admin@example.com', password: 'wrongpass' },
      };
      const mockRes = createMockRes();
      
      // Mock different hash for password comparison
      crypto.createHash.mockReturnValue({
        update: jest.fn().mockReturnThis(),
        digest: jest.fn().mockReturnValue('different_hash'),
      });
      
      const mockAdmin = {
        idPengguna: 1,
        email: 'admin@example.com',
        displayName: 'Admin User',
        role: 'admin',
        PASSWORD: 'correct_hash', // Different from our mock
      };
      
      mockDbPromise.query.mockResolvedValueOnce([[mockAdmin]]);
      
      await authController.loginAdmin(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(401);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Password salah',
      });
    });

    test('should successfully login admin with correct credentials', async () => {
      const mockReq = {
        body: { email: 'admin@example.com', password: 'admin123' },
      };
      const mockRes = createMockRes();
      
      const mockAdmin = {
        idPengguna: 1,
        email: 'admin@example.com',
        displayName: 'Admin User',
        role: 'admin',
        PASSWORD: 'hashed_password_123', // Same as our mock
      };
      
      mockDbPromise.query.mockResolvedValueOnce([[mockAdmin]]);
      
      await authController.loginAdmin(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalledWith(expect.objectContaining({
        success: true,
        message: 'Login admin berhasil',
      }));
    });
  });

  describe('getProfile Function', () => {
    test('should return 404 when user not found', async () => {
      const mockReq = { userId: 999 }; // Non-existent user ID
      const mockRes = createMockRes();
      
      mockDbPromise.query.mockResolvedValueOnce([[]]); // Empty result
      
      await authController.getProfile(mockReq, mockRes);
      
      expect(mockRes.status).toHaveBeenCalledWith(404);
      expect(mockRes.json).toHaveBeenCalledWith({
        success: false,
        message: 'Pengguna tidak terdaftar',
      });
    });

    test('should return user profile when user exists', async () => {
      const mockReq = { userId: 1 };
      const mockRes = createMockRes();
      
      const mockUser = [
        {
          idPengguna: 1,
          displayName: 'Test User',
          email: 'test@example.com',
          role: 'appuser',
        },
      ];
      
      mockDbPromise.query.mockResolvedValueOnce([mockUser]);
      
      await authController.getProfile(mockReq, mockRes);
      
      expect(mockDbPromise.query).toHaveBeenCalledWith(
        'SELECT idPengguna, displayName, email, role FROM users WHERE idPengguna = ?',
        [1]
      );
      expect(mockRes.json).toHaveBeenCalledWith({
        success: true,
        user: mockUser[0],
      });
    });
  });
});