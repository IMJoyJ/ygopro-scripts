--フェルグラントドラゴン
-- 效果：
-- 这张卡不是从墓地中不能特殊召唤，若没已从场上送去墓地则也不能作从墓地的特殊召唤。
-- ①：这张卡从墓地的特殊召唤成功的场合，以自己墓地1只怪兽为对象发动。这张卡的攻击力上升作为对象的怪兽的等级×200。
function c3954901.initial_effect(c)
	-- 效果原文：这张卡不是从墓地中不能特殊召唤，若没已从场上送去墓地则也不能作从墓地的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c3954901.spcon)
	c:RegisterEffect(e1)
	-- 效果原文：①：这张卡从墓地的特殊召唤成功的场合，以自己墓地1只怪兽为对象发动。这张卡的攻击力上升作为对象的怪兽的等级×200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3954901,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c3954901.atkcon)
	e2:SetTarget(c3954901.atktg)
	e2:SetOperation(c3954901.atkop)
	c:RegisterEffect(e2)
end
-- 规则层面：判断此卡是否从场上被送去墓地后才进行特殊召唤
function c3954901.spcon(e)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 规则层面：判断此卡是否从墓地特殊召唤成功
function c3954901.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 规则层面：选择1只自己墓地的怪兽作为对象
function c3954901.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsLevelAbove(1) end
	if chk==0 then return true end
	-- 规则层面：提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 规则层面：选择满足条件的1只墓地怪兽作为对象
	Duel.SelectTarget(tp,Card.IsLevelAbove,tp,LOCATION_GRAVE,0,1,1,nil,1)
end
-- 规则层面：将对象怪兽的等级×200的数值加到此卡攻击力上
function c3954901.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：获取此连锁中选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 效果原文：这张卡的攻击力上升作为对象的怪兽的等级×200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetLevel()*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
