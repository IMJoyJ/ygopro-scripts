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
	-- 这张卡从场上离开时，这张卡放置的海洋指示物每有1个，自己场上存在的鱼族·海龙族怪兽的攻击力直到结束阶段时上升200。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c4404099.regop)
	c:RegisterEffect(e0)
	-- 攻击上升
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4404099,1))  --"攻击上升"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c4404099.atkcon)
	e2:SetOperation(c4404099.atkop)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
end
-- 设置连锁操作信息，表示将要放置1个海洋指示物。
function c4404099.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定放置指示物的类别为CATEGORY_COUNTER。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x23)
end
-- 将海洋指示物放置到场上。
function c4404099.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x23,1)
	end
end
-- 记录离开场上的海洋指示物数量。
function c4404099.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetCounter(0x23)
	e:SetLabel(ct)
end
-- 判断离开场上时是否带有海洋指示物。
function c4404099.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	e:SetLabel(ct)
	return ct>0
end
-- 过滤场上存在的鱼族或海龙族怪兽。
function c4404099.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_SEASERPENT)
end
-- 为符合条件的怪兽设置攻击力提升效果。
function c4404099.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有鱼族和海龙族的怪兽。
	local g=Duel.GetMatchingGroup(c4404099.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为怪兽设置攻击力提升200×指示物数量的效果，持续到结束阶段。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel()*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
