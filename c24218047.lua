--破面竜
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只守备力1500以下的幻龙族怪兽特殊召唤。
function c24218047.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只守备力1500以下的幻龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24218047,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c24218047.condition)
	e1:SetTarget(c24218047.target)
	e1:SetOperation(c24218047.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡在墓地且因战斗破坏
function c24218047.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数：守备力1500以下的幻龙族怪兽且可以特殊召唤
function c24218047.filter(c,e,tp)
	return c:IsDefenseBelow(1500) and c:IsRace(RACE_WYRM)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时点判断：场上存在满足条件的怪兽且有空位
function c24218047.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c24218047.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：将要特殊召唤1只幻龙族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：若场上存在空位则提示选择并特殊召唤
function c24218047.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只幻龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c24218047.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
