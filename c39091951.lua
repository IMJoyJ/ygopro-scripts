--パンダボーグ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以支付800基本分从自己卡组把1只4星的念动力族怪兽特殊召唤。
function c39091951.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以支付800基本分从自己卡组把1只4星的念动力族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39091951,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c39091951.condition)
	e1:SetCost(c39091951.cost)
	e1:SetTarget(c39091951.target)
	e1:SetOperation(c39091951.operation)
	c:RegisterEffect(e1)
end
-- 判定触发条件：这张卡被战斗破坏送去墓地时，即自身当前位于墓地且破坏原因为战斗破坏。
function c39091951.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 支付代价：检查并实际支付800基本分作为发动代价。
function c39091951.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认玩家能否支付800基本分，若不能则不能发动。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 实际支付800基本分。
	Duel.PayLPCost(tp,800)
end
-- 定义检索/召唤对象的过滤条件：必须是4星、念动力族且可以被玩家特殊召唤的怪兽。
function c39091951.filter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标判定：在发动时确认自己主要怪兽区有空位，且卡组存在满足条件的1只怪兽可供特殊召唤。
function c39091951.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的1只4星念动力族怪兽（不取对象，处理时再选择）。
		and Duel.IsExistingMatchingCard(c39091951.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行特殊召唤，预期从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若场上仍有空位，则从卡组选择1只满足条件的怪兽以表侧攻击表示特殊召唤。
function c39091951.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上是否有可用的主要怪兽区域空格，若无则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组选出1只满足条件的4星念动力族怪兽。
	local g=Duel.SelectMatchingCard(tp,c39091951.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
