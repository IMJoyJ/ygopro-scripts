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
-- 发动的条件检查：必须在对方回合（对方进行攻击宣言时）。
function c92854392.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方玩家。
	return Duel.GetTurnPlayer()~=tp
end
-- 效果的发动准备与选择目标：在自己场上选择1只表侧表示的怪兽作为对象。
function c92854392.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在至少1只表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1) end
	-- 显示提示信息：请选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽作为效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1)
end
-- 效果的处理：限制对方怪兽必须攻击选中的目标怪兽，并将当前攻击转移到该目标上。
function c92854392.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local fid=tc:GetRealFieldID()
		-- 对方只能以所选择的这只怪兽为攻击对象，且必须用所有表侧攻击表示的怪兽攻击所选择的这只怪兽。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		-- 为玩家注册效果：对方场上的怪兽在战斗阶段必须进行攻击。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e2:SetValue(c92854392.atklimit)
		e2:SetLabel(fid)
		-- 为玩家注册效果：对方怪兽若攻击则必须选择指定的怪兽作为攻击目标。
		Duel.RegisterEffect(e2,tp)
		-- 将当前的攻击目标转移为选中的目标怪兽。
		Duel.ChangeAttackTarget(tc)
	end
end
-- 必须攻击的目标怪兽校验函数：匹配目标怪兽的真实字段ID（Field ID）。
function c92854392.atklimit(e,c)
	return c:GetRealFieldID()==e:GetLabel()
end
