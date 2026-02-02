'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Checklist extends Model {
    static associate(models) {

      Checklist.belongsTo(models.Category, { foreignKey: 'categoryId' });
      Checklist.hasMany(models.Item, { foreignKey: 'checklistId' });
    }
  }
  Checklist.init({
    title: DataTypes.STRING,

    categoryId: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'Checklist',
  });
  return Checklist;
};