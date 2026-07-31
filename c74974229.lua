--エーリアン・ソルジャー M／フレーム
-- 效果：
-- 爬虫类族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1只怪兽才能发动。丢弃的怪兽的原本等级数量的A指示物给场上的表侧表示怪兽放置。这个效果在对方回合也能发动。
-- ②：这张卡被战斗·效果破坏送去墓地的场合才能发动。从自己墓地选最多有着有A指示物放置的对方场上的怪兽数量的连接怪兽以外的爬虫类族怪兽特殊召唤（同名卡最多1张）。
function c74974229.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册连接召唤手续：爬虫类族怪兽2只
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
-- Cost过滤条件：手牌中等级1以上的怪兽且可丢弃
function c74974229.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1) and c:IsDiscardable()
end
-- ①效果发动Cost：丢弃1只怪兽并记录其原本等级
function c74974229.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：手牌是否存在可丢弃的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c74974229.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌选择1只怪兽
	local g=Duel.SelectMatchingCard(tp,c74974229.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
	-- 从手牌丢弃选中的怪兽
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- ①效果发动准备：设置放置A指示物的操作信息
function c74974229.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：场上是否存在可放置A指示物的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 设置连锁操作信息：放置记载数量的0x100e（A）指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetLabel(),0,0x100e)
end
-- ①效果处理：给场上的表侧表示怪兽放置丢弃怪兽原本等级数量的A指示物
function c74974229.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 获取场上所有可放置A指示物的卡
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x100e,1)
	if g:GetCount()==0 then return end
	for i=1,ct do
		-- 提示玩家选择要放置指示物的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		local sg=g:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(0x100e,1)
	end
end
-- ②效果发动条件：此卡被战斗或效果破坏送去墓地
function c74974229.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 墓地特召过滤条件：非连接怪兽的爬虫类族怪兽且可特殊召唤
function c74974229.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 指示物过滤条件：有A指示物放置的卡
function c74974229.ctfilter(c)
	return c:GetCounter(0x100e)>0
end
-- ②效果发动准备：设置从墓地特殊召唤怪兽的操作信息
function c74974229.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：墓地是否存在可特召的非连接爬虫类族怪兽
		and Duel.IsExistingMatchingCard(c74974229.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 发动条件检查：对方场上是否存在放置有A指示物的怪兽
		and Duel.IsExistingMatchingCard(c74974229.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置连锁操作信息：从墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：从墓地选最多为对方场上有A指示物怪兽数量的非连接爬虫类族怪兽特殊召唤
function c74974229.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取墓地中不受王谷影响且满足条件的爬虫类族怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c74974229.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取对方场上有A指示物放置的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c74974229.ctfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 or ct==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从符合条件的怪兽中选择不同名的卡组（数量不超过可特召上限）
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,ct))
	-- 将选中的怪兽表侧表示特殊召唤
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
