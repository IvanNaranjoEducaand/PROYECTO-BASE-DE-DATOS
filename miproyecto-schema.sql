DROP TABLE IF EXISTS `artistas`;
CREATE TABLE `artistas` (
  `NOMBRE` varchar(40) NOT NULL,
  `PAÍS_ORIGEN` varchar(45) NOT NULL,
  `SUELDO` int NOT NULL,
  `GÉNERO_MUSICAL` varchar(45) NOT NULL,
  `AGENTE/REPRESENTANTE` varchar(45) NOT NULL,
  PRIMARY KEY (`NOMBRE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

DROP TABLE IF EXISTS `conciertos`;
CREATE TABLE `conciertos` (
  `FECHA` date NOT NULL,
  `DURACIÓN` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `ID_INSTALACIÓN` int NOT NULL,
  `GIRA_NOMBRE` varchar(70) NOT NULL,
  PRIMARY KEY (`GIRA_NOMBRE`,`FECHA`),
  KEY `fk_CONCIERTOS_INSTALACIONES_idx` (`ID_INSTALACIÓN`),
  CONSTRAINT `fk_CONCIERTOS_GIRA1` FOREIGN KEY (`GIRA_NOMBRE`) REFERENCES `gira` (`NOMBRE`),
  CONSTRAINT `fk_CONCIERTOS_INSTALACIONES` FOREIGN KEY (`ID_INSTALACIÓN`) REFERENCES `instalaciones` (`ID_INSTALACIONES`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

DROP TABLE IF EXISTS `conciertos_tienen_artistas`;
CREATE TABLE `conciertos_tienen_artistas` (
  `CONCIERTOS_GIRA_NOMBRE` varchar(70) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `CONCIERTOS_FECHA` date NOT NULL,
  `ARTISTAS_NOMBRE` varchar(40) NOT NULL,
  PRIMARY KEY (`CONCIERTOS_GIRA_NOMBRE`,`CONCIERTOS_FECHA`,`ARTISTAS_NOMBRE`),
  KEY `fk_CONCIERTOS_has_ARTISTAS_ARTISTAS1_idx` (`ARTISTAS_NOMBRE`),
  KEY `fk_CONCIERTOS_has_ARTISTAS_CONCIERTOS1_idx` (`CONCIERTOS_GIRA_NOMBRE`,`CONCIERTOS_FECHA`),
  CONSTRAINT `fk_CONCIERTOS_has_ARTISTAS_ARTISTAS1` FOREIGN KEY (`ARTISTAS_NOMBRE`) REFERENCES `artistas` (`NOMBRE`),
  CONSTRAINT `fk_CONCIERTOS_has_ARTISTAS_CONCIERTOS1` FOREIGN KEY (`CONCIERTOS_GIRA_NOMBRE`, `CONCIERTOS_FECHA`) REFERENCES `conciertos` (`GIRA_NOMBRE`, `FECHA`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

DROP TABLE IF EXISTS `copia_seguridad_conciertos`;
CREATE TABLE `copia_seguridad_conciertos` (
  `FECHA` date NOT NULL,
  `DURACIÓN` varchar(10) DEFAULT NULL,
  `ID_INSTALACIÓN` int DEFAULT NULL,
  `GIRA_NOMBRE` varchar(70) DEFAULT NULL,
  PRIMARY KEY (`FECHA`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `entradas`;
CREATE TABLE `entradas` (
  `TIPO` varchar(10) NOT NULL,
  `Nº_ENTRADAS` int NOT NULL,
  `PRECIO` int unsigned NOT NULL,
  `ZONA` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `CÓDIGO_DE_ENTRADA` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `CONCIERTOS_GIRA_NOMBRE` varchar(70) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `CONCIERTOS_FECHA` date NOT NULL,
  PRIMARY KEY (`TIPO`,`CONCIERTOS_GIRA_NOMBRE`,`CONCIERTOS_FECHA`),
  KEY `fk_ENTRADAS_CONCIERTOS1_idx` (`CONCIERTOS_GIRA_NOMBRE`,`CONCIERTOS_FECHA`),
  CONSTRAINT `fk_ENTRADAS_CONCIERTOS1` FOREIGN KEY (`CONCIERTOS_GIRA_NOMBRE`, `CONCIERTOS_FECHA`) REFERENCES `conciertos` (`GIRA_NOMBRE`, `FECHA`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

DROP TABLE IF EXISTS `gira`;
CREATE TABLE `gira` (
  `NOMBRE` varchar(70) NOT NULL,
  `ARTISTAS_NOMBRE` varchar(40) NOT NULL,
  PRIMARY KEY (`NOMBRE`),
  KEY `fk_GIRA_ARTISTAS1_idx` (`ARTISTAS_NOMBRE`),
  CONSTRAINT `fk_GIRA_ARTISTAS1` FOREIGN KEY (`ARTISTAS_NOMBRE`) REFERENCES `artistas` (`NOMBRE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

DROP TABLE IF EXISTS `instalaciones`;
CREATE TABLE `instalaciones` (
  `ID_INSTALACIONES` int NOT NULL,
  `NOMBRE` varchar(50) NOT NULL,
  `PAIS` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `DIRECCION` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `CAPACIDAD` int NOT NULL,
  PRIMARY KEY (`ID_INSTALACIONES`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

DROP TABLE IF EXISTS `personal`;
CREATE TABLE `personal` (
  `ID_PERSONAL` int NOT NULL,
  `NOMBRE` varchar(45) NOT NULL,
  `APELLIDOS` varchar(45) NOT NULL,
  `NIF` varchar(10) NOT NULL,
  `FECHA_NACIMIENTO` date NOT NULL,
  `TELEFONO` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `SUELDO` int NOT NULL,
  PRIMARY KEY (`ID_PERSONAL`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

DROP TABLE IF EXISTS `personal_trabaja_conciertos`;
CREATE TABLE `personal_trabaja_conciertos` (
  `PERSONAL_ID_PERSONAL` int NOT NULL,
  `CONCIERTOS_GIRA_NOMBRE` varchar(70) NOT NULL,
  `CONCIERTOS_FECHA` date NOT NULL,
  PRIMARY KEY (`PERSONAL_ID_PERSONAL`,`CONCIERTOS_GIRA_NOMBRE`,`CONCIERTOS_FECHA`),
  KEY `fk_PERSONAL_has_CONCIERTOS_CONCIERTOS2_idx` (`CONCIERTOS_GIRA_NOMBRE`,`CONCIERTOS_FECHA`),
  KEY `fk_PERSONAL_has_CONCIERTOS_PERSONAL2_idx` (`PERSONAL_ID_PERSONAL`),
  CONSTRAINT `fk_PERSONAL_has_CONCIERTOS_CONCIERTOS2` FOREIGN KEY (`CONCIERTOS_GIRA_NOMBRE`, `CONCIERTOS_FECHA`) REFERENCES `conciertos` (`GIRA_NOMBRE`, `FECHA`),
  CONSTRAINT `fk_PERSONAL_has_CONCIERTOS_PERSONAL2` FOREIGN KEY (`PERSONAL_ID_PERSONAL`) REFERENCES `personal` (`ID_PERSONAL`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;