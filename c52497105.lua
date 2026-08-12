--蛮勇鱗粉
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力上升1000，这个回合不能向对方玩家直接攻击。这个回合的结束阶段时，选择的怪兽的攻击力下降2000。
function c52497105.initial_effect(c)
	-- 创建效果对象e1，设置其为魔陷发动效果，具有改变攻击力的Category属性，限制只能在伤害步骤发动，设置触发时机为自由连锁，设置发动条件为aux.dscon函数返回真，设置目标选择函数为c52497105.target，设置发动效果处理函数为c52497105.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置该效果的发动条件为aux.dscon函数，用于限制效果不能在伤害计算后发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c52497105.target)
	e1:SetOperation(c52497105.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数c52497105.filter，用于判断目标怪兽是否满足发动条件：必须表侧表示，且不在伤害步骤或不是攻击怪兽或有攻击目标
function c52497105.filter(c)
	-- 返回值为真，表示该怪兽满足发动条件，即表侧表示，且不在伤害步骤或不是攻击怪兽或有攻击目标
	return c:IsFaceup() and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or c~=Duel.GetAttacker() or Duel.GetAttackTarget())
end
-- 定义效果的目标选择函数c52497105.target，用于选择场上表侧表示的怪兽作为效果对象
function c52497105.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52497105.filter(chkc) end
	-- 检查是否满足发动条件：场上存在满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c52497105.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上满足条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c52497105.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义效果的处理函数c52497105.activate，用于执行效果内容：使目标怪兽攻击力上升1000，不能直接攻击，并在结束阶段时攻击力下降2000
function c52497105.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽的攻击力上升1000，持续到结束阶段
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
		-- 使目标怪兽在本回合不能向对方玩家直接攻击，持续到结束阶段
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 设置一个在结束阶段触发的效果，用于使目标怪兽的攻击力下降2000
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCountLimit(1)
		e3:SetOperation(c52497105.atkdown)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 定义结束阶段时触发的效果处理函数c52497105.atkdown，用于使目标怪兽的攻击力下降2000
function c52497105.atkdown(e,tp,eg,ep,ev,re,r,rp)
	-- 使目标怪兽的攻击力下降2000，持续到结束阶段
	local e1=Effect.CreateEffect(e:GetOwner())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e:GetHandler():RegisterEffect(e1,true)
end
