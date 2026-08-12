--Live☆Twin エントランス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：丢弃1张手卡才能发动。从卡组把1只「姬丝基勒」怪兽或「璃拉」怪兽特殊召唤。这张卡的发动后，直到回合结束时自己不是「邪恶★双子」怪兽不能从额外卡组特殊召唤。
function c8083925.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。从卡组把1只「姬丝基勒」怪兽或「璃拉」怪兽特殊召唤。这张卡的发动后，直到回合结束时自己不是「邪恶★双子」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8083925,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,8083925+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c8083925.cost)
	e1:SetTarget(c8083925.target)
	e1:SetOperation(c8083925.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价：丢弃1张手牌
function c8083925.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手牌作为发动的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中属于「姬丝基勒」或「璃拉」字段且可以特殊召唤的怪兽
function c8083925.filter(c,e,tp)
	return c:IsSetCard(0x152,0x153) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动的目标检查与操作信息设置
function c8083925.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动时点检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c8083925.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理：从卡组特殊召唤怪兽，并适用额外卡组特殊召唤限制
function c8083925.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时检查自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 发送系统提示信息，提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组中选择1只满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c8083925.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是「邪恶★双子」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c8083925.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该回合内不能从额外卡组特殊召唤「邪恶★双子」以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 定义限制条件：不能从额外卡组特殊召唤「邪恶★双子」以外的怪兽
function c8083925.splimit(e,c)
	return not c:IsSetCard(0x2151) and c:IsLocation(LOCATION_EXTRA)
end
