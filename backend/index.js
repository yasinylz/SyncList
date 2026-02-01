require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Checklist, Item, Category } = require('./models');
const app = express();
app.use(cors());
app.use(express.json());

// ==================== CATEGORY ENDPOINTS ====================

// Tüm kategorileri getir
app.get('/api/categories', async (req, res) => {
    try {
        const categories = await Category.findAll();
        res.json(categories);
    } catch (error) {
        res.status(500).json({ error: "Kategoriler çekilemedi", details: error.message });
    }
});

// Yeni kategori oluştur
app.post('/api/categories', async (req, res) => {
    try {
        const newCategory = await Category.create(req.body);
        res.status(201).json(newCategory);
    } catch (err) {
        res.status(400).json({ error: "Kategori oluşturulamadı", details: err.message });
    }
});

// ==================== CHECKLIST ENDPOINTS ====================

// Tüm listeleri getir (Item ve Category ile birlikte)
app.get('/api/checklists', async (req, res) => {
    try {
        const checklists = await Checklist.findAll({
            include: [{ model: Item }, { model: Category }]
        });
        res.json(checklists);
    } catch (error) {
        res.status(500).json({ error: "Listeler çekilemedi", details: error.message });
    }
});

// Tek bir listeyi getir
app.get('/api/checklists/:id', async (req, res) => {
    try {
        const checklist = await Checklist.findByPk(req.params.id, {
            include: [{ model: Item }, { model: Category }]
        });
        if (checklist) {
            res.json(checklist);
        } else {
            res.status(404).json({ error: "Liste bulunamadı" });
        }
    } catch (error) {
        res.status(500).json({ error: "Liste çekilemedi", details: error.message });
    }
});

// Yeni liste oluştur
app.post('/api/checklists', async (req, res) => {
    try {
        const newList = await Checklist.create(req.body);
        res.status(201).json(newList);
    } catch (err) {
        res.status(400).json({ error: "Liste oluşturulamadı", details: err.message });
    }
});

// Liste güncelle
app.put('/api/checklists/:id', async (req, res) => {
    try {
        const checklist = await Checklist.findByPk(req.params.id);
        if (checklist) {
            await checklist.update(req.body);
            res.json(checklist);
        } else {
            res.status(404).json({ error: "Liste bulunamadı" });
        }
    } catch (err) {
        res.status(500).json({ error: "Güncelleme hatası", details: err.message });
    }
});

// Liste sil
app.delete('/api/checklists/:id', async (req, res) => {
    try {
        // Önce listeye ait tüm maddeleri sil
        await Item.destroy({ where: { checklistId: req.params.id } });
        // Sonra listeyi sil
        await Checklist.destroy({ where: { id: req.params.id } });
        res.json({ message: "Liste ve maddeleri silindi" });
    } catch (err) {
        res.status(500).json({ error: "Silme hatası", details: err.message });
    }
});

// ==================== ITEM ENDPOINTS ====================

// Belirli bir listeye ait maddeleri getir
app.get('/api/items/:checklistId', async (req, res) => {
    try {
        const items = await Item.findAll({
            where: { checklistId: req.params.checklistId }
        });
        res.json(items);
    } catch (error) {
        res.status(500).json({ error: "Maddeler çekilemedi", details: error.message });
    }
});

// Yeni madde ekle
app.post('/api/items', async (req, res) => {
    try {
        const newItem = await Item.create({
            ...req.body,
            isCompleted: false
        });
        res.status(201).json(newItem);
    } catch (err) {
        res.status(400).json({ error: "Madde eklenemedi", details: err.message });
    }
});

// Madde tamamlanma durumunu değiştir (toggle)
app.patch('/api/items/:id/toggle', async (req, res) => {
    try {
        const item = await Item.findByPk(req.params.id);
        if (item) {
            item.isCompleted = !item.isCompleted;
            await item.save();
            res.json(item);
        } else {
            res.status(404).json({ error: "Madde bulunamadı" });
        }
    } catch (err) {
        res.status(500).json({ error: "Güncelleme hatası", details: err.message });
    }
});

// Madde güncelle
app.put('/api/items/:id', async (req, res) => {
    try {
        const item = await Item.findByPk(req.params.id);
        if (item) {
            await item.update(req.body);
            res.json(item);
        } else {
            res.status(404).json({ error: "Madde bulunamadı" });
        }
    } catch (err) {
        res.status(500).json({ error: "Güncelleme hatası", details: err.message });
    }
});

// Madde sil
app.delete('/api/items/:id', async (req, res) => {
    try {
        await Item.destroy({ where: { id: req.params.id } });
        res.json({ message: "Madde silindi" });
    } catch (err) {
        res.status(500).json({ error: "Silme hatası", details: err.message });
    }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', message: 'SyncList API çalışıyor!' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 SyncList API çalışıyor: http://localhost:${PORT}`);
});