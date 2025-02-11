# Obtenir le chemin du répertoire du script
$scriptPath = $PSScriptRoot

# Récupérer le contenu du fichier ListeAExtraire.txt
$content = Get-Content -Raw -Path "$scriptPath\ListeAExtraire.txt"

# Définir le synoptique (en exemple ici)
$text = "50_30_06"

# Date d'aujourd'hui
$date = Get-Date -Format "yyMMdd"

# Création du dossier et du fichier de sortie
New-Item "$scriptPath\$date" -Type Directory -Force | Out-Null
$OutFile = "$scriptPath\$date\Resulat_synotique.sql"

# Base de données
$bd = "HTTIF_MSCRM"

# Diviser le contenu en sections "INSERT ... GO"
$sections = $content -split "(?=INSERT)"

# Filtrer les sections contenant le synoptique spécifié
$matchingSections = $sections | Where-Object { $_ -match $text }

# Vérifier si des sections ont été trouvées
if ($matchingSections) {
    Write-Output "Pour le synoptique $text"
    
    # Trouver l'ID dans les sections correspondantes
    $id = find-id -matchingSections $matchingSections

    if ($id) {
        # Construire la requête SQL avec l'ID récupéré
        $sqlQuery = "USE [$bd];`nDELETE FROM [dbo].[gs2e_synoptiquedeprocessusBase] WHERE gs2e_synoptiquedeprocessusId = N'$id';"
        # Ajouter le résultat dans le fichier
        Add-Content -Path $OutFile -Value "
        *************************************************
        Script de suppression de l'ancien synoptique
        *************************************************
        $sqlQuery
        "
    }
    else {
        Add-Content -Path $OutFile -Value "******Aucun ID n'a été trouvé, donc la requête SQL n'est pas générée.******"
        Write-Output "Aucun ID n'a été trouvé, donc la requête SQL n'est pas générée."
    }

    # Modifier le script (si nécessaire)
    $modifiedSqlQuery = mod_script -matchingSections $matchingSections
    Write-Output "ICI $modifiedSqlQuery"
    if ($modifiedSqlQuery) {
        Add-Content -Path $OutFile -Value "
        *************************************************
        Script de modification de l'ancien synoptique
        *************************************************
        $modifiedSqlQuery
        "
    }

} else {
    Write-Output "Aucune section correspondante n'a été trouvée."
}
# Obtenir le chemin du répertoire du script
$scriptPath = $PSScriptRoot

# Récupérer le contenu du fichier ListeAExtraire.txt
$content = Get-Content -Raw -Path "$scriptPath\ListeAExtraire.txt"

# Définir le synoptique (en exemple ici)
$text = "50_30_06"

# Date d'aujourd'hui
$date = Get-Date -Format "yyMMdd"

# Création du dossier et du fichier de sortie
New-Item "$scriptPath\$date" -Type Directory -Force | Out-Null
$OutFile = "$scriptPath\$date\Resulat_synotique.sql"

# Base de données
$bd = "HTTIF_MSCRM"

# Diviser le contenu en sections "INSERT ... GO"
$sections = $content -split "(?=INSERT)"

# Filtrer les sections contenant le synoptique spécifié
$matchingSections = $sections | Where-Object { $_ -match $text }

# Vérifier si des sections ont été trouvées
if ($matchingSections) {
    Write-Output "Pour le synoptique $text"
    
    # Trouver l'ID dans les sections correspondantes
    $id = find-id -matchingSections $matchingSections

    if ($id) {
        # Construire la requête SQL avec l'ID récupéré
        $sqlQuery = "USE [$bd];`nDELETE FROM [dbo].[gs2e_synoptiquedeprocessusBase] WHERE gs2e_synoptiquedeprocessusId = N'$id';"
        # Ajouter le résultat dans le fichier
        Add-Content -Path $OutFile -Value "
        *************************************************
        Script de suppression de l'ancien synoptique
        *************************************************
        $sqlQuery
        "
    }
    else {
        Add-Content -Path $OutFile -Value "******Aucun ID n'a été trouvé, donc la requête SQL n'est pas générée.******"
        Write-Output "Aucun ID n'a été trouvé, donc la requête SQL n'est pas générée."
    }

    # Modifier le script (si nécessaire)
    $modifiedSqlQuery = mod_script -matchingSections $matchingSections
    Write-Output "ICI $modifiedSqlQuery"
    if ($modifiedSqlQuery) {
        Add-Content -Path $OutFile -Value "
        *************************************************
        Script de modification de l'ancien synoptique
        *************************************************
        $modifiedSqlQuery
        "
    }

} else {
    Write-Output "Aucune section correspondante n'a été trouvée."
}

