--闇の閃光
-- 效果：
-- ①：把自己场上1只攻击力1500以上的暗属性怪兽解放才能发动。把这个回合特殊召唤的怪兽全部破坏。
function c29876529.initial_effect(c)
	-- ①：把自己场上1只攻击力1500以上的暗属性怪兽解放才能发动。把这个回合特殊召唤的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c29876529.cost)
	e1:SetTarget(c29876529.target)
	e1:SetOperation(c29876529.activate)
	c:RegisterEffect(e1)
end
-- 设置发动时的标记为1，表示需要支付解放代价
function c29876529.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 检查场上是否存在满足条件的暗属性且攻击力1500以上的怪兽
function c29876529.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackAbove(1500)
		-- 确保该怪兽在场上存在可以被破坏的特殊召唤怪兽
		and Duel.IsExistingMatchingCard(c29876529.dfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 判断是否为本回合特殊召唤的怪兽
function c29876529.dfilter(c)
	return c:IsStatus(STATUS_SPSUMMON_TURN)
end
-- 判断是否满足发动条件并处理解放怪兽和设置破坏对象
function c29876529.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=0 then
			e:SetLabel(0)
			-- 检查场上是否存在满足条件的可解放怪兽
			return Duel.CheckReleaseGroup(tp,c29876529.costfilter,1,nil)
		else
			-- 检查场上是否存在本回合特殊召唤的怪兽
			return Duel.IsExistingMatchingCard(c29876529.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择满足条件的可解放怪兽
		local rg=Duel.SelectReleaseGroup(tp,c29876529.costfilter,1,1,nil)
		-- 将选中的怪兽解放作为发动代价
		Duel.Release(rg,REASON_COST)
	end
	-- 获取所有本回合特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c29876529.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，准备破坏怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果发动时执行破坏操作
function c29876529.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有本回合特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c29876529.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将所有符合条件的怪兽破坏
	Duel.Destroy(g,REASON_EFFECT)
end
