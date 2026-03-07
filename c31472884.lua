--共闘
-- 效果：
-- 这张卡发动的回合，自己怪兽不能直接攻击。
-- ①：从手卡丢弃1只怪兽，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时变成和为这张卡发动而丢弃的怪兽的各自数值相同。
function c31472884.initial_effect(c)
	-- 创建此卡的发动效果，设置其为永续效果，具有取对象和伤害步骤发动的属性，且为自由连锁时点
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置此效果的发动条件为aux.dscon，即不能在伤害计算后发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c31472884.cost)
	e1:SetTarget(c31472884.target)
	e1:SetOperation(c31472884.activate)
	c:RegisterEffect(e1)
	if not c31472884.global_check then
		c31472884.global_check=true
		-- 创建一个全局持续效果，用于监听攻击宣言事件
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c31472884.check)
		-- 将上述创建的攻击宣言监听效果注册到全局环境，由玩家0（通常是游戏开始的玩家）拥有
		Duel.RegisterEffect(ge1,0)
	end
end
-- 定义攻击宣言时的处理函数，用于记录当前玩家是否已经进行过攻击宣言
function c31472884.check(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 判断当前攻击是否没有目标怪兽
	if Duel.GetAttackTarget()==nil then
		-- 为当前攻击玩家注册一个标识效果，用于标记其在本回合已进行过攻击宣言
		Duel.RegisterFlagEffect(tc:GetControler(),31472884,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 定义用于筛选可丢弃的怪兽的过滤函数，要求为怪兽卡、可丢弃、攻击力和守备力非负，并且场上存在满足条件的目标怪兽
function c31472884.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable() and c:GetAttack()>=0 and c:GetDefense()>=0
		-- 检查是否存在满足tgfilter条件的场上怪兽，用于确保丢弃的怪兽能有目标怪兽进行数值转移
		and Duel.IsExistingTarget(c31472884.tgfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
-- 定义用于筛选目标怪兽的过滤函数，要求目标怪兽为表侧表示，且其攻击力或守备力与丢弃的怪兽不同
function c31472884.tgfilter(c,dc)
	return c:IsFaceup() and (not c:IsAttack(dc:GetAttack()) or not c:IsDefense(dc:GetDefense()))
end
-- 定义此卡发动时的费用处理函数，设置标签为1表示已支付费用
function c31472884.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 定义此卡发动时的目标选择处理函数，包括丢弃手牌和选择目标怪兽
function c31472884.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and c31472884.tgfilter(chkc,e:GetLabelObject()) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查当前玩家是否已在此回合发动过此卡，防止重复发动
		return Duel.GetFlagEffect(tp,31472884)==0
			-- 检查手牌中是否存在满足cfilter条件的怪兽，用于丢弃作为发动代价
			and Duel.IsExistingMatchingCard(c31472884.cfilter,tp,LOCATION_HAND,0,1,nil)
	end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足cfilter条件的1张手牌并将其送入墓地作为发动代价
	local g=Duel.SelectMatchingCard(tp,c31472884.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手牌送入墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	-- 提示玩家选择要作为目标的表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足tgfilter条件的1只场上怪兽作为目标
	Duel.SelectTarget(tp,c31472884.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g:GetFirst())
	e:SetLabelObject(g:GetFirst())
	-- 创建一个影响全场怪兽的永续效果，禁止其直接攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将禁止直接攻击的效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义此卡发动后的处理函数，用于设置目标怪兽的攻击力和守备力
function c31472884.activate(e,tp,eg,ep,ev,re,r,rp)
	local cc=e:GetLabelObject()
	local atk=cc:GetAttack()
	local def=cc:GetDefense()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个用于设置目标怪兽攻击力的临时效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 创建一个用于设置目标怪兽守备力的临时效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(def)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
