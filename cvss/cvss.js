

var CVSS31 = {};
CVSS31.CVSSVersionIdentifier = "CVSS:3.1";
CVSS31.exploitabilityCoefficient = 8.22;
CVSS31.scopeCoefficient = 1.08;
CVSS31.vectorStringRegex_31 = /^CVSS:3\.1\/AV:[NALP]|AC:[LH]|PR:[UNLH]|UI:[NR]|S:[UC]|[CIA]$/;
CVSS31.Weight = {
    AV: { N: 0.85, A: 0.62, L: 0.55, P: 0.2 },
    AC: { H: 0.44, L: 0.77 },
    PR: {
        U: { N: 0.85, L: 0.62, H: 0.27 },
        C: { N: 0.85, L: 0.68, H: 0.5 }
    },
    UI: { N: 0.85, R: 0.62 },
    S: { U: 6.42, C: 7.52 },
    CIA: { N: 0, L: 0.22, H: 0.56 }
};

CVSS31.severityRatings = [
    { name: "None", bottom: 0.0, top: 0.0 },
    { name: "Low", bottom: 0.1, top: 3.9 },
    { name: "Medium", bottom: 4.0, top: 6.9 },
    { name: "High", bottom: 7.0, top: 8.9 },
    { name: "Critical", bottom: 9.0, top: 10.0 }
];

CVSS31.calculateCVSSFromMetrics = function (AttackVector, AttackComplexity, PrivilegesRequired, UserInteraction, Scope, Confidentiality, Integrity, Availability) {
    var badMetrics = [];
    if (typeof AttackVector === "undefined" || AttackVector === "") {
        badMetrics.push("AV")
    }
    if (typeof AttackComplexity === "undefined" || AttackComplexity === "") {
        badMetrics.push("AC")
    }
    if (typeof PrivilegesRequired === "undefined" || PrivilegesRequired === "") {
        badMetrics.push("PR")
    }
    if (typeof UserInteraction === "undefined" || UserInteraction === "") {
        badMetrics.push("UI")
    }
    if (typeof Scope === "undefined" || Scope === "") {
        badMetrics.push("S")
    }
    if (typeof Confidentiality === "undefined" || Confidentiality === "") {
        badMetrics.push("C")
    }
    if (typeof Integrity === "undefined" || Integrity === "") {
        badMetrics.push("I")
    }
    if (typeof Availability === "undefined" || Availability === "") {
        badMetrics.push("A")
    }
    if (badMetrics.length > 0) {
        return {
            success: !1, errorType: "MissingBaseMetric", errorMetrics: badMetrics
        }
    }

    var AV = AttackVector;
    var AC = AttackComplexity;
    var PR = PrivilegesRequired;
    var UI = UserInteraction;
    var S = Scope;
    var C = Confidentiality;
    var I = Integrity;
    var A = Availability;

    if (!CVSS31.Weight.AV.hasOwnProperty(AV)) {
        badMetrics.push("AV")
    }
    if (!CVSS31.Weight.AC.hasOwnProperty(AC)) {
        badMetrics.push("AC")
    }
    if (!CVSS31.Weight.PR.U.hasOwnProperty(PR)) {
        badMetrics.push("PR")
    }
    if (!CVSS31.Weight.UI.hasOwnProperty(UI)) {
        badMetrics.push("UI")
    }
    if (!CVSS31.Weight.S.hasOwnProperty(S)) {
        badMetrics.push("S")
    }
    if (!CVSS31.Weight.CIA.hasOwnProperty(C)) {
        badMetrics.push("C")
    }
    if (!CVSS31.Weight.CIA.hasOwnProperty(I)) {
        badMetrics.push("I")
    }
    if (!CVSS31.Weight.CIA.hasOwnProperty(A)) {
        badMetrics.push("A")
    }
    if (badMetrics.length > 0) {
        return { success: !1, errorType: "UnknownMetricValue", errorMetrics: badMetrics }
    }
    var metricWeightAV = CVSS31.Weight.AV[AV];
    var metricWeightAC = CVSS31.Weight.AC[AC];
    var metricWeightPR = CVSS31.Weight.PR[S][PR];
    var metricWeightUI = CVSS31.Weight.UI[UI];
    var metricWeightS = CVSS31.Weight.S[S];
    var metricWeightC = CVSS31.Weight.CIA[C];
    var metricWeightI = CVSS31.Weight.CIA[I];
    var metricWeightA = CVSS31.Weight.CIA[A];
    var iss;
    var impact;
    var exploitability;
    var baseScore;
    iss = (1 - ((1 - metricWeightC) * (1 - metricWeightI) * (1 - metricWeightA)));
    if (S === 'U') {
        impact = metricWeightS * iss
    } else {
        impact = metricWeightS * (iss - 0.029) - 3.25 * Math.pow(iss - 0.02, 15)
    }
    exploitability = CVSS31.exploitabilityCoefficient * metricWeightAV * metricWeightAC * metricWeightPR * metricWeightUI;
    if (impact <= 0) {
        baseScore = 0
    } else {
        if (S === 'U') {
            baseScore = CVSS31.roundUp1(Math.min((exploitability + impact), 10))
        } else {
            baseScore = CVSS31.roundUp1(Math.min(CVSS31.scopeCoefficient * (exploitability + impact), 10))
        }
    }

    var vectorString = CVSS31.CVSSVersionIdentifier + "/AV:" + AV + "/AC:" + AC + "/PR:" + PR + "/UI:" + UI + "/S:" + S + "/C:" + C + "/I:" + I + "/A:" + A;
    return {
        success: !0, baseMetricScore: baseScore.toFixed(1),
        baseSeverity: CVSS31.severityRating(baseScore.toFixed(1)),
        baseISS: iss,
        baseImpact: impact,
        baseExploitability: exploitability,
        vectorString: vectorString
    }
};

