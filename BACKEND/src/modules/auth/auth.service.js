const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { User } = require('../../models');

class AuthService {
  static async registerPublicUser({ name, email, phone, password, role }) {
    // Prevent public creation of ADMIN accounts
    if (role === 'ADMIN') {
      const error = new Error('Admin accounts cannot be registered publicly.');
      error.statusCode = 400;
      throw error;
    }

    const allowedRoles = ['ADVERTISER', 'BILLBOARD_OWNER'];
    const targetRole = allowedRoles.includes(role) ? role : 'ADVERTISER';

    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      const error = new Error('User with this email address already exists.');
      error.statusCode = 400;
      throw error;
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = await User.create({
      name,
      email,
      phone: phone || null,
      password: hashedPassword,
      role: targetRole,
    });

    const token = this.generateToken(user);
    const userJson = user.toJSON();
    delete userJson.password;

    return { user: userJson, token };
  }

  static async login({ email, password }) {
    const user = await User.findOne({ where: { email } });
    if (!user) {
      const error = new Error('Invalid email or password.');
      error.statusCode = 401;
      throw error;
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      const error = new Error('Invalid email or password.');
      error.statusCode = 401;
      throw error;
    }

    const token = this.generateToken(user);
    const userJson = user.toJSON();
    delete userJson.password;

    return { user: userJson, token };
  }

  static generateToken(user) {
    const secret = process.env.JWT_SECRET || 'smartadd_super_secret_jwt_key_2026_production';
    const expiresIn = process.env.JWT_EXPIRES_IN || '7d';
    return jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      secret,
      { expiresIn }
    );
  }
}

module.exports = AuthService;
