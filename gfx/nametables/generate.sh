#!/usr/bin/env bash
set -e

python nametable_builder.py break \
    enter_high_score_nametable.bak \
    characters.txt \
    --output \
    enter_high_score_nametable.py 

python nametable_builder.py break \
    game_nametable.bak \
    characters.txt \
    --output \
    game_nametable.py 

python nametable_builder.py break \
    game_type_menu_nametable.bak \
    characters.txt \
    --output \
    game_type_menu_nametable.py 

python nametable_builder.py break \
    high_scores_nametable.bak \
    characters.txt \
    --output \
    high_scores_nametable.py --skip-attrs

python nametable_builder.py break \
    legal_screen_nametable.bak \
    characters.txt \
    --output \
    legal_screen_nametable.py 

python nametable_builder.py break \
    level_menu_nametable.bak \
    characters.txt \
    --output \
    level_menu_nametable.py 

python nametable_builder.py break \
    title_screen_nametable.bak \
    characters.txt \
    --output \
    title_screen_nametable.py 

python nametable_builder.py break \
    type_a_ending_nametable.bak \
    characters_ending.txt \
    --output \
    type_a_ending_nametable.py 

python nametable_builder.py break \
    type_b_ending_nametable.bak \
    characters_ending.txt \
    --output \
    type_b_ending_nametable.py 

python nametable_builder.py break \
    type_b_lvl9_ending_nametable.bak \
    characters_ending.txt \
    --output \
    type_b_lvl9_ending_nametable.py 
