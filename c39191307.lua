--仮面竜
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的龙族怪兽特殊召唤。
function c39191307.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39191307,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c39191307.condition)
	e1:SetTarget(c39191307.target)
	e1:SetOperation(c39191307.operation)
	c:RegisterEffect(e1)
end
-- 检查此卡是否在墓地且因战斗破坏而离场
function c39191307.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤满足攻击力1500以下、龙族且可特殊召唤的卡
function c39191307.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_DRAGON)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上存在空位且卡组存在符合条件的怪兽
function c39191307.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c39191307.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果发动后将要处理的特殊召唤目标信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动后的操作：选择并特殊召唤符合条件的怪兽
function c39191307.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c39191307.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
