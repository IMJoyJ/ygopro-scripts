--生け贄人形
-- 效果：
-- 祭掉自己场上1只怪兽发动。从手卡特殊召唤1只可以通常召唤的7星怪兽。特殊召唤出的怪兽本回合不能攻击。
function c2903036.initial_effect(c)
	-- 效果发动时创建效果，设置为魔陷发动，自由时点，需要支付祭品，目标为特殊召唤，效果处理为激活
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c2903036.cost)
	e1:SetTarget(c2903036.target)
	e1:SetOperation(c2903036.activate)
	c:RegisterEffect(e1)
end
-- 检查玩家场上是否有可用怪兽区
function c2903036.cfilter(c,tp)
	-- 返回玩家场上可用怪兽区数量大于0
	return Duel.GetMZoneCount(tp,c)>0
end
-- 祭掉自己场上1只怪兽发动
function c2903036.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查玩家场上是否存在满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c2903036.cfilter,1,nil,tp) end
	-- 选择1张满足条件的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c2903036.cfilter,1,1,nil,tp)
	-- 将选中的怪兽解放作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 过滤手卡中可以通常召唤的7星怪兽
function c2903036.filter(c,e,tp)
	return c:IsLevel(7) and c:IsSummonableCard() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，检查是否存在满足条件的怪兽
function c2903036.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤条件
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查手卡中是否存在满足条件的怪兽
		return res and Duel.IsExistingMatchingCard(c2903036.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 设置连锁操作信息，准备特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 发动效果，从手卡特殊召唤1只7星怪兽
function c2903036.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c2903036.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 特殊召唤选中的怪兽并设置不能攻击效果
	if g:GetCount()>0 and Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP) then
		-- 特殊召唤出的怪兽本回合不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		g:GetFirst():RegisterEffect(e1,true)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
