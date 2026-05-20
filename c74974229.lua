--エーリアン・ソルジャー M／フレーム
-- 效果：
-- 爬虫类族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1只怪兽才能发动。丢弃的怪兽的原本等级数量的A指示物给场上的表侧表示怪兽放置。这个效果在对方回合也能发动。
-- ②：这张卡被战斗·效果破坏送去墓地的场合才能发动。从自己墓地选最多有着有A指示物放置的对方场上的怪兽数量的连接怪兽以外的爬虫类族怪兽特殊召唤（同名卡最多1张）。
function c74974229.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续，需要爬虫类族怪兽2只作为连接素材
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
-- 过滤手卡中等级1以上且可以丢弃的怪兽卡
function c74974229.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1) and c:IsDiscardable()
end
-- ①效果的发动代价（Cost）处理：从手卡丢弃1只怪兽，并记录其原本等级
function c74974229.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c74974229.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手卡选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c74974229.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
	-- 将选择的怪兽作为发动代价丢弃送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- ①效果的发动准备（Target）处理：检查场上是否有可以放置A指示物的怪兽，并设置操作信息
function c74974229.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1只可以放置A指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 设置效果处理的操作信息为放置等同于丢弃怪兽原本等级数量的A指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetLabel(),0,0x100e)
end
-- ①效果的效果处理（Operation）：将等同于丢弃怪兽原本等级数量的A指示物分次放置在场上的表侧表示怪兽上
function c74974229.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 获取双方场上所有可以放置A指示物的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x100e,1)
	if g:GetCount()==0 then return end
	for i=1,ct do
		-- 提示玩家选择要放置指示物的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		local sg=g:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(0x100e,1)
	end
end
-- ②效果的发动条件：这张卡被战斗或效果破坏并送去墓地
function c74974229.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤墓地中可以特殊召唤的、连接怪兽以外的爬虫类族怪兽
function c74974229.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤场上放置有A指示物的怪兽
function c74974229.ctfilter(c)
	return c:GetCounter(0x100e)>0
end
-- ②效果的发动准备（Target）处理：检查自身怪兽区域空位数、墓地中是否有可特召的爬虫类族怪兽，以及对方场上是否有放置有A指示物的怪兽，并设置操作信息
function c74974229.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在至少1只满足特召条件的非连接爬虫类族怪兽
		and Duel.IsExistingMatchingCard(c74974229.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查对方场上是否存在至少1只放置有A指示物的怪兽
		and Duel.IsExistingMatchingCard(c74974229.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置效果处理的操作信息为从墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的效果处理（Operation）：从自己墓地选择最多等同于对方场上有A指示物怪兽数量的、卡名不同的非连接爬虫类族怪兽特殊召唤
function c74974229.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取自己墓地中满足特召条件且不受王家长眠之谷影响的非连接爬虫类族怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c74974229.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 计算对方场上放置有A指示物的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c74974229.ctfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 or ct==0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1到最大允许数量（受空位数和对方场上带A指示物怪兽数限制）的、卡名互不相同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,ct))
	-- 将选择的怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
