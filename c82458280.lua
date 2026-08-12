--マジック・ホール・ゴーレム
-- 效果：
-- 1回合1次，选择自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽直到结束阶段时攻击力变成一半数值，这个回合可以直接攻击对方玩家。这个效果发动的回合，选择的怪兽以外的怪兽不能攻击。
function c82458280.initial_effect(c)
	-- 1回合1次，选择自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽直到结束阶段时攻击力变成一半数值，这个回合可以直接攻击对方玩家。这个效果发动的回合，选择的怪兽以外的怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82458280,0))  --"直接攻击"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c82458280.condition)
	e1:SetTarget(c82458280.target)
	e1:SetOperation(c82458280.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的阶段限制条件函数，仅在主要阶段1可以发动
function c82458280.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 定义过滤条件，筛选场上表侧表示存在的卡片
function c82458280.filter(c)
	return c:IsFaceup()
end
-- 定义效果发动的对象选择与誓约限制效果注册的目标函数
function c82458280.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c82458280.filter(chkc) end
	-- 在发动效果时，检查自己场上是否存在至少1只表侧表示的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c82458280.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动效果的玩家发送提示信息，要求选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c82458280.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 这个效果发动的回合，选择的怪兽以外的怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c82458280.ftarget)
	e1:SetLabel(g:GetFirst():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册该不能攻击的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤不能攻击的怪兽，排除被选择为效果对象的怪兽（即其他怪兽不能攻击）
function c82458280.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 定义效果处理的执行函数，使选择的怪兽攻击力减半并可以直接攻击
function c82458280.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽直到结束阶段时攻击力变成一半数值
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		tc:RegisterEffect(e1)
		-- 这个回合可以直接攻击对方玩家。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
