--スペシャル・デュアル・サモン
-- 效果：
-- 选择自己场上表侧表示存在的1只二重怪兽，变成再度召唤的状态。这个回合的结束阶段时，选择的二重怪兽回到手卡。
function c26120084.initial_effect(c)
	-- 效果设置为魔法卡发动，自由连锁，具有取对象效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c26120084.target)
	e1:SetOperation(c26120084.operation)
	c:RegisterEffect(e1)
end
c26120084.has_text_type=TYPE_DUAL
-- 过滤函数：选择表侧表示、二重类型且未处于再度召唤状态的怪兽
function c26120084.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL) and not c:IsDualState()
end
-- 效果处理函数：选择自己场上表侧表示存在的1只二重怪兽作为对象
function c26120084.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c26120084.filter(chkc) end
	-- 检查阶段：确认场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c26120084.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c26120084.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动处理函数：使选择的怪兽进入再度召唤状态，并在结束阶段将其送回手卡
function c26120084.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c26120084.filter(tc) then
		tc:EnableDualState()
		-- 在结束阶段时，将对象怪兽送回手卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetOperation(c26120084.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
-- 结束阶段处理函数：将对象怪兽送回手卡
function c26120084.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对象怪兽送回手卡，原因效果
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
