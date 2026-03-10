--H・C スパルタス
-- 效果：
-- 1回合1次，对方怪兽的攻击宣言时选择这张卡以外的自己场上1只名字带有「英豪」的怪兽才能发动。这张卡的攻击力直到战斗阶段结束时上升选择的怪兽的原本攻击力数值。
function c50491121.initial_effect(c)
	-- 创建一个字段诱发即时效果，用于在对方怪兽攻击宣言时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50491121,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1)
	e1:SetCondition(c50491121.atkcon)
	e1:SetTarget(c50491121.atktg)
	e1:SetOperation(c50491121.atkop)
	c:RegisterEffect(e1)
end
-- 判断当前回合玩家是否为非使用者
function c50491121.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当对方怪兽攻击宣言时，该效果才能发动
	return Duel.GetTurnPlayer()~=tp
end
-- 定义过滤器函数，用于筛选场上表侧表示且名字带有「英豪」的怪兽
function c50491121.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x6f)
end
-- 设置效果的目标选择函数，选择一只符合条件的怪兽作为目标
function c50491121.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50491121.filter(chkc) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c50491121.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示使用者选择一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一只符合条件的场上怪兽作为目标
	Duel.SelectTarget(tp,c50491121.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 设置效果的处理函数，使自身攻击力上升目标怪兽的原本攻击力数值
function c50491121.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果所选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将自身攻击力增加目标怪兽的原本攻击力数值，直到战斗阶段结束
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
