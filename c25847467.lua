--暗黒界の刺客 カーキ
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合，以场上1只怪兽为对象发动。那只怪兽破坏。
function c25847467.initial_effect(c)
	-- 效果原文内容：①：这张卡被效果从手卡丢弃去墓地的场合，以场上1只怪兽为对象发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25847467,0))  --"把场上1只怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c25847467.descon)
	e1:SetTarget(c25847467.destg)
	e1:SetOperation(c25847467.desop)
	c:RegisterEffect(e1)
end
-- 规则层面操作：判断此卡是否从手卡因效果丢弃至墓地
function c25847467.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 规则层面操作：选择场上一只怪兽作为破坏对象
function c25847467.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	-- 规则层面操作：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面操作：选取场上一只怪兽作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 规则层面操作：设置连锁操作信息，确定破坏效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面操作：执行破坏效果，将指定怪兽破坏
function c25847467.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁的处理目标
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 规则层面操作：将目标怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
