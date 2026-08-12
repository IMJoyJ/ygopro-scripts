--大凛魔天使ローザリアン
-- 效果：
-- 这张卡不能通常召唤。从自己的手卡和墓地把7星以上的植物族怪兽各1只从游戏中除外的场合可以特殊召唤。1回合1次，自己的主要阶段时才能发动。这张卡以外的场上表侧表示存在的卡的效果直到结束阶段时无效。
function c81146288.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己的手卡和墓地把7星以上的植物族怪兽各1只从游戏中除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c81146288.spcon)
	e1:SetTarget(c81146288.sptg)
	e1:SetOperation(c81146288.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，自己的主要阶段时才能发动。这张卡以外的场上表侧表示存在的卡的效果直到结束阶段时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81146288,0))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c81146288.distg)
	e2:SetOperation(c81146288.disop)
	c:RegisterEffect(e2)
end
-- 过滤手卡或墓地中等级7以上且可以除外的植物族怪兽
function c81146288.spfilter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_PLANT) and c:IsAbleToRemoveAsCost()
end
-- 检查自身特殊召唤的条件是否满足（怪兽区域有空位，且手卡和墓地各存在1只满足条件的怪兽）
function c81146288.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取手卡和墓地中所有满足条件的植物族怪兽
	local g=Duel.GetMatchingGroup(c81146288.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,c)
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查获取的怪兽组中是否能选出两张卡，分别位于手卡和墓地
		and g:CheckSubGroup(aux.gfcheck,2,2,Card.IsLocation,LOCATION_HAND,LOCATION_GRAVE)
end
-- 特殊召唤的准备处理，选择手卡和墓地各1只满足条件的怪兽并记录
function c81146288.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡和墓地中所有满足条件的植物族怪兽
	local g=Duel.GetMatchingGroup(c81146288.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,c)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从符合条件的怪兽中选择手卡和墓地各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsLocation,LOCATION_HAND,LOCATION_GRAVE)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的除外动作
function c81146288.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤的消耗表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 效果无效化效果的发动准备，检查场上是否存在除自身以外的表侧表示卡片
function c81146288.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查可行性：场上是否存在至少1张除自身以外可以被无效的表侧表示卡片
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
end
-- 效果无效化效果的实际处理，使场上除自身以外的所有表侧表示卡片的效果直到结束阶段时无效
function c81146288.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上除自身以外的所有可以被无效的表侧表示卡片
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	local tc=g:GetFirst()
	while tc do
		-- 效果直到结束阶段时无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果直到结束阶段时无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 效果直到结束阶段时无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