CVSS31.calculateCVSSFromVector = function (vectorString) {
    var metricValues = {
        AV: undefined,
        AC: undefined,
        PR: undefined,
        UI: undefined,
        S: undefined,
        C: undefined,
        I: undefined,
        A: undefined
    };
    var badMetrics = [];
    if (!CVSS31.vectorStringRegex_31.test(vectorString)) {
        return { success: !1, errorType: "MalformedVectorString" }
    }
    var metricNameValue = vectorString.substring(CVSS31.CVSSVersionIdentifier.length).split("/");
    for (var i in metricNameValue) {
        if (metricNameValue.hasOwnProperty(i)) {
            var singleMetric = metricNameValue[i].split(":");
            if (typeof metricValues[singleMetric[0]] === "undefined") {
                metricValues[singleMetric[0]] = singleMetric[1]
            } else {
                badMetrics.push(singleMetric[0])
            }
        }
    }

    if (badMetrics.length > 0) {
        return {
            success: !1, errorType: "MultipleDefinitionsOfMetric", errorMetrics: badMetrics
        }
    }
    return CVSS31.calculateCVSSFromMetrics(
        metricValues.AV,
        metricValues.AC,
        metricValues.PR,
        metricValues.UI,
        metricValues.S,
        metricValues.C,
        metricValues.I,
        metricValues.A)
};

CVSS31.roundUp1 = function Roundup(input) {
    var int_input = Math.round(input * 100000);
    if (int_input % 10000 === 0) {
        return int_input / 100000
    } else {
        return (Math.floor(int_input / 10000) + 1) / 10
    }
};

CVSS31.severityRating = function (score) {
    var severityRatingLength = CVSS31.severityRatings.length;
    var validatedScore = Number(score);
    if (isNaN(validatedScore)) {
        return validatedScore
    }
    for (var i = 0; i < severityRatingLength; i++) {
        if (score >= CVSS31.severityRatings[i].bottom && score <= CVSS31.severityRatings[i].top) {
            return CVSS31.severityRatings[i].name
        }
    }
    return undefined
};

