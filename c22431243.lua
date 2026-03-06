--超進化薬
-- 效果：
-- 祭掉自己场上1只爬虫类族怪兽。从手卡特殊召唤1只恐龙族怪兽上场。
function c22431243.initial_effect(c)
	-- 效果原文：祭掉自己场上1只爬虫类族怪兽。从手卡特殊召唤1只恐龙族怪兽上场。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c22431243.cost)
	e1:SetTarget(c22431243.target)
	e1:SetOperation(c22431243.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查场上是否存在满足条件的爬虫类族怪兽（可解放）
function c22431243.cfilter(c,tp)
	return c:IsRace(RACE_REPTILE)
		-- 效果作用：确保该怪兽在场且有可用怪兽区
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果作用：支付代价，解放场上1只满足条件的爬虫类族怪兽
function c22431243.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 效果作用：检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c22431243.cfilter,1,nil,tp) end
	-- 效果作用：选择1只满足条件的爬虫类族怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c22431243.cfilter,1,1,nil,tp)
	-- 效果作用：将选中的怪兽以代价形式解放
	Duel.Release(g,REASON_COST)
end
-- 效果作用：筛选手卡中可特殊召唤的恐龙族怪兽
function c22431243.filter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断是否可以发动此效果（有怪兽区或已支付代价）
function c22431243.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件（有怪兽区或已支付代价）
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 效果作用：检查手卡中是否存在满足条件的恐龙族怪兽
		return res and Duel.IsExistingMatchingCard(c22431243.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤恐龙族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果作用：执行效果，从手卡特殊召唤恐龙族怪兽
function c22431243.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查是否有可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：从手卡选择1只满足条件的恐龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c22431243.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：将选中的恐龙族怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
