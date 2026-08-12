--剣闘排斥波
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的「剑斗兽」怪兽在战斗阶段以外不会成为对方的效果的对象。
-- ②：从自己卡组有「剑斗兽」怪兽特殊召唤的场合才能发动。相同种族的怪兽不在自己场上存在的1只「剑斗兽」怪兽从卡组守备表示特殊召唤。
function c93684009.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的「剑斗兽」怪兽在战斗阶段以外不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c93684009.tgcon)
	e2:SetTarget(c93684009.tglimit)
	-- 设置不能成为对方卡的效果的对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：从自己卡组有「剑斗兽」怪兽特殊召唤的场合才能发动。相同种族的怪兽不在自己场上存在的1只「剑斗兽」怪兽从卡组守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,93684009)
	e3:SetCondition(c93684009.spcon)
	e3:SetTarget(c93684009.sptg)
	e3:SetOperation(c93684009.spop)
	c:RegisterEffect(e3)
end
-- 检查当前是否处于战斗阶段以外。
function c93684009.tgcon(e)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return not (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 过滤受影响的卡片为「剑斗兽」怪兽。
function c93684009.tglimit(e,c)
	return c:IsSetCard(0x1019)
end
-- 过滤从自己卡组特殊召唤的「剑斗兽」怪兽。
function c93684009.cfilter(c,tp)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp)
end
-- 检查是否有满足条件的「剑斗兽」怪兽从自己卡组特殊召唤。
function c93684009.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c93684009.cfilter,1,nil,tp)
end
-- 过滤卡组中可以守备表示特殊召唤，且其种族不在自己场上存在的「剑斗兽」怪兽。
function c93684009.filter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查自己场上是否存在相同种族的怪兽。
		and not Duel.IsExistingMatchingCard(c93684009.filter1,tp,LOCATION_MZONE,0,1,c,c:GetRace())
end
-- 过滤自己场上表侧表示且种族相同的怪兽。
function c93684009.filter1(c,race)
	return c:IsFaceup() and c:IsRace(race)
end
-- 效果②的发动准备，检查怪兽区域空位以及卡组中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息。
function c93684009.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足特殊召唤条件的「剑斗兽」怪兽。
		and Duel.IsExistingMatchingCard(c93684009.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理，从卡组选择1只满足条件的「剑斗兽」怪兽表侧守备表示特殊召唤。
function c93684009.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送选择要特殊召唤的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「剑斗兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c93684009.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