function updateScores() {
    var result = CVSS31.calculateCVSSFromMetrics(
        inputValue('input[type="radio"][name=AV]:checked'),
        inputValue('input[type="radio"][name=AC]:checked'),
        inputValue('input[type="radio"][name=PR]:checked'),
        inputValue('input[type="radio"][name=UI]:checked'),
        inputValue('input[type="radio"][name=S]:checked'),
        inputValue('input[type="radio"][name=C]:checked'),
        inputValue('input[type="radio"][name=I]:checked'),
        inputValue('input[type="radio"][name=A]:checked'));
    if (result.success === !0) {
        var L = document.querySelectorAll(".needBaseMetrics"), i = L.length;
        while (i--) {
            hide(L[i])
        }
        parentNode(text("#baseMetricScore", result.baseMetricScore),
            '.scoreRating').className = 'scoreRating ' + result.baseSeverity.toLowerCase();
        document.getElementById("cvssvector").value = result.vectorString;
        document.getElementById("generate").disabled = false;
        window.location.hash=result.vectorString
        //validateCVSS31();
    } else if (result.error === "Not all base metrics were given - cannot calculate scores.") {
        var L = document.querySelectorAll(".needBaseMetrics"), i = L.length;
        while (i--) {
            show(L[i])
        }
        hide("#vectorString")
    }
}

window.Element && function (ElementPrototype) {
    ElementPrototype.matchesSelector = ElementPrototype.matchesSelector ||
        ElementPrototype.mozMatchesSelector ||
        ElementPrototype.msMatchesSelector ||
        ElementPrototype.oMatchesSelector ||
        ElementPrototype.webkitMatchesSelector ||
        function (selector) {
            var node = this, nodes = (node.parentNode || node.document).querySelectorAll(selector), i = -1;
            while (nodes[++i] && nodes[i] != node);
            return !!nodes[i]
        }
}(Element.prototype);

var matchesSelector = function (node, selector) {
    if (!('parentNode' in node) || !node.parentNode) return !1;
    return Array.prototype.indexOf.call(node.parentNode.querySelectorAll(selector)) != -1
};

function node() {
    for (var i = 0; i < arguments.length; i++) {
        var o = arguments[i];
        if (typeof (o) == 'string' && o) return document.querySelector(o);
        else if ('nodeName' in o) return o;
        else if ('jquery' in o) return o.get(0)
    }
    return !1
}
function parentNode(p, q) {
    if (!p || !(p = node(p))) return;
    else if ((typeof (q) == 'string' && p.matchesSelector(q)) || p == q) return p;
    else if (p.nodeName.toLowerCase() != 'html') return parentNode(p.parentNode, q);
    else return
}

function text(q, s) {
    var e = node(q); if (!e) return; if (arguments.length > 1) {
        if ('textContent' in e) { e.textContent = s } else { e.innerText = s }
        return e
    }
    return e.textContent || e.innerText
}

function hide(q) {
    var e = node(q);
    if (!e) return; e.setAttribute('style', 'display:none');
    return e
}

function show(q) {
    var e = node(q); if (!e) return;
    e.setAttribute('style', 'display:inline-block');
    return e
}

function inputValue(q, v) {
    var e = document.querySelector(q);
    if (!e || e.nodeName.toLowerCase() != 'input') return;
    if (arguments.length > 1) {
        e.value = v; return e
    }
    return e.value
}

function setMetricsFromVector(vectorString) {
    var result = !0;
    var urlMetric;
    var metricValuesToSet = {
        AV: undefined,
        AC: undefined,
        PR: undefined,
        UI: undefined,
        S: undefined,
        C: undefined,
        I: undefined,
        A: undefined
    }
    var vectorStringRegex_31 = /^CVSS:3.1\/AV:[NALP]|AC:[LH]|PR:[UNLH]|UI:[NR]|S:[UC]|[CIA]:[NLH]$/;
    if (vectorStringRegex_31.test(vectorString)) {
        var urlMetrics = vectorString.substring("CVSS:3.1/".length).split("/");
        for (var p in urlMetrics) {
            var urlMetric = urlMetrics[p].split(":"); metricValuesToSet[urlMetric[0]] = urlMetric[1]
        }
        if (metricValuesToSet.AV !== undefined &&
            metricValuesToSet.AC !== undefined &&
            metricValuesToSet.PR !== undefined &&
            metricValuesToSet.UI !== undefined &&
            metricValuesToSet.S !== undefined &&
            metricValuesToSet.C !== undefined &&
            metricValuesToSet.I !== undefined &&
            metricValuesToSet.A !== undefined) {
            for (var p in metricValuesToSet) {
                document.getElementById(p + "_" + metricValuesToSet[p]).checked = !0
            }
        } else {
            result = "NotAllBaseMetricsProvided"
        }
    } else {
        result = "MalformedVectorString"
    }
    updateScores();
    return result
}

