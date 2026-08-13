--ダーク・アイズ・イリュージョニスト
-- 效果：
-- 反转：这张卡场上存在的时候，指定的1只怪兽永续不能攻击。
function c38247752.initial_effect(c)
	-- 反转：这张卡场上存在的时候，指定的1只怪兽永续不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38247752,0))  --"攻击限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c38247752.target)
	e1:SetOperation(c38247752.operation)
	c:RegisterEffect(e1)
end
-- 反转效果的发动处理：判定对象是否合法（对方场上表侧表示怪兽），并选择1只作为效果对象。
function c38247752.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 向玩家发出选择对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让当前玩家从对方主要怪兽区选择1只表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 效果处理阶段：确认发动者仍与效果关联、对象仍与效果关联且对象不免疫此效果时，将对象设为该卡的永续对象，并给对象附加上不能攻击的效果。
function c38247752.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 指定的1只怪兽永续不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c38247752.rcon)
		tc:RegisterEffect(e1)
	end
end
-- 设置“不能攻击”效果的持续条件：仅当效果持有者（暗眼幻想师）仍然以该怪兽作为永续对象时，该怪兽不能攻击。
function c38247752.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
