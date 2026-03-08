--ホールディング・アームズ
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象发动。这只怪兽表侧表示存在期间，作为对象的表侧表示怪兽不能攻击，效果无效化。
-- ②：只要这张卡的①的效果作为对象的怪兽在场上存在，这张卡不会被战斗·效果破坏。
function c43730887.initial_effect(c)
	-- 效果原文：①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象发动。这只怪兽表侧表示存在期间，作为对象的表侧表示怪兽不能攻击，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43730887,0))  --"选择怪兽不能攻击，效果无效化"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c43730887.target)
	e1:SetOperation(c43730887.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 效果原文：②：只要这张卡的①的效果作为对象的怪兽在场上存在，这张卡不会被战斗·效果破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e6:SetCondition(c43730887.indcon)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e7)
end
-- 选择对方场上一只表侧表示的怪兽作为效果对象。
function c43730887.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 提示玩家选择一张表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上选择一只表侧表示的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表示将使目标怪兽效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 将目标怪兽效果无效并使其不能攻击。
function c43730887.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 给目标怪兽添加效果无效效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c43730887.rcon)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		tc:RegisterEffect(e2)
	end
end
-- 判断目标怪兽是否仍存在于场上。
function c43730887.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
-- 判断拘束臂是否已选择目标怪兽。
function c43730887.indcon(e)
	return e:GetHandler():GetFirstCardTarget()~=nil
end
