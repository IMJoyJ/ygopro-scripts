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
-- 判断是否为对方回合
function c92854392.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是发动者，则满足条件
	return Duel.GetTurnPlayer()~=tp
end
-- 选择自己场上1张表侧表示的怪兽作为目标
function c92854392.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在至少1张表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1) end
	-- 提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1张自己场上的表侧表示怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1)
end
-- 设置效果发动后的处理，使对方必须攻击所选怪兽
function c92854392.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local fid=tc:GetRealFieldID()
		-- 创建一个影响全场的必须攻击效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		-- 将效果e1注册给对方玩家
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e2:SetValue(c92854392.atklimit)
		e2:SetLabel(fid)
		-- 将效果e2注册给对方玩家
		Duel.RegisterEffect(e2,tp)
		-- 强制改变攻击对象为所选怪兽
		Duel.ChangeAttackTarget(tc)
	end
end
-- 判断攻击怪兽是否为所选怪兽
function c92854392.atklimit(e,c)
	return c:GetRealFieldID()==e:GetLabel()
end
