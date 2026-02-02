'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Item extends Model {

    /*static associate(models) {
 
    }*/
  }
  Item.init({
    taskName: DataTypes.STRING,
    isCompleted: DataTypes.BOOLEAN,
    checklistId: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'Item',
  });
  return Item;
};