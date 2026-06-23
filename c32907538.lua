--ウォールクリエイター
-- 效果：
-- 这张卡召唤成功时，可以选择对方场上存在的1只怪兽。只要这张卡在场上表侧表示存在，选择的怪兽不能攻击也不能解放。这张卡的控制者在每次自己的结束阶段支付500基本分。或者不支付500基本分让这张卡破坏。
function c32907538.initial_effect(c)
	-- 这张卡召唤成功时，可以选择对方场上存在的1只怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32907538,1))  --"攻击限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c32907538.target)
	e1:SetOperation(c32907538.operation)
	c:RegisterEffect(e1)
	-- 这张卡的控制者在每次自己的结束阶段支付500基本分。或者不支付500基本分让这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c32907538.mtcon)
	e2:SetOperation(c32907538.mtop)
	c:RegisterEffect(e2)
end
-- 选择对方场上存在的1只怪兽作为效果对象。
function c32907538.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查是否满足选择对方场上怪兽的条件。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从对方场上选择1只怪兽作为效果对象。
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 将被选择的怪兽设置为不能攻击且不能解放。
function c32907538.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 使目标怪兽不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c32907538.rcon)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_SUM)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e3)
	end
end
-- 判断目标怪兽是否仍被该效果影响。
function c32907538.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
-- 判断是否为当前玩家的结束阶段。
function c32907538.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者。
	return Duel.GetTurnPlayer()==tp
end
-- 在结束阶段询问玩家是否支付500基本分以维持卡片存在。
function c32907538.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能支付500基本分并询问是否支付。
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(32907538,0)) then  --"是否要支付500基本分维持「造墙者」？"
		-- 支付500基本分。
		Duel.PayLPCost(tp,500)
	else
		-- 因未支付费用而破坏此卡。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
