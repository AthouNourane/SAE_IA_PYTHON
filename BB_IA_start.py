import BB_modele
from typing import Literal
import importlib
import os
import sys
from tkiteasy import ouvrirFenetre

def charger_IAs(noms_des_joueurs : list[str], game : BB_modele.Game):
    """Charge les objets IA contenus dans les fichiers (noms des joueurs) donnés
    
    Args:
        player_names ([str]): noms des joueurs
    Returns:
        list : liste des objet IAs par chaque indice de joueur
    """

    list_ia = []

    for i in range(len(noms_des_joueurs)):
        imp = importlib.import_module("IA." + noms_des_joueurs[i])
        list_ia.append(imp.IA_Bomber(i, game.to_dict(), game.timerglobal, game.timerfantôme ) )

    return list_ia
        

def partie(noms_des_joueurs : list[str], scenario : str):
    """
    Simule une partie du jeu BomberBUT

    Args:
        joueurs ([str]) : liste contenant les noms des joueurs i.e. les noms des fichiers contenant les IA
            (on peut mettre plusieurs fois le même nom)
        scenario : nom du fichier contenant la map de départ
    Returns:
        historique (str) : historique complet de la partie
        scores (list) : liste des scores des joueurs en fin de partie
    """

    game = BB_modele.charger_scenario(scenario)
    nb_joueurs = len(noms_des_joueurs)
    assert nb_joueurs == len(game.bombers)
    IAs = charger_IAs(noms_des_joueurs, game)
    
    # Garder trace des PV précédents pour détecter qui a tué qui
    pv_precedents = [bomber.pv for bomber in game.bombers]
    derniere_bombe = [None] * nb_joueurs  # Pour tracker qui a posé la dernière bombe
    
    print("=== Début de la partie ===")
    for i, bomber in enumerate(game.bombers):
        print(f"Joueur {i+1} ({noms_des_joueurs[i]}) commence à la position {bomber.position}")
    
    game_over = False
    
    while not game_over:
        game.log("début_tour " + str(game.compteur_tour))        
        print(f"\n=== Tour {game.compteur_tour} ===")
        
        #phase joueurs
        for j in range(nb_joueurs):
            if game.bombers[j].pv > 0:
                original_stdout = sys.stdout
                # sys.stdout = open(os.devnull, 'w')
                action = IAs[j].action(game.to_dict())
                # sys.stdout = original_stdout
                
                position_actuelle = game.bombers[j].position
                print(f"Joueur {j+1} ({noms_des_joueurs[j]}) en position {position_actuelle} effectue l'action: {action}")
                
                game.résoudre_action(j,action)
                
                if action == 'X':
                    derniere_bombe[j] = position_actuelle
                    print(f"⚠️ Joueur {j+1} pose une bombe à la position {position_actuelle}")

        #phase non joueur
        game.phase_non_joueur()
        
        # Vérifier les éliminations et identifier qui a tué qui
        for j in range(nb_joueurs):
            if pv_precedents[j] > 0 and game.bombers[j].pv <= 0:
                tueur = None
                # Chercher qui a posé la dernière bombe qui a pu tuer le joueur
                for k in range(nb_joueurs):
                    if derniere_bombe[k] is not None:
                        # Utiliser les attributs x et y de l'objet Position
                        dist_x = abs(derniere_bombe[k].x - game.bombers[j].position.x)
                        dist_y = abs(derniere_bombe[k].y - game.bombers[j].position.y)
                        if dist_x <= 3 or dist_y <= 3:  # Distance approximative de l'explosion
                            tueur = k
                            break
                
                if tueur is not None:
                    print(f"💀 Joueur {j+1} ({noms_des_joueurs[j]}) a été éliminé par Joueur {tueur+1} ({noms_des_joueurs[tueur]})!")
                else:
                    print(f"💀 Joueur {j+1} ({noms_des_joueurs[j]}) a été éliminé par un fantôme!")
        
        # Mettre à jour les PV précédents
        pv_precedents = [bomber.pv for bomber in game.bombers]


        #
        carte = game.carte
        text = {
            "M": "gray",
            "C": "red",
            "P": "blue",
            "B": "green"
        }
        if carte is not None:
            for y in range(len(carte)):
                for x in range(len(carte[y])):
                    if carte[y][x] in text:
                        g.dessinerRectangle(SIZE * x, SIZE * y, SIZE, SIZE, text[carte[y][x]])
            for i in game.bombers:
                g.dessinerRectangle(i.position.x*SIZE, i.position.y*SIZE, SIZE, SIZE, "yellow")
            for i in game.bombes:
                g.dessinerRectangle(i.position.x*SIZE, i.position.y*SIZE, SIZE, SIZE, "green")
            for i in game.fantômes:
                g.dessinerRectangle(i.position.x*SIZE, i.position.y*SIZE, SIZE, SIZE, "white")
        #g.pause(0.1)
        g.actualiser()
        g.supprimer("all")
        #

        #test game over
        game_over = game.is_game_over() 
    
    print("\n=== Fin de la partie ===")
    print("Scores finaux:")
    for j in range(nb_joueurs):
        print(f"Joueur {j+1} ({noms_des_joueurs[j]}): {game.scores[j]} points et il vous reste {bomber.pv} pv.")

    
    game.log("game_over")
    game.log(f"scores {game.scores}")




if __name__ == '__main__':
    g = ouvrirFenetre(700, 700)
    SIZE = 25
    #partie(['IA_ATHOUMANI_LEMETEYER'], "maps/training2.txt")
    # Test sur battle0.txt (4 joueurs)
    partie(['IA_ATHOUMANI_LEMETEYER','IA_ATHOUMANI_LEMETEYER','IA_ATHOUMANI_LEMETEYER','IA_ATHOUMANI_LEMETEYER'], "maps/battle0.txt")
    
    # Test sur battle1.txt (4 joueurs)
    #partie(['IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER'], "maps/battle1.txt")

    # Test sur battle2.txt (16 joueurs)
    """partie(['IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER', 
            'IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER', 
            'IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER', 
            'IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER', 'IA_ATHOUMANI_LEMETEYER'], "maps/battle2.txt")"""
    


    