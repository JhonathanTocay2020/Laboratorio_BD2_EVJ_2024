create database BD2_C3;
use BD2_C3;
use master;
DROP DATABASE BD2_C3;

-- Tabla Catedraticos
CREATE TABLE Catedraticos (
    CatedraticoID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(255)
);

-- Tabla Auxiliares
CREATE TABLE Auxiliares (
    AuxiliarID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(255)
);

-- Tabla Cursos
CREATE TABLE Cursos (
    CursoID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre_de_Curso VARCHAR(500)
);

-- Tabla Secciones
CREATE TABLE Secciones (
    SeccionID INT IDENTITY(1,1) PRIMARY KEY,
    Seccion VARCHAR(50)
);

-- Tabla Modalidades
CREATE TABLE Modalidades (
    ModalidadID INT IDENTITY(1,1) PRIMARY KEY,
    Modalidad VARCHAR(50)
);

-- Tabla Edificios
CREATE TABLE Edificios (
    EdificioID INT IDENTITY(1,1) PRIMARY KEY,
    Edificio VARCHAR(50)
);

-- Tabla Salones
CREATE TABLE Salones (
    SalonID INT IDENTITY(1,1) PRIMARY KEY,
    Salon VARCHAR(50),
    EdificioID INT,
    FOREIGN KEY (EdificioID) REFERENCES Edificios(EdificioID)
);

-- Tabla Horarios
CREATE TABLE Horarios (
    HorarioID INT IDENTITY(1,1) PRIMARY KEY,
    Inicio TIME,
    Final TIME
);

-- Tabla Curso_Seccion (Relación entre Cursos y Secciones con detalles adicionales)
CREATE TABLE Curso_Seccion (
    Curso_SeccionID INT IDENTITY(1,1) PRIMARY KEY,
    CursoID INT,
    SeccionID INT,
    ModalidadID INT,
    SalonID INT,
    HorarioID INT,
    CatedraticoID INT,
    AuxiliarID INT,
    FOREIGN KEY (CursoID) REFERENCES Cursos(CursoID),
    FOREIGN KEY (SeccionID) REFERENCES Secciones(SeccionID),
    FOREIGN KEY (ModalidadID) REFERENCES Modalidades(ModalidadID),
    FOREIGN KEY (SalonID) REFERENCES Salones(SalonID),
    FOREIGN KEY (HorarioID) REFERENCES Horarios(HorarioID),
    FOREIGN KEY (CatedraticoID) REFERENCES Catedraticos(CatedraticoID),
    FOREIGN KEY (AuxiliarID) REFERENCES Auxiliares(AuxiliarID)
);

-- Tabla Temporal 
CREATE TABLE Temp_Cursos (
    Nombre_de_Curso VARCHAR(500),
    Seccion VARCHAR(50),
    Modalidad VARCHAR(50),
    Edificio VARCHAR(50),
    Salon VARCHAR(50),
    Inicio TIME,
    Final TIME,
    Catedratico VARCHAR(255),
    Auxiliar VARCHAR(255)
);

SELECT * FROM Temp_Cursos;
truncate table Temp_Cursos;

-- Llenar Tablas

-- Insertar en la tabla Cursos
INSERT INTO Cursos (Nombre_de_Curso)
SELECT DISTINCT Nombre_de_Curso FROM Temp_Cursos;

-- Insertar en la tabla Secciones
INSERT INTO Secciones (Seccion)
SELECT DISTINCT Seccion FROM Temp_Cursos;

-- Insertar en la tabla Modalidades
INSERT INTO Modalidades (Modalidad)
SELECT DISTINCT Modalidad FROM Temp_Cursos;

-- Insertar en la tabla Edificios
INSERT INTO Edificios (Edificio)
SELECT DISTINCT Edificio FROM Temp_Cursos;

-- Insertar en la tabla Salones
INSERT INTO Salones (Salon, EdificioID)
SELECT DISTINCT Salon, e.EdificioID 
FROM Temp_Cursos t
JOIN Edificios e ON t.Edificio = e.Edificio;

-- Insertar en la tabla Horarios
INSERT INTO Horarios (Inicio, Final)
SELECT DISTINCT Inicio, Final FROM Temp_Cursos;

-- Insertar en la tabla Catedraticos
INSERT INTO Catedraticos (Nombre)
SELECT DISTINCT Catedratico FROM Temp_Cursos
WHERE Catedratico IS NOT NULL AND Catedratico <> '';

-- Insertar en la tabla Auxiliares
INSERT INTO Auxiliares (Nombre)
SELECT DISTINCT Auxiliar FROM Temp_Cursos
WHERE Auxiliar IS NOT NULL AND Auxiliar <> '';

-- Insertar en la tabla Curso_Seccion
INSERT INTO Curso_Seccion (CursoID, SeccionID, ModalidadID, SalonID, HorarioID, CatedraticoID, AuxiliarID)
SELECT DISTINCT 
    c.CursoID,
    s.SeccionID,
    m.ModalidadID,
    sl.SalonID,
    h.HorarioID,
    ca.CatedraticoID,
    a.AuxiliarID
FROM Temp_Cursos t
JOIN Cursos c ON t.Nombre_de_Curso = c.Nombre_de_Curso
JOIN Secciones s ON t.Seccion = s.Seccion
JOIN Modalidades m ON t.Modalidad = m.Modalidad
JOIN Salones sl ON t.Salon = sl.Salon
JOIN Edificios e ON t.Edificio = e.Edificio
JOIN Horarios h ON t.Inicio = h.Inicio AND t.Final = h.Final
LEFT JOIN Catedraticos ca ON t.Catedratico = ca.Nombre
LEFT JOIN Auxiliares a ON t.Auxiliar = a.Nombre;

-- Selects 

Select * from Catedraticos;
Select * from Auxiliares;
Select * from Secciones;
Select * from Modalidades;

-- Tarea por hacer

CREATE PROCEDURE ObtenerCursosPorHoraInicio
    @HoraInicio TIME
AS
BEGIN
    SELECT 
        c.Nombre_de_Curso,
        s.Seccion,
        m.Modalidad,
        e.Edificio,
        sa.Salon,
        h.Inicio,
        h.Final,
        cat.Nombre AS Catedratico,
        aux.Nombre AS Auxiliar
    FROM 
        Curso_Seccion cs
    JOIN 
        Cursos c ON cs.CursoID = c.CursoID
    JOIN 
        Secciones s ON cs.SeccionID = s.SeccionID
    JOIN 
        Modalidades m ON cs.ModalidadID = m.ModalidadID
    JOIN 
        Salones sa ON cs.SalonID = sa.SalonID
    JOIN 
        Edificios e ON sa.EdificioID = e.EdificioID
    JOIN 
        Horarios h ON cs.HorarioID = h.HorarioID
    LEFT JOIN 
        Catedraticos cat ON cs.CatedraticoID = cat.CatedraticoID
    LEFT JOIN 
        Auxiliares aux ON cs.AuxiliarID = aux.AuxiliarID
    WHERE 
        h.Inicio = @HoraInicio;
END;

EXEC ObtenerCursosPorHoraInicio '07:00:00'; -- Reemplaza '09:00:00' con la hora específica que desees

