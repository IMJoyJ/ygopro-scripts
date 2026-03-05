--機皇兵グランエル・アイン
-- 效果：
-- 这张卡的攻击力上升这张卡以外的场上表侧表示存在的名字带有「机皇」的怪兽数量×100的数值。这张卡召唤成功时，可以选择对方场上表侧表示存在的1只怪兽，那只怪兽的攻击力直到结束阶段时变成一半。
function c2137678.initial_effect(c)
	-- 这张卡的攻击力上升这张卡以外的场上表侧表示存在的名字带有「机皇」的怪兽数量×100的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c2137678.val)
	c:RegisterEffect(e1)
	-- 这张卡召唤成功时，可以选择对方场上表侧表示存在的1只怪兽，那只怪兽的攻击力直到结束阶段时变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2137678,0))  --"攻击变成一半"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c2137678.target)
	e2:SetOperation(c2137678.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选场上表侧表示且名字带有「机皇」的怪兽。
function c2137678.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13)
end
-- 计算场上除自身外的「机皇」怪兽数量，并乘以100作为攻击力提升值。
function c2137678.val(e,c)
	-- 返回场上除自身外的「机皇」怪兽数量乘以100的结果。
	return Duel.GetMatchingGroupCount(c2137678.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,c)*100
end
-- 设置选择目标时的处理函数，用于选择对方场上表侧表示的怪兽。
function c2137678.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查是否满足选择目标的条件，即对方场上是否存在表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的一只表侧表示怪兽作为目标。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 设置效果发动时的处理函数，用于将目标怪兽的攻击力变为一半。
function c2137678.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽的攻击力设置为原来的一半，并在结束阶段重置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		tc:RegisterEffect(e1)
	end
end
