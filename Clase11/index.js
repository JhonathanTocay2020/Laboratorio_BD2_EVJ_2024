require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const AWS = require('aws-sdk');

// Configurar AWS SDK
const s3 = new AWS.S3({
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
});

const app = express();
app.use(bodyParser.json({ limit: '10mb' })); // Permitir carga de imágenes grandes

// Ruta para subir imagen
app.post('/upload', async (req, res) => {
    const { base64Image } = req.body;

    if (!base64Image) {
        return res.status(400).send({ message: 'Falta el parámetro base64Image' });
    }

    try {
        // Generar nombre de archivo usando la fecha actual
        const currentDate = new Date();
        const fileName = `${currentDate.getFullYear()}-${currentDate.getMonth() + 1}-${currentDate.getDate()}.png`;

        // Decodificar el string base64
        const buffer = Buffer.from(base64Image, 'base64');

        // Parámetros para la subida a S3
        const params = {
            Bucket: process.env.AWS_BUCKET_NAME,
            Key: fileName,
            Body: buffer,
            ContentEncoding: 'base64',
            ContentType: 'image/png' // Ajusta esto según el tipo de imagen
        };

        // Subir el archivo a S3
        const data = await s3.upload(params).promise();
        res.status(200).send({ message: 'Archivo subido con éxito', url: data.Location });
    } catch (err) {
        console.error('Error subiendo el archivo a S3:', err);
        res.status(500).send({ message: 'Error subiendo el archivo a S3', error: err.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor escuchando en el puerto ${PORT}`);
});