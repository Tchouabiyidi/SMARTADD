const bcrypt = require('bcryptjs');
const { Op } = require('sequelize');
const { User } = require('../../models');

class UserService {
  static async createUser({ name, email, phone, password, role }) {
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      const error = new Error('User with this email address already exists.');
      error.statusCode = 400;
      throw error;
    }

    const validRoles = ['ADVERTISER', 'BILLBOARD_OWNER', 'ADMIN'];
    const userRole = validRoles.includes(role) ? role : 'ADVERTISER';

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = await User.create({
      name,
      email,
      phone: phone || null,
      password: hashedPassword,
      role: userRole,
    });

    const userJson = user.toJSON();
    delete userJson.password;
    return userJson;
  }

  static async getAllUsers({ role, search }) {
    const whereClause = {};

    if (role && ['ADVERTISER', 'BILLBOARD_OWNER', 'ADMIN'].includes(role.toUpperCase())) {
      whereClause.role = role.toUpperCase();
    }

    if (search) {
      whereClause[Op.or] = [
        { name: { [Op.like]: `%${search}%` } },
        { email: { [Op.like]: `%${search}%` } },
        { phone: { [Op.like]: `%${search}%` } },
      ];
    }

    return User.findAll({
      where: whereClause,
      attributes: { exclude: ['password'] },
      order: [['created_at', 'DESC']],
    });
  }

  static async getUserById(id) {
    return User.findByPk(id, {
      attributes: { exclude: ['password'] },
    });
  }

  static async updateUser(id, updateData) {
    const user = await User.findByPk(id);
    if (!user) {
      const error = new Error('User not found.');
      error.statusCode = 404;
      throw error;
    }

    if (updateData.role && !['ADVERTISER', 'BILLBOARD_OWNER', 'ADMIN'].includes(updateData.role)) {
      const error = new Error('Invalid user role provided.');
      error.statusCode = 400;
      throw error;
    }

    if (updateData.password) {
      const salt = await bcrypt.genSalt(10);
      updateData.password = await bcrypt.hash(updateData.password, salt);
    }

    await user.update(updateData);

    const userJson = user.toJSON();
    delete userJson.password;
    return userJson;
  }

  static async changeRole(id, newRole) {
    const validRoles = ['ADVERTISER', 'BILLBOARD_OWNER', 'ADMIN'];
    if (!validRoles.includes(newRole)) {
      const error = new Error(`Invalid role '${newRole}'. Allowed roles: ADVERTISER, BILLBOARD_OWNER, ADMIN.`);
      error.statusCode = 400;
      throw error;
    }

    const user = await User.findByPk(id);
    if (!user) {
      const error = new Error('User not found.');
      error.statusCode = 404;
      throw error;
    }

    await user.update({ role: newRole });

    const userJson = user.toJSON();
    delete userJson.password;
    return userJson;
  }

  static async deleteUser(id) {
    const user = await User.findByPk(id);
    if (!user) {
      const error = new Error('User not found.');
      error.statusCode = 404;
      throw error;
    }

    await user.destroy();
    return true;
  }
}

module.exports = UserService;
