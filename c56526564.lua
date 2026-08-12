--絶縁の落とし穴
-- 效果：
-- ①：连接怪兽连接召唤成功时才能发动。场上的不在连接状态的怪兽全部破坏。
function c56526564.initial_effect(c)
	-- ①：连接怪兽连接召唤成功时才能发动。场上的不在连接状态的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c56526564.condition)
	e1:SetTarget(c56526564.target)
	e1:SetOperation(c56526564.activate)
	c:RegisterEffect(e1)
end
-- 过滤连接召唤成功的连接怪兽
function c56526564.cfilter(c)
	return c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 检查特殊召唤成功的怪兽中是否存在连接召唤成功的连接怪兽，作为发动的条件
function c56526564.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c56526564.cfilter,1,nil)
end
-- 过滤不在连接状态的怪兽
function c56526564.filter(c)
	return not c:IsLinkState()
end
-- 发动时的效果对象确认与操作信息设置，检查场上是否存在不在连接状态的怪兽
function c56526564.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上所有不在连接状态的怪兽
	local g=Duel.GetMatchingGroup(c56526564.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置破坏操作信息，包含要破坏的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理，获取并破坏场上所有不在连接状态的怪兽
function c56526564.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场上所有不在连接状态的怪兽
	local g=Duel.GetMatchingGroup(c56526564.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 因效果破坏这些不在连接状态的怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
