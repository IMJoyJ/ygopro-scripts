--エーリアン・ソルジャー M／フレーム
-- 效果：
-- 爬虫类族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1只怪兽才能发动。丢弃的怪兽的原本等级数量的A指示物给场上的表侧表示怪兽放置。这个效果在对方回合也能发动。
-- ②：这张卡被战斗·效果破坏送去墓地的场合才能发动。从自己墓地选最多有着有A指示物放置的对方场上的怪兽数量的连接怪兽以外的爬虫类族怪兽特殊召唤（同名卡最多1张）。
function c74974229.initial_effect(c)
	c:EnableReviveLimit()
	-- 连接召唤素材设定：爬虫类族怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_REPTILE),2,2)
	-- 初始化卡片效果：注册丢弃手牌怪兽给场上怪兽放置原等级数量A指示物的自由奏效/诱发即时效果
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
	-- 初始化卡片效果：注册被破坏送墓时从墓地特召最多对方场上有A指示物怪兽数量的非连接爬虫类族怪兽诱发效果
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
-- 丢弃Cost过滤条件：拥有原本等级（1星以上）的怪兽且可丢弃
function c74974229.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1) and c:IsDiscardable()
end
-- ①效果发动Cost：从手牌丢弃1只怪兽，并记录其原本等级
function c74974229.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足Cost条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c74974229.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c74974229.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
	-- 将选择的怪兽作为Cost丢弃送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- ①效果发动准备：检查场上是否存在可放置A指示物的表侧表示怪兽并设置放置操作信息
function c74974229.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在可以放置A指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 设置连锁操作信息：放置原本等级数量的A指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetLabel(),0,0x100e)
end
-- ①效果处理：逐个选择场上的表侧表示怪兽放置A指示物，共放置Cost怪兽原本等级次
function c74974229.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 获取场上所有可以放置A指示物的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x100e,1)
	if g:GetCount()==0 then return end
	for i=1,ct do
		-- 提示玩家选择要放置指示物的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		local sg=g:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(0x100e,1)
	end
end
-- ②效果发动条件：此卡因战斗或效果被破坏并送去墓地
function c74974229.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 特召怪兽过滤条件：墓地中的爬虫类族怪兽，且不能是连接怪兽，且可以特殊召唤
function c74974229.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 对方怪兽条件过滤：场上带有A指示物的怪兽
function c74974229.ctfilter(c)
	return c:GetCounter(0x100e)>0
end
-- ②效果发动准备：检查怪兽区空位、墓地特召目标及对方场上带A指示物怪兽，并设置特召操作信息
function c74974229.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足特召条件的爬虫类族怪兽
		and Duel.IsExistingMatchingCard(c74974229.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查对方场上是否存在带有A指示物的怪兽
		and Duel.IsExistingMatchingCard(c74974229.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置连锁操作信息：从墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：从墓地选最多有带A指示物对方怪兽数量的不同名非连接爬虫类族怪兽特殊召唤
function c74974229.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己主要怪兽区域的剩余空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取墓地中符合条件的爬虫类族怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c74974229.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 统计对方场上带有A指示物的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c74974229.ctfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 or ct==0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择1到数量上限的互不同名怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,ct))
	-- 将选择的怪兽表侧表示特殊召唤
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
