import controlP5.*;
import peasy.*;

int numIterations = 2; // Ajustez le nombre d'itérations selon les besoins
ArrayList<PVector> vertices;
ArrayList<int[]> faces;

void setup() {
  size(800, 800, P3D);
  PeasyCam cam = new PeasyCam(this, 500);
  initializeMesh(); // Initialise le maillage initial
}

void draw() {
  background(0);
  stroke(0);
  fill(150, 150, 255);
  drawMesh(); // Dessine le maillage
}

void initializeMesh() {
  // Initialise les sommets et les faces d'un parallélépipède
  vertices = new ArrayList<>();
  faces = new ArrayList<>();
  
  float w = 200;  // Largeur du parallélépipède
  float h = 350;  // Hauteur du parallélépipède
  float d = 120;   // Profondeur du parallélépipède
  
  // Sommets
  vertices.add(new PVector(-w/2, -h/2, -d/2));
  vertices.add(new PVector(w/2, -h/2, -d/2));
  vertices.add(new PVector(w/2, h/2, -d/2));
  vertices.add(new PVector(-w/2, h/2, -d/2));
  vertices.add(new PVector(-w/2, -h/2, d/2));
  vertices.add(new PVector(w/2, -h/2, d/2));
  vertices.add(new PVector(w/2, h/2, d/2));
  vertices.add(new PVector(-w/2, h/2, d/2));

  // Faces
  // Avant
  faces.add(new int[]{0, 1, 2, 3});
  // Arrière
  faces.add(new int[]{4, 5, 6, 7});
  // Côtés
  faces.add(new int[]{0, 3, 7, 4});
  faces.add(new int[]{1, 2, 6, 5});
  faces.add(new int[]{3, 2, 6, 7});
  faces.add(new int[]{0, 1, 5, 4});
}

void drawMesh() {
  fill(255, 0, 0);
  beginShape(QUADS);
  for (int[] face : faces) {
    for (int vertexIndex : face) {
      PVector v = vertices.get(vertexIndex);
      vertex(v.x, v.y, v.z);
    }
  }
  endShape();
}

void keyPressed() {
  // Vérifie si la touche "c" est enfoncée
  if (key == 'c' || key == 'C') {
    // Appelle la fonction CatmullClark pour effectuer la subdivision
    catmullClarkSubdivision();
  }
}

void catmullClarkSubdivision() {
  ArrayList<PVector> newVertices = new ArrayList<>();
  ArrayList<int[]> newFaces = new ArrayList<>();

  // Étape 1 : Calculer les points de face
  ArrayList<PVector> facePoints = calculate_face_points(vertices, faces);

  // Étape 2 : Calculer les points d'arête
  HashMap<String, PVector> edgePoints = calculate_edge_points(vertices, faces, facePoints);

  // Étape 3 : Mettre à jour les coordonnées des sommets
  for (int i = 0; i < vertices.size(); i++) {
    PVector oldCoords = vertices.get(i);
    ArrayList<PVector> avgFacePoints = getAdjacentFacePoints(i, faces, facePoints);
    ArrayList<PVector> avgMidEdges = getAdjacentEdgeMidpoints(i, vertices, faces, edgePoints);

    int n = avgFacePoints.size();
    float m1 = (n - 3.0) / n;
    float m2 = 1.0 / n;
    float m3 = 2.0 / n;

    PVector newCoords = new PVector();
    newCoords.add(PVector.mult(oldCoords, m1));
    PVector avg = new PVector();
    for (PVector avgFacePoint : avgFacePoints) {
      avg.add(avgFacePoint);
    }
    avg.div(n);
    newCoords.add(PVector.mult(avg, m2));
    avg = new PVector();
    for (PVector avgMidEdge : avgMidEdges) {
      avg.add(avgMidEdge);
    }
    avg.div(n);
    newCoords.add(PVector.mult(avg, m3));
    newVertices.add(newCoords);
  }
  
  // Ajouter les points de face et les points d'arête aux nouveaux sommets
  newVertices.addAll(facePoints);
  for (PVector edgePoint : edgePoints.values()) {
    newVertices.add(edgePoint);
  }
  
  // Étape 4 : Générer de nouvelles faces
  for (int[] face : faces) {
    int a = face[0];
    int b = face[1];
    int c = face[2];
    int d = face.length == 4 ? face[3] : -1; // Vérifier s'il s'agit d'un quadrilatère ou d'un triangle

    int edgePointAB = getEdgePointIndex(a, b, edgePoints,newVertices);
    int edgePointBC = getEdgePointIndex(b, c, edgePoints,newVertices);
    int edgePointCD = getEdgePointIndex(c, d, edgePoints,newVertices);
    int edgePointDA = getEdgePointIndex(d, a, edgePoints,newVertices);

    int facePointIndex = getFacePointIndex(facePoints, face,newVertices);

    // Créer de nouvelles faces
    int[] newFace1 = {a, edgePointAB, facePointIndex, edgePointDA};
    int[] newFace2 = {b, edgePointBC, facePointIndex, edgePointAB};
    int[] newFace3 = {c, edgePointCD, facePointIndex, edgePointBC};
    int[] newFace4 = {d, edgePointDA, facePointIndex, edgePointCD};

    newFaces.add(newFace1);
    newFaces.add(newFace2);
    newFaces.add(newFace3);

    if (d != -1) {
      newFaces.add(newFace4);
    }
  }

  // Mettre à jour le maillage avec les nouveaux sommets et faces
  vertices = newVertices;
  faces = newFaces;
}
// Fonction pour obtenir les points de face adjacents à un sommet
ArrayList<PVector> getAdjacentFacePoints(int vertexIndex, ArrayList<int[]> faces, ArrayList<PVector> facePoints) {
  ArrayList<PVector> adjacentFacePoints = new ArrayList<>();
  for (int[] face : faces) {
    for (int faceVertex : face) {
      if (faceVertex == vertexIndex) {
        adjacentFacePoints.add(facePoints.get(faces.indexOf(face)));
        break;
      }
    }
  }
  return adjacentFacePoints;
}

