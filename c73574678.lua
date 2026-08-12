--アマゾネスの吹き矢兵
-- 效果：
-- 在自己的每1个准备阶段选择对方场上1只怪兽。被选择的怪兽攻击力下降500直到回合结束。
function c73574678.initial_effect(c)
	-- 在自己的每1个准备阶段选择对方场上1只怪兽。被选择的怪兽攻击力下降500直到回合结束。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73574678,0))  --"攻击下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c73574678.condition)
	e1:SetTarget(c73574678.target)
	e1:SetOperation(c73574678.operation)
	c:RegisterEffect(e1)
end
-- 效果的发动条件函数：判断是否满足在自己的准备阶段发动的条件
function c73574678.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 效果的目标选择函数：选择对方场上1只表侧表示的怪兽作为效果对象
function c73574678.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 在客户端显示提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果的执行函数：使作为对象的怪兽攻击力下降500直到回合结束
function c73574678.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在target阶段选择的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 被选择的怪兽攻击力下降500直到回合结束。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
