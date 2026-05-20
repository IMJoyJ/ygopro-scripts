--ポールポジション
-- 效果：
-- 场上表侧表示存在的攻击力最高的怪兽不受魔法的效果影响。场上不存在「杆位」时，场上表侧表示存在的攻击力最高的怪兽破坏。
function c73578229.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	g:KeepAlive()
	-- 场上表侧表示存在的攻击力最高的怪兽不受魔法的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c73578229.adjustop)
	e2:SetLabelObject(g)
	c:RegisterEffect(e2)
	-- 场上表侧表示存在的攻击力最高的怪兽不受魔法的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetTarget(c73578229.etarget)
	e3:SetValue(c73578229.efilter)
	e3:SetLabelObject(g)
	c:RegisterEffect(e3)
	-- 场上不存在「杆位」时，场上表侧表示存在的攻击力最高的怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(c73578229.checkop)
	c:RegisterEffect(e4)
	-- 场上不存在「杆位」时，场上表侧表示存在的攻击力最高的怪兽破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetLabelObject(e4)
	e5:SetOperation(c73578229.desop)
	c:RegisterEffect(e5)
end
-- 判断怪兽是否属于当前攻击力最高的怪兽组
function c73578229.etarget(e,c)
	return e:GetLabelObject():IsContains(c)
end
-- 过滤出魔法卡的效果
function c73578229.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
-- 在场上状态变化时，更新并记录当前场上表侧表示攻击力最高的怪兽组，并刷新状态
function c73578229.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local preg=e:GetLabelObject()
	if g:GetCount()>0 then
		local ag=g:GetMaxGroup(Card.GetAttack)
		if ag:Equal(preg) then return end
		preg:Clear()
		preg:Merge(ag)
	else
		if preg:GetCount()==0 then return end
		preg:Clear()
	end
	-- 手动立即刷新受这张卡影响的怪兽的无效/免疫状态
	Duel.AdjustInstantly(e:GetHandler())
	-- 重新调整并刷新场上所有卡片的信息，以处理因免疫状态改变导致的攻击力变化
	Duel.Readjust()
end
-- 在卡片离场前，检查自身是否处于未被无效且已发动的状态，并记录结果
function c73578229.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsDisabled() or not c:IsStatus(STATUS_EFFECT_ENABLED) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 在卡片离场时，若离场前未被无效，则将场上表侧表示攻击力最高的怪兽破坏
function c73578229.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()==0 then
		-- 获取双方场上所有表侧表示的怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:GetCount()>0 then
			local ag=g:GetMaxGroup(Card.GetAttack)
			-- 因效果将攻击力最高的怪兽破坏
			Duel.Destroy(ag,REASON_EFFECT)
		end
	end
end