// Fonction pour obtenir les points de milieu d'arête adjacents à un sommet
ArrayList<PVector> getAdjacentEdgeMidpoints(int vertexIndex, ArrayList<PVector> vertices, ArrayList<int[]> faces, HashMap<String, PVector> edgePoints) {
  ArrayList<PVector> adjacentEdgeMidpoints = new ArrayList<>();
  PVector vertex = vertices.get(vertexIndex);

  for (int[] face : faces) {
    for (int i = 0; i < face.length; i++) {
      int nextIndex = (i + 1) % face.length;
      int edgeStart = face[i];
      int edgeEnd = face[nextIndex];

      if ((edgeStart == vertexIndex || edgeEnd == vertexIndex) && edgeStart != edgeEnd) {
        String edgeKey = getEdgeKey(edgeStart, edgeEnd);
        PVector edgeMidpoint = edgePoints.get(edgeKey);
        adjacentEdgeMidpoints.add(edgeMidpoint);
        break;
      }
    }
  }

  return adjacentEdgeMidpoints;
}

int getFacePointIndex(ArrayList<PVector> facePoints, int[] face, ArrayList<PVector> newVertices) {
  PVector avgFacePoint = new PVector();
  for (int vertexIndex : face) {
    avgFacePoint.add(vertices.get(vertexIndex));
  }
  avgFacePoint.div(face.length);
  
  int existingIndex = newVertices.indexOf(avgFacePoint);
  if (existingIndex == -1) {
    newVertices.add(avgFacePoint);
    return newVertices.size() - 1;
  } else {
    return existingIndex;
  }
}

// Fonction pour obtenir l'indice du point de milieu d'arête lors de la subdivision
int getEdgePointIndex(int start, int end, HashMap<String, PVector> edgePoints, ArrayList<PVector> newVertices) {
  String edgeKey = getEdgeKey(start, end);
  PVector edgeMidpoint = edgePoints.get(edgeKey);
  
  if (edgeMidpoint == null) {
    edgeMidpoint = new PVector((vertices.get(start).x + vertices.get(end).x) / 2,
                               (vertices.get(start).y + vertices.get(end).y) / 2,
                               (vertices.get(start).z + vertices.get(end).z) / 2);
    edgePoints.put(edgeKey, edgeMidpoint);
  }

  int edgePointIndex = newVertices.indexOf(edgeMidpoint);
  if (edgePointIndex == -1) {
    newVertices.add(edgeMidpoint);
    return newVertices.size() - 1;
  } else {
    return edgePointIndex;
  }
}

// Fonction pour obtenir la clé d'une arête
String getEdgeKey(int start, int end) {
  return start < end ? start + "-" + end : end + "-" + start;
}
// Fonction pour calculer les points de face lors de la subdivision
ArrayList<PVector> calculate_face_points(ArrayList<PVector> vertices, ArrayList<int[]> faces) {
  ArrayList<PVector> facePoints = new ArrayList<>();
  for (int[] face : faces) {
    PVector avgPoint = new PVector();
    for (int vertexIndex : face) {
      avgPoint.add(vertices.get(vertexIndex));
    }
    avgPoint.div(face.length);
    facePoints.add(avgPoint);
  }
  return facePoints;
}

// Fonction pour calculer les points de milieu d'arête lors de la subdivision
HashMap<String, PVector> calculate_edge_points(ArrayList<PVector> vertices, ArrayList<int[]> faces, ArrayList<PVector> facePoints) {
  HashMap<String, PVector> edgePoints = new HashMap<>();
  for (int[] face : faces) {
    for (int i = 0; i < face.length; i++) {
      int nextIndex = (i + 1) % face.length;
      int edgeStart = face[i];
      int edgeEnd = face[nextIndex];

      PVector facePointStart = facePoints.get(faces.indexOf(face));
      PVector facePointEnd = facePoints.get(faces.indexOf(getAdjacentFace(face, vertices, faces, edgeStart, edgeEnd)));

      PVector edgePoint = new PVector();
      edgePoint.add(vertices.get(edgeStart));
      edgePoint.add(vertices.get(edgeEnd));
      edgePoint.add(facePointStart);
      edgePoint.add(facePointEnd);
      edgePoint.div(4.0);

      String edgeKey = getEdgeKey(edgeStart, edgeEnd);
      edgePoints.put(edgeKey, edgePoint);
    }
  }
  return edgePoints;
}

// Fonction pour obtenir la face adjacente à une arête
int[] getAdjacentFace(int[] face, ArrayList<PVector> vertices, ArrayList<int[]> faces, int edgeStart, int edgeEnd) {
  for (int[] adjacentFace : faces) {
    if (adjacentFace != face && hasEdge(adjacentFace, edgeStart, edgeEnd)) {
      return adjacentFace;
    }
  }
  return null;
}

// Fonction pour vérifier si une arête est présente dans une face
boolean hasEdge(int[] face, int edgeStart, int edgeEnd) {
  for (int i = 0; i < face.length; i++) {
    int nextIndex = (i + 1) % face.length;
    if ((face[i] == edgeStart && face[nextIndex] == edgeEnd) ||
        (face[i] == edgeEnd && face[nextIndex] == edgeStart)) {
      return true;
    }
  }
  return false;
}
