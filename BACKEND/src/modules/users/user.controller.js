const UserService = require('./user.service');

class UserController {
  static async createUser(req, res, next) {
    try {
      const { name, email, phone, password, role } = req.body;
      if (!name || !email || !password) {
        return res.status(400).json({
          success: false,
          message: 'Name, email, and password are required.',
        });
      }

      const user = await UserService.createUser({ name, email, phone, password, role });
      res.status(201).json({
        success: true,
        message: 'User account created successfully.',
        data: user,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getAllUsers(req, res, next) {
    try {
      const { role, search } = req.query;
      const users = await UserService.getAllUsers({ role, search });
      res.status(200).json({
        success: true,
        data: users,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getUserById(req, res, next) {
    try {
      const user = await UserService.getUserById(req.params.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found.',
        });
      }
      res.status(200).json({
        success: true,
        data: user,
      });
    } catch (error) {
      next(error);
    }
  }

  static async updateUser(req, res, next) {
    try {
      const updatedUser = await UserService.updateUser(req.params.id, req.body);
      res.status(200).json({
        success: true,
        message: 'User profile updated successfully.',
        data: updatedUser,
      });
    } catch (error) {
      next(error);
    }
  }

  static async changeRole(req, res, next) {
    try {
      const { role } = req.body;
      if (!role) {
        return res.status(400).json({
          success: false,
          message: 'Role parameter is required.',
        });
      }

      const updatedUser = await UserService.changeRole(req.params.id, role);
      res.status(200).json({
        success: true,
        message: `User role changed to '${role}' successfully.`,
        data: updatedUser,
      });
    } catch (error) {
      next(error);
    }
  }

  static async deleteUser(req, res, next) {
    try {
      await UserService.deleteUser(req.params.id);
      res.status(200).json({
        success: true,
        message: 'User account deleted successfully.',
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = UserController;
