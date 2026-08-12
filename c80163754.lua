--バーストブレス
-- 效果：
-- ①：把自己场上1只龙族怪兽解放才能发动。持有解放的怪兽的攻击力以下的守备力的场上的怪兽全部破坏。
function c80163754.initial_effect(c)
	-- ①：把自己场上1只龙族怪兽解放才能发动。持有解放的怪兽的攻击力以下的守备力的场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMINGS_CHECK_MONSTER)
	e1:SetLabel(1)
	e1:SetCost(c80163754.cost)
	e1:SetTarget(c80163754.target)
	e1:SetOperation(c80163754.activate)
	c:RegisterEffect(e1)
end
-- 过滤可解放的龙族怪兽，要求其攻击力必须大于等于传入的守备力数值（确保至少能破坏1只怪兽）
function c80163754.cfilter(c,def)
	return c:IsRace(RACE_DRAGON) and c:IsAttackAbove(def)
end
-- 过滤场上表侧表示且守备力在指定数值以下的怪兽
function c80163754.filter(c,atk)
	return c:IsFaceup() and (not atk or c:IsDefenseBelow(atk))
end
-- 发动代价处理：检查并选择自己场上1只龙族怪兽解放，并将其攻击力保存到Label中
function c80163754.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取场上所有表侧表示的怪兽，用于后续计算最低守备力
		local g=Duel.GetMatchingGroup(c80163754.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:GetCount()==0 then return false end
		local mg,mdef=g:GetMinGroup(Card.GetDefense)
		e:SetLabel(0)
		-- 检查自己场上是否存在攻击力大于等于场上怪兽最低守备力的可解放龙族怪兽
		return Duel.CheckReleaseGroup(tp,c80163754.cfilter,1,nil,mdef)
	end
	-- 获取场上所有表侧表示的怪兽，用于计算最低守备力
	local g=Duel.GetMatchingGroup(c80163754.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local mg,mdef=g:GetMinGroup(Card.GetDefense)
	-- 选择自己场上1只攻击力大于等于场上怪兽最低守备力的龙族怪兽
	local rg=Duel.SelectReleaseGroup(tp,c80163754.cfilter,1,1,nil,mdef)
	e:SetLabel(rg:GetFirst():GetAttack())
	-- 解放选中的龙族怪兽
	Duel.Release(rg,REASON_COST)
end
-- 效果的目标处理：验证发动状态，并设置破坏怪兽的操作信息
function c80163754.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel()==0 end
	-- 获取场上守备力在解放怪兽攻击力以下的表侧表示怪兽
	local dg=Duel.GetMatchingGroup(c80163754.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetLabel())
	-- 设置破坏操作的信息，包含预计破坏的怪兽组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果运行处理：破坏所有守备力在解放怪兽攻击力以下的场上怪兽
function c80163754.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上守备力在解放怪兽攻击力以下的表侧表示怪兽
	local dg=Duel.GetMatchingGroup(c80163754.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetLabel())
	-- 破坏所有符合条件的怪兽
	Duel.Destroy(dg,REASON_EFFECT)
end