var CVSSVectorInURL; 
function urlhash() { 
    var h = window.location.hash; 
    CVSSVectorInURL = h; 
    setMetricsFromVector(h.substring(1)) 
}
function inputSelect() { 
    this.setSelectionRange(0, this.value.length) 
}
function cvssLoad() {
    urlhash(); 
    if (("onhashchange" in window)) { 
        window.onhashchange = urlhash 
    }
}

///////////////////////////////////////////////////////////////////

var cvss_table = {
    'AV': {
        'N': { 'value': 'Network', 'desc': 'The vulnerable component is bound to the network stack and the set of possible attackers extends beyond the other options listed below, up to and including the entire Internet.' },
        'A': { 'value': 'Adjacent', 'desc': 'The vulnerable component is bound to the network stack, but the attack is limited at the protocol level to a logically adjacent topology.' },
        'L': { 'value': 'Local', 'desc': 'The vulnerable component is not bound to the network stack and the attacker\'s path is via read/write/execute capabilities.' },
        'P': { 'value': 'Physical', 'desc': 'The attack requires the attacker to physically touch or manipulate the vulnerable component.' }
    },
    'AC': {
        'L': { 'value': 'Low', 'desc': 'Specialized access conditions or extenuating circumstances do not exist.' },
        'H': { 'value': 'High', 'desc': 'A successful attack depends on conditions beyond the attacker\'s control.' }
    },
    'PR': {
        'N': { 'value': 'None', 'desc': 'The attacker is unauthorized prior to attack, and therefore does not require any access to settings or files of the vulnerable system to carry out an attack.' },
        'L': { 'value': 'Low', 'desc': 'The attacker requires privileges that provide basic user capabilities that could normally affect only settings and files owned by a user.' },
        'H': { 'value': 'High', 'desc': 'The attacker requires privileges that provide significant (e.g., administrative) control over the vulnerable component allowing access to component-wide settings and files.' }
    },
    'UI': {
        'N': { 'value': 'None', 'desc': 'The vulnerable system can be exploited without interaction from any user.' },
        'R': { 'value': 'Required', 'desc': 'Successful exploitation of this vulnerability requires a user to take some action before the vulnerability can be exploited.' }
    },
    'S': {
        'U': { 'value': 'Unchanged', 'desc': 'An exploited vulnerability can only affect resources managed by the same security authority. In this case, the vulnerable component and the impacted component are either the same, or both are managed by the same security authority.' },
        'C': { 'value': 'Changed', 'desc': 'An exploited vulnerability can affect resources beyond the security scope managed by the security authority of the vulnerable component.' }
    },
    'C': {
        'H': { 'value': 'High', 'desc': 'There is a total loss of confidentiality, resulting in all resources within the impacted component being divulged to the attacker.' },
        'L': { 'value': 'Low', 'desc': 'There is some loss of confidentiality.' },
        'N': { 'value': 'None', 'desc': 'There is no loss of confidentiality within the impacted component.' }
    },
    'I': {
        'H': { 'value': 'High', 'desc': 'There is a total loss of integrity, or a complete loss of protection.' },
        'L': { 'value': 'Low', 'desc': 'Modification of data is possible, but the attacker does not have control over the consequence of a modification, or the amount of modification is limited.' },
        'N': { 'value': 'None', 'desc': 'There is no loss of integrity within the impacted component.' }
    },
    'A': {
        'H': { 'value': 'High', 'desc': 'There is a total loss of availability, resulting in the attacker being able to fully deny access to resources in the impacted component; this loss is either sustained (while the attacker continues to deliver the attack) or persistent (the condition persists even after the attack has completed).' },
        'L': { 'value': 'Low', 'desc': 'Performance is reduced or there are interruptions in resource availability.' },
        'N': { 'value': 'None', 'desc': 'There is no impact to availability within the impacted component.' }
    }
};

