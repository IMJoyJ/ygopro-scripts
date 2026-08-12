--巳剣大祓
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：对方把魔法·陷阱·怪兽的效果发动时，把自己场上1只5星以上的爬虫类族怪兽解放才能发动。那个效果无效并破坏。
-- ②：把墓地的这张卡除外，以自己墓地1只爬虫类族怪兽为对象才能发动。那只怪兽特殊召唤，这个效果特殊召唤的怪兽以外的自己场上1只怪兽解放。
local s,id,o=GetID()
-- 注册两个效果：①连锁时无效并破坏对方效果；②墓地发动特殊召唤怪兽并解放场上怪兽
function s.initial_effect(c)
	-- ①：对方把魔法·陷阱·怪兽的效果发动时，把自己场上1只5星以上的爬虫类族怪兽解放才能发动。那个效果无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只爬虫类族怪兽为对象才能发动。那只怪兽特殊召唤，这个效果特殊召唤的怪兽以外的自己场上1只怪兽解放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 效果②的发动需要将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 判断是否为对方发动效果且该效果可被无效
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动效果且该效果可被无效
	return ep~=tp and Duel.IsChainDisablable(ev)
end
-- 筛选场上满足条件的爬虫类族5星以上怪兽
function s.cfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsLevelAbove(5) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果①的发动需要解放场上1只满足条件的怪兽
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽可解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil) end
	-- 选择1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil)
	-- 执行怪兽解放操作
	Duel.Release(g,REASON_COST)
end
-- 设置效果①的处理信息，包括使效果无效和破坏目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使效果无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏目标的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果①的处理：使连锁效果无效并破坏目标
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使效果无效且目标卡存在
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 筛选墓地满足条件的爬虫类族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动条件检查：墓地有爬虫类族怪兽可特殊召唤，且自己场上存在可解放的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空位可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp)
		-- 检查自己场上是否存在可解放的怪兽
		and Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地满足条件的怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果②的处理：特殊召唤怪兽并解放场上怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 目标怪兽可特殊召唤且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 提示选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 选择场上1只可解放的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsReleasableByEffect,tp,LOCATION_MZONE,0,1,1,tc)
		if g:GetCount()>0 then
			-- 显示选中怪兽被选为对象的动画
			Duel.HintSelection(g)
			-- 执行怪兽解放操作
			Duel.Release(g,REASON_EFFECT)
		end
	end
end
