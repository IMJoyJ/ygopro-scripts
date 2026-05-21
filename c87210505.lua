--騎士の称号
-- 效果：
-- ①：把自己场上1只表侧表示的「黑魔术师」解放才能发动。从自己的手卡·卡组·墓地选1只「黑魔术骑士」特殊召唤。
function c87210505.initial_effect(c)
	-- 在卡片中注册记载了「黑魔术师」卡名的事实
	aux.AddCodeList(c,46986414)
	-- ①：把自己场上1只表侧表示的「黑魔术师」解放才能发动。从自己的手卡·卡组·墓地选1只「黑魔术骑士」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c87210505.cost)
	e1:SetTarget(c87210505.target)
	e1:SetOperation(c87210505.activate)
	c:RegisterEffect(e1)
end
-- 解放怪兽的过滤条件函数（用于解放代价）
function c87210505.costfilter(c,tp)
	-- 检查卡片是否为表侧表示的「黑魔术师」，且解放后能空出怪兽区域
	return c:IsFaceup() and c:IsCode(46986414) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果发动的代价处理函数
function c87210505.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 在发动步骤检查是否能支付解放1只满足条件的怪兽的代价
	if chk==0 then return Duel.CheckReleaseGroup(tp,c87210505.costfilter,1,nil,tp) end
	-- 让玩家选择1只满足条件的怪兽准备解放
	local g=Duel.SelectReleaseGroup(tp,c87210505.costfilter,1,1,nil,tp)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤怪兽的过滤条件函数
function c87210505.spfilter(c,e,tp)
	return c:IsCode(50725996) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 效果发动的目标检查与操作信息设置函数
function c87210505.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可用的怪兽区域（若已支付解放代价则视为满足，否则检查当前怪兽区空格）
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查手卡、卡组、墓地中是否存在可特殊召唤的「黑魔术骑士」
		return res and Duel.IsExistingMatchingCard(c87210505.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 设置当前连锁的操作信息为：从手卡、卡组、墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理的执行函数
function c87210505.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前怪兽区域已满，则无法特殊召唤，直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡、卡组、墓地中选择1只满足条件的「黑魔术骑士」（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c87210505.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件和苏生限制以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
