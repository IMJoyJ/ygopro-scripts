--奇跡の軌跡
-- 效果：
-- 选择自己场上表侧攻击表示存在的1只怪兽发动。对方从卡组抽1张卡。直到这个回合的结束阶段时，选择怪兽的攻击力上升1000，同1次的战斗阶段中最多2次可以向怪兽攻击。那只怪兽进行战斗的场合，对方玩家受到的战斗伤害变成0。
function c97168905.initial_effect(c)
	-- 选择自己场上表侧攻击表示存在的1只怪兽发动。对方从卡组抽1张卡。直到这个回合的结束阶段时，选择怪兽的攻击力上升1000，同1次的战斗阶段中最多2次可以向怪兽攻击。那只怪兽进行战斗的场合，对方玩家受到的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件为不在伤害步骤或在伤害步骤的伤害计算前
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c97168905.target)
	e1:SetOperation(c97168905.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的目标选择与合法性检测函数
function c97168905.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsPosition(POS_FACEUP_ATTACK) end
	-- 在发动准备阶段，检查对方玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1)
		-- 并检查自己场上是否存在表侧攻击表示的怪兽
		and Duel.IsExistingTarget(Card.IsPosition,tp,LOCATION_MZONE,0,1,nil,POS_FACEUP_ATTACK) end
	-- 在界面上提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只表侧攻击表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsPosition,tp,LOCATION_MZONE,0,1,1,nil,POS_FACEUP_ATTACK)
	-- 设置效果处理信息，声明此效果包含对方玩家抽1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 定义效果处理的执行函数
function c97168905.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 对方玩家因效果从卡组抽1张卡
	Duel.Draw(1-tp,1,REASON_EFFECT)
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 直到这个回合的结束阶段时，选择怪兽的攻击力上升1000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
		-- 同1次的战斗阶段中最多2次可以向怪兽攻击。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		-- 那只怪兽进行战斗的场合，对方玩家受到的战斗伤害变成0。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
