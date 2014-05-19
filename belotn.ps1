param($length)

$ErrorActionPreference= 'silentlycontinue'

	$wl = gc wordlist.txt |? { $_.length -eq $length }
	$uwl = ($wl |? { ($_.toCharArray() | select -uniq).Count -eq $length })
	if($uwl.count -eq 0){
		$uwl = $wl |% { $_ | add-member -passthru -type noteproperty -name score -value ($_.toCharArray() | select -uniq).Count } | sort score -desc
	}
	$item1 = $uwl[(get-random -min 0 -max $uwl.count)]
	Write-host $item1
	$response1 = [console]::Readline()
	$list = ($uwl |? { $_ -notmatch "[$item1]" })
	if( $list.count -gt 0){
		$item2 = $list[0]
	}else{
		$list = $uwl|% { $_ | add-member -passthru -type noteproperty -name comm  -value $( (diff $_.toCharArray() $item1.toCharArray() -excludedifferent -includeequal).count) } | sort Comm | sort -desc Score
		$item2 = $list[0]
	}
	Write-host $item2
	$response2 = [console]::Readline()
	
	$pattern = (97..122 | foreach {[char]$_}) -join ''
	$m = @()
	for($i=0;$i -lt $length;$i++){
		$m+= $pattern
	}
	
function  Get-Patterns{
	param($m,$length,$response2, $item2)
	for($i=0;$i -lt $length;$i++){
		if( $response2[$i] -eq 'X' ){
			if( ($item2.tocharArray() |? { $_ -eq $item2[$i]} ).Count -lt 2){
				for($j = 0 ; $j -lt $length; $j++){
					if( ($m[$j]).length -gt 1 -and $m[$j].tocharArray() -contains $item2[$i]){
						$m[$j] = $m[$j].remove($m[$j].indexOf($item2[$i]),1)
					}
				}
			}
		}
		
		if( $response2[$i] -eq '?' ){
			if( $m[$i].indexOf($item2[$i]) ){
				$m[$i] = $m[$i].remove($m[$i].indexof($item2[$i]),1)
			}
		}
		
		if( $response2[$i] -eq 'O' ){
			$m[$i] = $item2[$i]
		}
	}
	return $m
}	

function get-Regex {
	param($m)
	$search = ""
	for($i=0;$i -lt $length;$i++){
		$search +="[$($m[$i])]"
	} 
	return $search
}

function Get-findletter {
	param( $length,$item1,$response1,$item2,$response2,$item3,$response3,$item4,$response4	)
	$letters=""
	for($i=0; $i -lt $length;$i++){
		if($response1[$i] -eq '?' -or $response1[$i] -eq 'O'){
			$letters="$letters$($item1[$i])"
		}
		if($response2[$i] -eq '?' -or $response2[$i] -eq 'O'){
			$letters="$letters$($item2[$i])"
		}
		if($response3[$i] -eq '?' -or $response3[$i] -eq 'O'){
			$letters="$letters$($item3[$i])"
		}
		if($response4 -and( $response4[$i] -eq '?' -or $response4[$i] -eq 'O' )){
			$letters="$letters$($item4[$i])"
		}
	}
	return ($letters.toCharArray() | select -uniq) -join ''
}

	for($i=0;$i -lt $length;$i++){
		if( $response1[$i] -eq 'X' ){
			for($j = 0 ; $j -lt $length; $j++){
				$m[$j] = $m[$j].remove($m[$j].indexOf($item1[$i]),1)
			}
		}
		if( $response1[$i] -eq '?' ){
			$m[$i] = $m[$i].remove($m[$i].indexof($item1[$i]),1)
		}
		
		if( $response1[$i] -eq 'O' ){
			$m[$i] = $item1[$i]
		}
		
		
	}
$m =get-Patterns $m $length $response2 $item2
$search = get-regex $m

	$third = $uwl |? { $_ -notmatch "[$item1$item2]" }
	
	if($third.Count -gt 0){
		if( $third.count -gt 1){
			$item3 = $third[0]
		}else{
			$item3 = $third
		}
	}else{
		$item3 = ($wl |? { $_ -match $search })[0]
	}
	Write-host $item3
	$response3 = [console]::Readline()
	$m =get-Patterns $m $length $response3 $item3
	$search = get-regex $m
	$letters = get-findletter $length $item1 $response1 $item2 $response2 $item3 $response3
	$forth = $uwl |? { $_ -notmatch "[$item1$item2$item3]" }
	$score = $false
	if( $forth.count -gt 0 -and $letters.length -lt 4){
		if($forth.count -gt 1){
			$item4 = $forth[0]
		}else{
			$item4 = $forth
		}
	}else{
		$forth = $wl |% { $_ | add-member -type noteproperty -name score -value $( (diff $_.toCharArray() $letters.toCharArray() -excludedifferent -includeequal).count) -passthru} | sort Score -desc
		$score = $true
		$tmp = ($forth |? { $_ -match $search })
		if($tmp.count -gt 1){
			$item4 = $tmp[0]
		}else{
			$item4 = $tmp
		}
	}

	Write-host $item4
	$response4 = [console]::Readline()
	
	if($response4 -ne "OOOOO"){
		$m = get-Patterns $m $length $response4 $item4
		$search = get-regex $m
		$letters = get-findletter $length $item1 $response1 $item2 $response2 $item3 $response3 $item4 $response4
		if($score){
			$last = $wl |% { 
				$_.score= $( (diff $_.toCharArray() $letters.toCharArray() -excludedifferent -includeequal).count)
				$_ 	} | sort Score -desc

		}else{
			$last = $wl |% { $_ | add-member -type noteproperty -name score -value $( (diff $_.toCharArray() $letters.toCharArray() -excludedifferent -includeequal).count) -passthru} | sort Score -desc 
		}
		$last = $last |? { $_ -match $search }
		if($last.count -gt 1){
			$item5 = $last[0]
		}else{
			$item5 = $last
		}
		Write-host $item5
	}