--立ちはだかる強敵
-- 效果：
-- 对方进行攻击宣言时这张卡才能发动。选择自己场上1张表侧表示的怪兽。这张卡发动回合，对方只能以所选择的这只怪兽为攻击对象，且必须用所有表侧攻击表示的怪兽攻击所选择的这只怪兽。
function c92854392.initial_effect(c)
	-- 创建一个永续效果，用于在对方攻击宣言时发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c92854392.condition)
	e1:SetTarget(c92854392.target)
	e1:SetOperation(c92854392.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：对方进行攻击宣言时才能发动
function c92854392.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为发动者以外的玩家
	return Duel.GetTurnPlayer()~=tp
end
-- 选择自己场上1张表侧表示的怪兽作为目标
function c92854392.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在至少1张表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1) end
	-- 向玩家提示“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1张自己场上的表侧表示怪兽作为目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1)
end
-- 发动效果：将对方攻击对象限制为所选怪兽，并强制其用所有表侧攻击表示怪兽攻击该怪兽
function c92854392.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local fid=tc:GetRealFieldID()
		-- 设置必须攻击效果，使对方只能攻击所选怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		-- 注册必须攻击效果，使对方只能以所选怪兽为攻击对象
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e2:SetValue(c92854392.atklimit)
		e2:SetLabel(fid)
		-- 注册必须攻击怪兽效果，强制对方所有表侧攻击表示怪兽必须攻击该怪兽
		Duel.RegisterEffect(e2,tp)
		-- 将当前攻击对象变更为所选怪兽
		Duel.ChangeAttackTarget(tc)
	end
end
-- 判断怪兽是否为所选目标怪兽的函数
function c92854392.atklimit(e,c)
	return c:GetRealFieldID()==e:GetLabel()
end
