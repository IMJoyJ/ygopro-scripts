--海底に潜む深海竜
-- 效果：
-- 每次双方准备阶段时给这张卡放置1个海洋指示物。这张卡从场上离开时，这张卡放置的海洋指示物每有1个，自己场上存在的鱼族·海龙族怪兽的攻击力直到结束阶段时上升200。
function c4404099.initial_effect(c)
	c:EnableCounterPermit(0x23)
	-- 每次双方准备阶段时给这张卡放置1个海洋指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4404099,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetTarget(c4404099.addct)
	e1:SetOperation(c4404099.addc)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c4404099.regop)
	c:RegisterEffect(e0)
	-- 这张卡从场上离开时，这张卡放置的海洋指示物每有1个，自己场上存在的鱼族·海龙族怪兽的攻击力直到结束阶段时上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4404099,1))  --"攻击上升"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c4404099.atkcon)
	e2:SetOperation(c4404099.atkop)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
end
c4404099.mentioned_counter={
	[0x23]=true,
}
-- 放置指示物效果的发动条件检测：返回true表示可以发动，并设置指示物操作信息。
function c4404099.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：宣告本次处理将放置1个海洋指示物（0x23）。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x23)
end
-- 效果处理：若这张卡仍与效果关联（仍在场上），则给这张卡放置1个海洋指示物。
function c4404099.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x23,1)
	end
end
-- 这张卡离场前，记录这张卡当前放置的海洋指示物数量，存入效果标签供后续攻击力上升效果使用。
function c4404099.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetCounter(0x23)
	e:SetLabel(ct)
end
-- 发动条件检测：读取离场前记录的海洋指示物数量，数量大于0时效果才能发动。
function c4404099.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	e:SetLabel(ct)
	return ct>0
end
-- 过滤条件：表侧表示且种族为鱼族或海龙族的怪兽。
function c4404099.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_SEASERPENT)
end
-- 效果处理：检索自己场上所有表侧表示的鱼族·海龙族怪兽，逐一赋予攻击力上升效果，上升数值为记录的指示物数量×200，直到结束阶段。
function c4404099.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索自己怪兽区域中满足过滤条件（表侧表示的鱼族·海龙族）的全部怪兽。
	local g=Duel.GetMatchingGroup(c4404099.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上存在的鱼族·海龙族怪兽的攻击力直到结束阶段时上升200（每有1个海洋指示物）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel()*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
