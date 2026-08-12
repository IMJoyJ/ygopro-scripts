--カードガード
-- 效果：
-- 这张卡召唤·特殊召唤成功时，给这张卡放置1个守卫指示物。这张卡放置的守卫指示物每有1个，这张卡的攻击力上升300。此外，1回合1次，可以把这张卡放置的1个守卫指示物取除，并给这张卡以外的自己场上表侧表示存在的1张卡放置1个守卫指示物。选择的卡被破坏的场合，作为代替把1个守卫指示物取除。
function c4694209.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，给这张卡放置1个守卫指示物
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4694209,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c4694209.addct)
	e1:SetOperation(c4694209.addc)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这张卡放置的守卫指示物每有1个，这张卡的攻击力上升300
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c4694209.attackup)
	c:RegisterEffect(e3)
	-- 1回合1次，可以把这张卡放置的1个守卫指示物取除，并给这张卡以外的自己场上表侧表示存在的1张卡放置1个守卫指示物
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4694209,1))  --"转移指示物"
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCost(c4694209.addccost2)
	e4:SetTarget(c4694209.addct2)
	e4:SetOperation(c4694209.addc2)
	c:RegisterEffect(e4)
end
c4694209.mentioned_counter={
	[0x1021]=true,
}
-- 召唤·特殊召唤成功时的发动条件检测：无需条件恒为可发动，并设置放置1个守卫指示物的操作信息
function c4694209.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁要放置1个守卫指示物（CATEGORY_COUNTER）的操作信息
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1021)
end
-- 效果处理：若这张卡仍与效果关联，给这张卡放置1个守卫指示物
function c4694209.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1021,1)
	end
end
-- 永续效果：这张卡的攻击力上升其放置的守卫指示物数量×300
function c4694209.attackup(e,c)
	return c:GetCounter(0x1021)*300
end
-- 起动效果的代价：检测并取除这张卡放置的1个守卫指示物作为发动代价
function c4694209.addccost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1021,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1021,1,REASON_COST)
end
-- 起动效果的对象选择：确认场上存在可放置守卫指示物的卡后，选择这张卡以外自己场上1张可放置守卫指示物的卡作为对象
function c4694209.addct2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsCanAddCounter(0x1021,1) end
	-- 发动条件检测：自己场上（这张卡以外）是否存在可以放置守卫指示物的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),0x1021,1) end
	-- 向玩家发送选择卡片的提示「转移指示物」
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(4694209,1))  --"转移指示物"
	-- 选择这张卡以外的自己场上1张可以放置守卫指示物的卡作为效果对象
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),0x1021,1)
end
-- 效果处理：给对象卡放置1个守卫指示物，若尚未注册则赋予其代替破坏效果（被破坏时改为取除1个守卫指示物）并做已注册标记
function c4694209.addc2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1021,1)
		if tc:GetFlagEffect(4694209)~=0 then return end
		-- 选择的卡被破坏的场合，作为代替把1个守卫指示物取除
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EFFECT_DESTROY_REPLACE)
		e1:SetTarget(c4694209.reptg)
		e1:SetOperation(c4694209.repop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(4694209,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
-- 代替破坏的适用条件：破坏非规则原因且该卡放置有守卫指示物
function c4694209.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_RULE) and e:GetHandler():GetCounter(0x1021)>0 end
	return true
end
-- 代替破坏的处理：取除该卡放置的1个守卫指示物作为破坏的代替
function c4694209.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x1021,1,REASON_EFFECT)
end
