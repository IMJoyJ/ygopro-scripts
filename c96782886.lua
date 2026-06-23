--メンタルマスター
-- 效果：
-- 支付800基本分，把自己场上「精神脑魔」以外的1只念动力族怪兽解放发动。从自己的卡组把1只等级4以下的念动力族怪兽在自己场上以表侧攻击表示特殊召唤。
function c96782886.initial_effect(c)
	-- 支付800基本分，把自己场上「精神脑魔」以外的1只念动力族怪兽解放发动。从自己的卡组把1只等级4以下的念动力族怪兽在自己场上以表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96782886,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,96782886)
	e1:SetCost(c96782886.cost)
	e1:SetTarget(c96782886.target)
	e1:SetOperation(c96782886.operation)
	c:RegisterEffect(e1)
end
function c96782886.costfilter(c,tp)
	return c:IsRace(RACE_PSYCHO) and Duel.GetMZoneCount(tp,c)>0
		and (c:IsControler(tp) or c:IsFaceup())
end
-- 代价处理：检查是否能支付800基本分并解放1只满足条件的怪兽
function c96782886.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,800)
		and Duel.CheckReleaseGroup(tp,c96782886.costfilter,1,nil,tp) end
	Duel.PayLPCost(tp,800)
	local sg=Duel.SelectReleaseGroup(tp,c96782886.costfilter,1,1,nil,tp)
	Duel.Release(sg,REASON_COST)
end
-- 过滤卡组中满足条件的怪兽：等级4以下的念动力族怪兽，且能以表侧攻击表示特殊召唤
function c96782886.filter(c,e,tp)
	return c:IsRace(RACE_PSYCHO) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果的目标处理：检查卡组中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c96782886.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96782886.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理：从卡组选择1只等级4以下的念动力族怪兽在自己场上以表侧攻击表示特殊召唤
function c96782886.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若满则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c96782886.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上
	if g:GetCount()>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK) end
end
