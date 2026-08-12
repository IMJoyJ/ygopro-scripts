--獣人アレス
-- 效果：
-- 只要这张卡在场上表侧表示存在，每次有连锁发生这张卡的攻击力上升500。
function c71395725.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，每次有连锁发生
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c71395725.chop)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，每次有连锁发生这张卡的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c71395725.atkcon)
	e2:SetOperation(c71395725.atkop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 在有效果发动时触发，通过设置Label来记录当前连锁是否大于1（即是否形成了连锁）
function c71395725.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前正在处理的连锁序号是否为1（即是否是连锁的起点）
	if Duel.GetCurrentChain()==1 then
		e:SetLabel(0)
	else
		e:SetLabel(1)
	end
end
-- 在连锁结束时，判断在本次连锁中是否发生了连锁（即Label是否为1），并重置Label
function c71395725.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local res=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(0)
	return res==1
end
-- 在连锁结束且满足条件时，创建并注册使自身攻击力上升500的效果
function c71395725.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的攻击力上升500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
