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
-- 将效果的Label标记设为1，表示需要后续进行解放代价操作，并返回true允许发动。
function c29876529.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 筛选可作为解放代价的怪兽：必须为暗属性且攻击力1500以上，并且除其自身外场上还存在本回合特殊召唤的怪兽（保证有可破坏对象）。
function c29876529.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackAbove(1500)
		-- 检查除候选解放怪兽自身以外，场上是否还存在至少1只本回合特殊召唤的怪兽，作为破坏效果的目标依据。
		and Duel.IsExistingMatchingCard(c29876529.dfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 判断怪兽是否具有本回合特殊召唤状态（STATUS_SPSUMMON_TURN）。
function c29876529.dfilter(c)
	return c:IsStatus(STATUS_SPSUMMON_TURN)
end
-- 发动时点处理：若标记为需要解放则先选择并解放符合条件的暗属性怪兽作为代价，随后获取所有本回合特殊召唤的怪兽，并为破坏效果设置操作信息。
function c29876529.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=0 then
			e:SetLabel(0)
			-- 检查自己场上是否存在至少1只满足costfilter条件的可解放怪兽，以确认解放代价可行。
			return Duel.CheckReleaseGroup(tp,c29876529.costfilter,1,nil)
		else
			-- 检查场上是否存在至少1只本回合特殊召唤的怪兽，以确保破坏效果有对象。
			return Duel.IsExistingMatchingCard(c29876529.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 让玩家从自己场上选择1只满足costfilter条件的怪兽作为解放代价。
		local rg=Duel.SelectReleaseGroup(tp,c29876529.costfilter,1,1,nil)
		-- 将选中的怪兽以代价方式解放（REASON_COST）。
		Duel.Release(rg,REASON_COST)
	end
	-- 获取场上所有本回合特殊召唤的怪兽，这些怪兽将成为后续破坏效果的处理对象。
	local g=Duel.GetMatchingGroup(c29876529.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置本次连锁的操作信息为破坏：目标为上述怪兽组，数量为组内卡数，用于效果发动的检测与处理。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，再次获取场上所有本回合特殊召唤的怪兽，并将其全部破坏。
function c29876529.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有本回合特殊召唤的怪兽，作为实际破坏的对象。
	local g=Duel.GetMatchingGroup(c29876529.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因（REASON_EFFECT）破坏这些怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
