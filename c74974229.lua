--エーリアン・ソルジャー M／フレーム
-- 效果：
-- 爬虫类族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1只怪兽才能发动。丢弃的怪兽的原本等级数量的A指示物给场上的表侧表示怪兽放置。这个效果在对方回合也能发动。
-- ②：这张卡被战斗·效果破坏送去墓地的场合才能发动。从自己墓地选最多有着有A指示物放置的对方场上的怪兽数量的连接怪兽以外的爬虫类族怪兽特殊召唤（同名卡最多1张）。
function c74974229.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加2只爬虫类族怪兽作为连接素材的连接召唤手续
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_REPTILE),2,2)
	-- ①：从手卡丢弃1只怪兽才能发动。丢弃的怪兽的原本等级数量的A指示物给场上的表侧表示怪兽放置。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74974229,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,74974229)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c74974229.ctcost)
	e1:SetTarget(c74974229.cttg)
	e1:SetOperation(c74974229.ctop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合才能发动。从自己墓地选最多有着有A指示物放置的对方场上的怪兽数量的连接怪兽以外的爬虫类族怪兽特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74974229,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,74974230)
	e2:SetCondition(c74974229.spcon)
	e2:SetTarget(c74974229.sptg)
	e2:SetOperation(c74974229.spop)
	c:RegisterEffect(e2)
end
c74974229.counter_add_list={0x100e}
c74974229.mentioned_counter={
	[0x100e]=true,
}
-- 过滤手卡中可以丢弃的有等级的怪兽
function c74974229.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1) and c:IsDiscardable()
end
-- 从手卡丢弃1只怪兽作为代价，并记录丢弃的怪兽的原本等级
function c74974229.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手卡是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c74974229.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c74974229.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
	-- 将选择的怪兽送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 判断场上是否有可以放置A指示物的怪兽并设置放置指示物的操作信息
function c74974229.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有可以放置A指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 设置放置指示物的操作信息，数量为丢弃怪兽的原本等级
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetLabel(),0,0x100e)
end
-- 给场上的表侧表示怪兽放置对应数量的A指示物
function c74974229.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 获取场上所有可以放置A指示物的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x100e,1)
	if g:GetCount()==0 then return end
	for i=1,ct do
		-- 提示选择要放置指示物的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		local sg=g:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(0x100e,1)
	end
end
-- 判断这张卡是否被战斗·效果破坏
function c74974229.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤自己墓地连接怪兽以外的爬虫类族怪兽
function c74974229.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤有A指示物的怪兽
function c74974229.ctfilter(c)
	return c:GetCounter(0x100e)>0
end
-- 判断是否有怪兽区域，以及墓地是否有可以特殊召唤的怪兽、对方场上是否有有A指示物的怪兽
function c74974229.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否有可以特殊召唤的满足条件的怪兽
		and Duel.IsExistingMatchingCard(c74974229.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 判断对方场上是否有有A指示物的怪兽
		and Duel.IsExistingMatchingCard(c74974229.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 从自己墓地选最多为对方场上有A指示物的怪兽数量的满足条件的怪兽特殊召唤
function c74974229.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的可用怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取自己墓地可以特殊召唤的满足条件的怪兽（不受王家长眠之谷影响）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c74974229.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取对方场上有A指示物的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c74974229.ctfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 or ct==0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选出卡名不同的怪兽，数量最多不超过怪兽区空位和对方场上有指示物怪兽数量的较小值
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,ct))
	-- 将选择的怪兽特殊召唤
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
