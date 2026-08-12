--EMウィップ・バイパー
-- 效果：
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时交换。这个效果在双方的主要阶段才能发动。
function c79967395.initial_effect(c)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时交换。这个效果在双方的主要阶段才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79967395,0))  --"攻守互换"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c79967395.condition)
	e1:SetTarget(c79967395.target)
	e1:SetOperation(c79967395.operation)
	c:RegisterEffect(e1)
end
-- 判定当前阶段是否为双方的主要阶段
function c79967395.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤场上表侧表示且具有守备力数值的怪兽
function c79967395.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 效果发动的对象选择与合法性检测
function c79967395.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c79967395.filter(chkc) end
	-- 在发动阶段检测场上是否存在至少1只符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c79967395.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择表侧表示卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c79967395.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：获取对象怪兽，将其攻击力与守备力数值直到回合结束时进行交换
function c79967395.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 那只怪兽的攻击力·守备力直到回合结束时交换
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end
