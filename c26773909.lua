--才呼粉身
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的战斗阶段以自己场上1只表侧表示怪兽为对象才能发动。自己失去那只怪兽的攻击力数值的基本分，那只怪兽的攻击力直到回合结束时变成2倍。这张卡发动的回合，作为对象的怪兽不能直接攻击。
function c26773909.initial_effect(c)
	-- ①：自己·对方的战斗阶段以自己场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,26773909+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c26773909.condition)
	e1:SetTarget(c26773909.target)
	e1:SetOperation(c26773909.activate)
	c:RegisterEffect(e1)
	if not c26773909.global_check then
		c26773909.global_check=true
		-- 这张卡发动的回合，作为对象的怪兽不能直接攻击。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c26773909.checkop)
		-- 注册一个全局的攻击宣言时点效果，用于标记攻击怪兽
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有怪兽攻击宣言时，为该怪兽注册一个标记flag，防止其在本回合再次攻击
function c26773909.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 若该怪兽未被标记且当前无攻击目标，则为其注册标记flag
	if tc:GetFlagEffect(26773909)==0 and Duel.GetAttackTarget()==nil then
		tc:RegisterFlagEffect(26773909,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判断当前是否处于战斗阶段且未在伤害步骤中
function c26773909.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 若当前阶段为战斗阶段开始到战斗阶段结束，并且不在伤害步骤中，则效果可以发动
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 筛选满足条件的场上表侧表示怪兽（攻击力低于玩家当前LP且未被标记）
function c26773909.filter(c,lp)
	return c:IsFaceup() and c:IsAttackBelow(lp) and c:GetFlagEffect(26773909)==0
end
-- 设置效果目标为满足条件的场上表侧表示怪兽
function c26773909.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取玩家当前LP
	local lp=Duel.GetLP(tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c26773909.filter(chkc,lp) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c26773909.filter,tp,LOCATION_MZONE,0,1,nil,lp) end
	-- 提示玩家选择一个表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c26773909.filter,tp,LOCATION_MZONE,0,1,1,nil,lp)
	-- 为选中的怪兽设置不能直接攻击的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	g:GetFirst():RegisterEffect(e1,true)
end
-- 处理效果的发动，使目标怪兽攻击力变为2倍并扣除其攻击力数值的基本分
function c26773909.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 扣除目标怪兽攻击力数值的基本分
		Duel.SetLP(tp,Duel.GetLP(tp)-tc:GetAttack())
		-- 若玩家基本分小于等于0则不继续处理
		if Duel.GetLP(tp)<=0 then return end
		-- 设置目标怪兽的最终攻击力为原本攻击力的2倍
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
