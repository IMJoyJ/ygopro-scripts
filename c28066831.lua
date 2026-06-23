--ガスタ・サンボルト
-- 效果：
-- 这张卡被战斗破坏送去墓地的场合，那次战斗阶段结束时可以把自己墓地存在的1只名字带有「薰风」的怪兽从游戏中除外，从自己卡组把1只守备力1500以下的念动力族·风属性怪兽特殊召唤。
function c28066831.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地的场合，那次战斗阶段结束时可以把自己墓地存在的1只名字带有「薰风」的怪兽从游戏中除外，从自己卡组把1只守备力1500以下的念动力族·风属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetOperation(c28066831.flagop)
	c:RegisterEffect(e1)
end
-- 当此卡因战斗破坏被送入墓地时，将自身场上的效果设置为在战斗阶段结束时发动的效果。
function c28066831.flagop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_GRAVE) or bit.band(c:GetReason(),REASON_BATTLE)==0 then return end
	-- 特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28066831,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCost(c28066831.cost)
	e1:SetTarget(c28066831.target)
	e1:SetOperation(c28066831.operation)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 用于判断是否满足除外的条件：是否为薰风卡组的怪兽且为怪兽卡且可以作为除外的代价。
function c28066831.costfilter(c)
	return c:IsSetCard(0x10) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 支付除外代价：选择1只满足条件的墓地怪兽除外。
function c28066831.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外代价的条件：确认墓地是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28066831.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只墓地怪兽。
	local g=Duel.SelectMatchingCard(tp,c28066831.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将所选怪兽从游戏中除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 用于判断是否满足特殊召唤的条件：守备力不超过1500、念动力族、风属性且可以特殊召唤。
function c28066831.filter(c,e,tp)
	return c:IsDefenseBelow(1500) and c:IsRace(RACE_PSYCHO) and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的目标：确认卡组是否存在满足条件的怪兽且场上存在空位。
function c28066831.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c28066831.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤1只满足条件的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤：从卡组选择1只满足条件的怪兽特殊召唤。
function c28066831.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只卡组怪兽。
	local g=Duel.SelectMatchingCard(tp,c28066831.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将所选怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
