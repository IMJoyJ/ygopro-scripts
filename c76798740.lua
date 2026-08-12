--ヴェンデット・チャージ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只不死族怪兽送去墓地才能发动。从卡组把1只「复仇死者」怪兽特殊召唤。
function c76798740.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡以及自己场上的表侧表示怪兽之中把1只不死族怪兽送去墓地才能发动。从卡组把1只「复仇死者」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,76798740+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c76798740.cost)
	e1:SetTarget(c76798740.target)
	e1:SetOperation(c76798740.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡或场上表侧表示的、可以作为代价送去墓地的不死族怪兽
function c76798740.cfilter(c,tp)
	return c:IsRace(RACE_ZOMBIE) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToGraveAsCost()
		-- 检查将该卡送去墓地后，是否能腾出可用于特殊召唤的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 发动代价：从手卡以及自己场上的表侧表示怪兽之中把1只不死族怪兽送去墓地
function c76798740.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手卡或场上是否存在满足送墓条件且能腾出怪兽区域的不死族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c76798740.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张手卡或场上表侧表示的不死族怪兽
	local g=Duel.SelectMatchingCard(tp,c76798740.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤卡组中可以特殊召唤的「复仇死者」怪兽
function c76798740.filter(c,e,tp)
	return c:IsSetCard(0x106) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标确认与操作信息设置
function c76798740.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在可以特殊召唤的「复仇死者」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c76798740.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组把1只「复仇死者」怪兽特殊召唤
function c76798740.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只「复仇死者」怪兽
	local g=Duel.SelectMatchingCard(tp,c76798740.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
