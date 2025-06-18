// CONFIGURACIÓN
rectAltura_um = 500;
nRect = 10;

getPixelSize(unit, pixelWidth, pixelHeight);
rectAltura_px = round(rectAltura_um / pixelHeight);

imgW = getWidth();
imgH = getHeight();

title = getTitle();
name = replace(title, ".tif", "");
dir = "C:/Users/Karen/OneDrive - Universidad Nacional de Colombia/Documentos/Documentos 2025-1/Pasantia/Imagenes Tanguro PlotProfile/Dac/";


roiManager("reset");

// CALCULAR EJE X COMÚN EN MICRÓMETROS
xPositions = newArray(imgW);
for (k = 0; k < imgW; k++) {
    xPositions[k] = d2s(k * pixelWidth, 2);
}

// CREAR ARCHIVO UNIFICADO
outputPath = dir + name + "_TodosPerfiles.csv";
File.saveString("ROI,Position_um,Intensity\n", outputPath);

// GENERAR Y GUARDAR LOS ROIs VÁLIDOS
for (j = 0; j < nRect; j++) {
    selectWindow(title);

    y = floor(random() * (imgH - rectAltura_px));
    makeRectangle(0, y, imgW, rectAltura_px);
    roiManager("Add");
    roiManager("Select", roiManager("Count") - 1);

    run("Measure");
    mean = getResult("Mean", nResults - 1);
    run("Clear Results");

    if (isNaN(mean) || mean < 5) {
        print("⚠️ ROI " + j + " descartado (media=" + mean + ").");
        roiManager("Delete");
    } else {
        print("✅ ROI " + j + " válido (media=" + mean + ").");
    }
}

// PROCESAR CADA ROI Y GUARDAR EN EL ARCHIVO UNIFICADO
for (i = 0; i < roiManager("Count"); i++) {
    roiManager("Select", i);
   
    profile = getProfile();
    if (profile.length == 0) {
        print("⚠️ ROI " + i + ": perfil vacío.");
        continue;
    }

    for (k = 0; k < profile.length; k++) {
        if (!isNaN(profile[k])) {
            File.append(i + "," + xPositions[k] + "," + profile[k] + "\n", outputPath);
        }
    }

    print("✅ Perfil " + i + " guardado.");
}

print(" Proceso completo. Todos los perfiles se guardaron en:\n" + outputPath);
