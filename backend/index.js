require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { CheckList, Item, Category } = require('./models');
const app = express();
app.use(cors());
app.use(express.json());


app.get('/api/checklist', async (req, res) => {
    try {
        const checklists = await Checklist.findAll({
            include: [{ model: Item }, { model: Category }]
        });
        res.json(checklists);
    } catch (error) {
        res.status(500).json({ error: "Listeler Çekilemedi", details: error.message });
    }
});
app.post('/api/checklists', async (req, res) => {
    try {
        const newList = await Checklist.create(req.body);
        res.status(201).json(newList);
    } catch (err) {
        res.status(400).json({ error: "Liste oluşturulamadı" });
    }
});
app.post('/api/items', async (req, res) => {
    try {
        const newItem = await Item.create(req.body);
        res.status(201).json(newItem);
    } catch (err) {
        res.status(400).json({ error: "Madde eklenemedi" });
    }
});
app.patch('/api/items/:id', async (req, res) => {
    try {
        const item = await Item.findByPk(req.params.id);
        if (item) {
            item.isCompleted = !item.isCompleted; // Mevcut durumu tersine çevir
            await item.save();
            res.json(item);
        } else {
            res.status(404).json({ error: "Madde bulunamadı" });
        }
    } catch (err) {
        res.status(500).json({ error: "Güncelleme hatası" });
    }
});
app.delete('/api/checklists/:id', async (req, res) => {
    try {
        await Checklist.destroy({ where: { id: req.params.id } });
        res.json({ message: "Liste silindi" });
    } catch (err) {
        res.status(500).json({ error: "Silme hatası" });
    }
});
app.listen(process.env.port, () => {
    console.log(`Example app listening on port ${process.env.port}`);
});