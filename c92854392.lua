--立ちはだかる強敵
-- 效果：
-- 对方进行攻击宣言时这张卡才能发动。选择自己场上1张表侧表示的怪兽。这张卡发动回合，对方只能以所选择的这只怪兽为攻击对象，且必须用所有表侧攻击表示的怪兽攻击所选择的这只怪兽。
function c92854392.initial_effect(c)
	-- 对方进行攻击宣言时这张卡才能发动。选择自己场上1张表侧表示的怪兽。这张卡发动回合，对方只能以所选择的这只怪兽为攻击对象，且必须用所有表侧攻击表示的怪兽攻击所选择的这只怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c92854392.condition)
	e1:SetTarget(c92854392.target)
	e1:SetOperation(c92854392.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件（对方回合的攻击宣言时）。
function c92854392.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方。
	return Duel.GetTurnPlayer()~=tp
end
-- 选择自己场上1张表侧表示的怪兽作为效果对象，且该怪兽不能是当前被攻击的怪兽。
function c92854392.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前被攻击的怪兽。
	local at=Duel.GetAttackTarget()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc~=at end
	-- 在发动阶段，检查自己场上是否存在除当前被攻击怪兽以外的表侧表示怪兽作为可选对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,at) end
	-- 给玩家发送提示信息，提示选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1张除当前被攻击怪兽以外的表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,at)
end
-- 效果处理，使对方在当前回合只能且必须用所有表侧攻击表示怪兽攻击所选择的怪兽，并强制转移当前的攻击对象。
function c92854392.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为攻击对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local fid=tc:GetRealFieldID()
		-- 这张卡发动回合，对方只能以所选择的这只怪兽为攻击对象，且必须用所有表侧攻击表示的怪兽攻击所选择的这只怪兽。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		-- 注册全局效果，强制对方怪兽在战斗阶段必须进行攻击。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e2:SetValue(c92854392.atklimit)
		e2:SetLabel(fid)
		-- 注册全局效果，限制对方怪兽若攻击则必须以所选择的怪兽为攻击对象。
		Duel.RegisterEffect(e2,tp)
		-- 将当前的攻击对象转移为所选择的怪兽。
		Duel.ChangeAttackTarget(tc)
	end
end
-- 限制攻击对象的目标过滤函数，判断攻击目标是否为所选择的怪兽（通过比较FieldID）。
function c92854392.atklimit(e,c)
	return c:GetRealFieldID()==e:GetLabel()
end
