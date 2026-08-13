--ホールディング・アームズ
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象发动。这只怪兽表侧表示存在期间，作为对象的表侧表示怪兽不能攻击，效果无效化。
-- ②：只要这张卡的①的效果作为对象的怪兽在场上存在，这张卡不会被战斗·效果破坏。
function c43730887.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象发动。这只怪兽表侧表示存在期间，作为对象的表侧表示怪兽不能攻击，效果无效化。
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
	-- ②：只要这张卡的①的效果作为对象的怪兽在场上存在，这张卡不会被战斗·效果破坏。
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
-- ①效果的取对象判定与发动准备：在连锁确认时，对象必须为对方场上表侧表示怪兽；发动时选择对方场上1只表侧表示怪兽作为对象，并登记无效化操作信息。
function c43730887.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 向操作玩家显示“请选择表侧表示的卡”的提示消息，用于引导玩家选择对象卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上选择1张表侧表示怪兽作为效果对象，并自动将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将本次效果处理的分类登记为无效化（CATEGORY_DISABLE），对象为所选的1只怪兽，供系统进行效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理：若本卡与对象怪兽均未离场且仍与效果关联、对象表侧表示且不免疫此效果，则将对象设为本卡的永续对象，并给对象附加‘效果无效化’与‘不能攻击’的效果。
function c43730887.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得此效果发动时选择的对象怪兽（即当前连锁的第一个目标）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 这只怪兽表侧表示存在期间，作为对象的表侧表示怪兽不能攻击，效果无效化。
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
-- 该效果（无效化/不能攻击）的持续条件：检查效果所有者（拘束臂）是否仍将拥有此效果的怪兽作为永续对象，若仍保持对象关系则效果继续适用。
function c43730887.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
-- ②效果的适用条件：检查这张卡是否存在永续对象（即①效果选择的对方怪兽仍作为这张卡的永续对象存在于场上），存在时返回真，使这张卡获得不会被战斗·效果破坏的抗性。
function c43730887.indcon(e)
	return e:GetHandler():GetFirstCardTarget()~=nil
end
