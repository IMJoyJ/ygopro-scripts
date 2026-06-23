--ダーク・アイズ・イリュージョニスト
-- 效果：
-- 反转：这张卡场上存在的时候，指定的1只怪兽永续不能攻击。
function c38247752.initial_effect(c)
	-- 反转效果：指定1只对方怪兽永续不能攻击
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38247752,0))  --"攻击限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c38247752.target)
	e1:SetOperation(c38247752.operation)
	c:RegisterEffect(e1)
end
-- 选择效果对象：选择对方场上1只表侧表示怪兽
function c38247752.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 提示选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只对方场上表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 将指定怪兽设置为不能攻击
function c38247752.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 使目标怪兽永续不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c38247752.rcon)
		tc:RegisterEffect(e1)
	end
end
-- 判断目标怪兽是否仍处于效果影响范围内
function c38247752.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
