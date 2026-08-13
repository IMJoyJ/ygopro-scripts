--ものマネ幻想師
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，选择对方场上表侧表示存在的1只怪兽发动。这张卡的攻击力·守备力变成和选择的怪兽的原本的攻击力·守备力相同数值。
function c26376390.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，选择对方场上表侧表示存在的1只怪兽发动。这张卡的攻击力·守备力变成和选择的怪兽的原本的攻击力·守备力相同数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26376390,0))  --"攻守变化"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c26376390.target)
	e1:SetOperation(c26376390.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果发动时的目标选择函数：检查已选择的对象是否为对方场上表侧表示的怪兽；若尚未选择且效果可以发动，则提示玩家选择对方场上表侧表示的1只怪兽作为对象。
function c26376390.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 向当前玩家发送“请选择表侧表示的卡”的提示消息，用于选择卡片时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上的表侧表示怪兽中选择1张作为效果对象，并将该卡设置为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：若这张卡仍在场上且与效果关联、对象怪兽也仍表侧表示且与效果关联，则将这张卡的攻击力和守备力分别设置为对象怪兽原本攻击力和原本守备力。
function c26376390.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中已选择的对象怪兽（第一张目标卡）。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这张卡的攻击力变成和选择的怪兽的原本的攻击力相同数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 这张卡的守备力变成和选择的怪兽的原本的守备力相同数值。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(tc:GetBaseDefense())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e2)
	end
end