# Fonction pour trouver l'ID dans les sections
function find-id {
    param (
        [string[]]$matchingSections
    )
    
    # Définir le pattern pour extraire l'ID
    $pattern = "VALUES\s*\(.*?N'([0-9a-f-]+)'.*?\)"
    
    # Initialiser une variable pour l'ID trouvé
    $id = $null

    # Parcourir chaque section et chercher l'ID
    foreach ($section in $matchingSections) {
        if ($section -match $pattern) {
            $id = $matches[1]
            break # Si un ID est trouvé, sortir de la boucle
        }
    }

    return $id
}

# Fonction pour modifier le script avec la nouvelle valeur
# Fonction pour modifier le script avec la nouvelle valeur
function mod_script {
    param (
        [string[]]$matchingSections
    )

    # Définir le pattern pour capturer la 8ème valeur après VALUES
    $pattern = "VALUES\s*\((?:N'[^']+',\s*){7}N'([^']+)'" 

    # Initialiser une variable pour la requête modifiée
    $modifiedSqlQuery = $null

    # Affichage pour déboguer (on va voir les sections analysées)
    Write-Output "Sections à analyser :"
    foreach ($section in $matchingSections) {
        Write-Output $section
    }

    # Parcourir chaque section et appliquer la modification
    foreach ($section in $matchingSections) {
        if ($matchingSections -match $pattern) {
            $extractedValue = $matches[1]
            Write-Output "Valeur extraite : $extractedValue"

            # Modifier la requête
            $modifiedSqlQuery = $section -replace "N'$extractedValue'", "(SELECT o.OrganizationId FROM [dbo].[OrganizationBase] o (NOLOCK))"

            # Affichage pour déboguer (on va voir la requête modifiée)
            Write-Output "Requête modifiée : $modifiedSqlQuery"

            # Retourner la requête modifiée
            return $modifiedSqlQuery  # Retourne explicitement la requête modifiée
        } else {
            Write-Output "Aucune correspondance pour le pattern dans cette section."
        }
    }

    # Si aucune modification n'a eu lieu, retourne null
    Write-Output "Aucune section modifiée."
    return $null
}


# Fonction pour trouver l'ID dans les sections
function find-id {
    param (
        [string[]]$matchingSections
    )
    
    # Définir le pattern pour extraire l'ID
    $pattern = "VALUES\s*\(.*?N'([0-9a-f-]+)'.*?\)"
    
    # Initialiser une variable pour l'ID trouvé
    $id = $null

    # Parcourir chaque section et chercher l'ID
    foreach ($section in $matchingSections) {
        if ($section -match $pattern) {
            $id = $matches[1]
            break # Si un ID est trouvé, sortir de la boucle
        }
    }

    return $id
}

# Fonction pour modifier le script avec la nouvelle valeur
# function mod_script {
#     param (
#         [string[]]$matchingSections
#     )

#     # Définir le pattern pour capturer la 8ème valeur après VALUES
#     $pattern = "VALUES\s*\((?:N'[^']+',\s*){7}N'([^']+)'" 

#     # Initialiser une variable pour la requête modifiée
#     $modifiedSqlQuery = $null

#     # Parcourir chaque section et appliquer la modification
#     foreach ($section in $matchingSections) {
#         if ($section -match $pattern) {
#             $extractedValue = $matches[1]
#             # Modifier la requête
#             $modifiedSqlQuery = $section -replace "N'$extractedValue'", "(SELECT o.OrganizationId FROM [dbo].[OrganizationBase] o (NOLOCK))"
#             # Retourner la requête modifiée
#             return $modifiedSqlQuery
#         }
#     }

#     return "True"
# }
   