function checkVectorValue(vectorin, vectorname, vectorabbr, vectorvalues) {
    console.log("checkVectorValue:vectorin:" + vectorin);
    console.log("checkVectorValue:vectorname:" + vectorname);
    console.log("checkVectorValue:vectorabbr:" + vectorabbr);
    console.log("checkVectorValue:vectorvalues:" + vectorvalues);
    returnvalue = vectorin;
    returnmessage = ""
    splitvectorin = vectorin.split(":");
    if (splitvectorin[0] == undefined) {
        badvector = true;
        returnmessage += "Unsupported " + vectorname + " " + returnvalue + "\n";
    }
    if (splitvectorin[1] == undefined) {
        badvector = true;
        returnmessage += "Unsupported " + vectorname + " " + returnvalue + "\n";
    }
    if (splitvectorin[0] != vectorabbr) {
        badvector = true;
        returnmessage += vectorname + " (" + vectorabbr + ") entered: " + returnvalue + "\n";
    }
    splitvectorvalues = vectorvalues.split("/")
    vectorvaluefound = false;
    vectorvalues = ""
    for (let i = 0; i < splitvectorvalues.length; i++) {
        console.log("checkVectorValue:splitvectorvalues[" + i + "]:" + splitvectorvalues[i]);

        if (splitvectorvalues[i] == splitvectorin[1]) {
            vectorvaluefound = true;
        }
        if (vectorvalues.length) {
            vectorvalues += " or "
        }
        vectorvalues += splitvectorvalues[i];
        console.log("checkVectorValue:vectorvalues:" + vectorvalues);
    }
    if (vectorvaluefound) {
        return splitvectorin[1]
    } else {
        badvector = true;
        returnmessage += vectorname + " (" + vectorabbr + ") value " + vectorvalues + " expected: " + returnvalue + "\n";
    }
    return returnmessage;
}
function validateCVSS31() {
    vector = document.getElementById("cvssvector").value
    if (vector == null || vector == "") {
        alert("Vector is empty.");
        return
    }
    //CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:L/I:L/A:L
    badvector = false;
    message = "";

    const vectorArray = vector.split("/");
    if (vectorArray[0] == undefined) {
        badvector = true
        message = "Unsupported format: " + vector + "\n";
    } else {
        version = vectorArray[0];
        if (version != "CVSS:3.1") {
            badvector = true
            message += "Unsupported CVSS Version: " + version + "\n";
        }
    }
    if (vectorArray[1] == undefined) {
        badvector = true
    } else {
        attackvector = vectorArray[1];
        attackvector = checkVectorValue(attackvector, "Attack Vector", "AV", "N/A/L/P")
        if (attackvector.length > 1) {
            badvector = true;
            message += attackvector;
        }
    }
    if (vectorArray[2] == undefined) {
        badvector = true
    } else {
        attackcomplexity = vectorArray[2];
        attackcomplexity = checkVectorValue(attackcomplexity, "Attack Complexity", "AC", "L/H")
        if (attackcomplexity.length > 1) {
            badvector = true;
            message += attackcomplexity;
        }
    }
    if (vectorArray[3] == undefined) {
        badvector = true
    } else {
        privilegesrequired = vectorArray[3];
        privilegesrequired = checkVectorValue(privilegesrequired, "Privileges Required", "PR", "N/L/H")
        if (privilegesrequired.length > 1) {
            badvector = true;
            message += privilegesrequired;
        }
    }
    if (vectorArray[4] == undefined) {
        badvector = true
    } else {
        userinteraction = vectorArray[4];
        userinteraction = checkVectorValue(userinteraction, "User Interaction", "UI", "N/R")
        if (userinteraction.length > 1) {
            badvector = true;
            message += userinteraction;
        }
    }
    if (vectorArray[5] == undefined) {
        badvector = true
    } else {
        scope = vectorArray[5];
        scope = checkVectorValue(scope, "Scope", "S", "U/C")
        if (scope.length > 1) {
            badvector = true;
            message += scope;
        }
    }
    if (vectorArray[6] == undefined) {
        badvector = true
    } else {
        confidentiality = vectorArray[6];
        confidentiality = checkVectorValue(confidentiality, "confidentiality", "C", "N/L/H")
        if (confidentiality.length > 1) {
            badvector = true;
            message += confidentiality;
        }
    }
    if (vectorArray[7] == undefined) {
        badvector = true
    } else {
        integrity = vectorArray[7];
        integrity = checkVectorValue(integrity, "Intigrety", "I", "N/L/H")
        if (integrity.length > 1) {
            badvector = true;
            message += integrity;
        }
    }
    if (vectorArray[8] == undefined) {
        badvector = true
    } else {
        availability = vectorArray[8];
        availability = checkVectorValue(availability, "Availability", "A", "N/L/H")
        if (availability.length > 1) {
            badvector = true;
            message += availability;
        }
    }

    parsed = "version:" + version + "\n" +
        "attackvector:" + attackvector + "\n" +
        "attackcomplexity:" + attackcomplexity + "\n" +
        "privilegesrequired:" + privilegesrequired + "\n" +
        "userinteraction:" + userinteraction + "\n" +
        "scope:" + scope + "\n" +
        "confidentiality:" + confidentiality + "\n" +
        "integrity:" + integrity + "\n" +
        "availability:" + availability;
    console.log("validateCVSS31:parsed:" + parsed);

    /*
    for (key in cvss_table) { 
        console.log(cvss_table[" + key + "]");
        for (subkey in cvss_table[key]) { 
            console.log("cvss_table[" + key + "][" + subkey + "]:" + cvss_table[key][subkey]);
            for (subsubkey in cvss_table[key][subkey]) { 
                console.log("cvss_table[" + key + "][" + subkey + "][" + subsubkey + "]:" + cvss_table[key][subkey][subsubkey]);
            }
        }
    }
    console.log("cvss_table['AV']['" + attackvector + "']['value'] = " + cvss_table['AV'][attackvector]['value']);
    console.log("cvss_table['AV']['" + attackvector + "']['desc'] = " + cvss_table['AV'][attackvector]['desc']);
    */

    var textarea = "Attack Vector : " + cvss_table['AV'][attackvector]['value'] + " : " + cvss_table['AV'][attackvector]['desc'] + "\n" +
        "Attack Complexity : " + cvss_table['AC'][attackcomplexity]['value'] + " : " + cvss_table['AC'][attackcomplexity]['desc'] + "\n" +
        "Privileges Required : " + cvss_table['PR'][privilegesrequired]['value'] + " : " + cvss_table['PR'][privilegesrequired]['desc'] + "\n" +
        "User Interaction : " + cvss_table['UI'][userinteraction]['value'] + " : " + cvss_table['UI'][userinteraction]['desc'] + "\n" +
        "Scope : " + cvss_table['S'][scope]['value'] + " : " + cvss_table['S'][scope]['desc'] + "\n" +
        "Confidentiality : " + cvss_table['C'][confidentiality]['value'] + " : " + cvss_table['C'][confidentiality]['desc'] + "\n" +
        "Integrity : " + cvss_table['I'][integrity]['value'] + " : " + cvss_table['I'][integrity]['desc'] + "\n" +
        "Availability : " + cvss_table['A'][availability]['value'] + " : " + cvss_table['A'][availability]['desc'] + "\n";
    console.log("validateCVSS31:textarea:" + textarea);

    document.getElementById("cvssreasons").value = textarea;

    if (badvector) {
        console.log("Vector is not valid:\n" + message);
        alert("Vector is not valid:\n" + message);
    } else {
        setMetricsFromVector(vector);
    }
}