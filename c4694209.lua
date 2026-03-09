--カードガード
-- 效果：
-- 这张卡召唤·特殊召唤成功时，给这张卡放置1个守卫指示物。这张卡放置的守卫指示物每有1个，这张卡的攻击力上升300。此外，1回合1次，可以把这张卡放置的1个守卫指示物取除，并给这张卡以外的自己场上表侧表示存在的1张卡放置1个守卫指示物。选择的卡被破坏的场合，作为代替把1个守卫指示物取除。
function c4694209.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，给这张卡放置1个守卫指示物。
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
	-- 这张卡放置的守卫指示物每有1个，这张卡的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c4694209.attackup)
	c:RegisterEffect(e3)
	-- 此外，1回合1次，可以把这张卡放置的1个守卫指示物取除，并给这张卡以外的自己场上表侧表示存在的1张卡放置1个守卫指示物。选择的卡被破坏的场合，作为代替把1个守卫指示物取除。
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
-- 设置连锁操作信息，指定将要放置1个守卫指示物。
function c4694209.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息为放置指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1021)
end
-- 若此卡存在于场上，则给此卡放置1个守卫指示物。
function c4694209.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1021,1)
	end
end
-- 返回此卡所放置的守卫指示物数量乘以300作为攻击力提升值。
function c4694209.attackup(e,c)
	return c:GetCounter(0x1021)*300
end
-- 支付1个守卫指示物作为代价，从自己场上取除1个守卫指示物。
function c4694209.addccost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1021,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1021,1,REASON_COST)
end
-- 选择目标卡片，确保其为己方场上的可放置守卫指示物的卡。
function c4694209.addct2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsCanAddCounter(0x1021,1) end
	-- 检查是否存在满足条件的目标卡片。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),0x1021,1) end
	-- 提示玩家选择要转移指示物的目标卡片。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(4694209,1))  --"转移指示物"
	-- 选择一个己方场上的目标卡片并设置为连锁对象。
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),0x1021,1)
end
-- 将目标卡片上放置1个守卫指示物，并注册代替破坏效果。
function c4694209.addc2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁处理的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1021,1)
		if tc:GetFlagEffect(4694209)~=0 then return end
		-- 为被转移指示物的卡片注册代替破坏效果，当该卡被破坏时取除1个守卫指示物。
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
-- 判断是否可以发动代替破坏效果，条件是该卡不是因规则破坏且拥有守卫指示物。
function c4694209.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_RULE) and e:GetHandler():GetCounter(0x1021)>0 end
	return true
end
-- 当代替破坏效果发动时，从目标卡上取除1个守卫指示物。
function c4694209.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x1021,1,REASON_EFFECT)
end
