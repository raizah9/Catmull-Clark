[![Language](https://img.shields.io/badge/Language-French-blue.svg)](https://en.wikipedia.org/wiki/French_language)

# Catmull-Clark

Dans cette première partie du projet, l'objectif était de mettre en œuvre l'algorithme de Catmull-Clark pour la subdivision des surfaces. L'application prend en entrée un maillage polygonal initial, représenté par une liste de sommets et de faces. L'algorithme de Catmull-Clark est appliqué de manière itérative pour générer plusieurs niveaux de subdivision.

Le code commence par initialiser un parallélépipède rectangulaire en définissant ses sommets et ses faces. Lorsque l'utilisateur appuie sur la touche "c", la fonction catmullClarkSubdivision est déclenchée. Cette fonction effectue les étapes spécifiques de l'algorithme, notamment le calcul des points de face, des points d'arête, et la mise à jour des coordonnées des sommets.

Les points de face sont calculés en prenant la moyenne des coordonnées des sommets formant chaque face. Les points d'arête sont déterminés en considérant les points de face adjacents. Les coordonnées des sommets sont ensuite mises à jour en fonction des points de face, des points d'arête et des coordonnées d'origine.

Le résultat de la subdivision est affiché graphiquement, et l'utilisateur peut observer les changements dans la géométrie du maillage à mesure que la subdivision progresse. La touche "c" est utilisée comme déclencheur manuel pour effectuer chaque itération de subdivision.

Le code est structuré de manière claire, avec des fonctions auxiliaires facilitant la compréhension et la maintenance du code. L'utilisation de la bibliothèque PeasyCam permet également d'ajouter une caméra pour explorer le maillage en 3D.
