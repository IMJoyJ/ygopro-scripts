--超音速波
-- 效果：
-- 自己回合选择场上1只名字带有「幻兽机」的怪兽才能发动。选择的怪兽在这个回合，攻击力变成原本攻击力的2倍，不受这张卡以外的魔法·陷阱卡的效果影响，向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。那之后，这个回合的结束阶段时自己场上的机械族怪兽全部破坏。这张卡发动的回合，选择的怪兽以外的怪兽不能攻击。
function c93211810.initial_effect(c)
	-- 自己回合选择场上1只名字带有「幻兽机」的怪兽才能发动。选择的怪兽在这个回合，攻击力变成原本攻击力的2倍，不受这张卡以外的魔法·陷阱卡的效果影响，向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。那之后，这个回合的结束阶段时自己场上的机械族怪兽全部破坏。这张卡发动的回合，选择的怪兽以外的怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c93211810.condition)
	e1:SetCost(c93211810.cost)
	e1:SetTarget(c93211810.target)
	e1:SetOperation(c93211810.activate)
	c:RegisterEffect(e1)
	if not c93211810.global_check then
		c93211810.global_check=true
		c93211810[0]=0
		c93211810[1]=0
		-- 这张卡发动的回合，选择的怪兽以外的怪兽不能攻击。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c93211810.checkop)
		-- 注册全局效果，用于记录本回合各玩家怪兽的攻击宣言次数。
		Duel.RegisterEffect(ge1,0)
		-- 这张卡发动的回合，选择的怪兽以外的怪兽不能攻击。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c93211810.clear)
		-- 注册全局效果，在每个回合开始时重置攻击宣言记录。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 攻击宣言时的操作：如果该怪兽本回合未进行过攻击宣言，则给该怪兽添加标记，并使对应玩家的攻击宣言次数加1。
function c93211810.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:GetFlagEffect(93211810)==0 then
		c93211810[ep]=c93211810[ep]+1
		tc:RegisterFlagEffect(93211810,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 重置函数：将双方玩家的攻击宣言次数清零。
function c93211810.clear(e,tp,eg,ep,ev,re,r,rp)
	c93211810[0]=0
	c93211810[1]=0
end
-- 发动条件：自己回合的主要阶段1或战斗阶段，且不在伤害计算后。
function c93211810.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判定当前是否为自己回合、阶段是否在主要阶段2之前，且不在伤害计算后。
	return Duel.GetTurnPlayer()==tp and ph<PHASE_MAIN2 and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 发动代价判定：本回合自己场上进行过攻击宣言的怪兽数量必须小于2（若已有其他怪兽攻击过，则不能发动）。
function c93211810.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c93211810[tp]<2 end
end
-- 过滤条件：场上表侧表示的名字带有「幻兽机」的怪兽，且若本回合已有怪兽攻击过，则该怪兽必须是那只进行过攻击的怪兽。
function c93211810.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x101b) and (c93211810[tp]==0 or c:GetFlagEffect(93211810)~=0)
end
-- 效果的目标选择与限制：选择1只符合条件的「幻兽机」怪兽作为对象，并注册“选择的怪兽以外的怪兽不能攻击”的限制效果。
function c93211810.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c93211810.filter(chkc,tp) end
	-- 判定场上是否存在可以作为对象的表侧表示「幻兽机」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c93211810.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只表侧表示的「幻兽机」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c93211810.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 这张卡发动的回合，选择的怪兽以外的怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c93211810.ftarget)
	e1:SetLabel(g:GetFirst():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，限制本回合除选择的怪兽以外的怪兽不能进行攻击。
	Duel.RegisterEffect(e1,tp)
end
-- 攻击限制的目标过滤：过滤出除选择的怪兽以外的其他怪兽。
function c93211810.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 效果处理：使选择的怪兽攻击力翻倍、获得穿防效果、获得魔陷免疫，并注册回合结束阶段破坏自己场上所有机械族怪兽的效果。
function c93211810.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽在这个回合，攻击力变成原本攻击力的2倍
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 不受这张卡以外的魔法·陷阱卡的效果影响
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetValue(c93211810.efilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		-- 那之后，这个回合的结束阶段时自己场上的机械族怪兽全部破坏。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetCountLimit(1)
		e4:SetCondition(c93211810.descon)
		e4:SetOperation(c93211810.desop)
		e4:SetReset(RESET_PHASE+PHASE_END)
		-- 注册在回合结束阶段触发的全局效果，用于破坏自己场上的机械族怪兽。
		Duel.RegisterEffect(e4,tp)
	end
end
-- 免疫效果的过滤条件：过滤出这张卡以外的魔法·陷阱卡的效果。
function c93211810.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwner()~=e:GetOwner()
end
-- 破坏效果的过滤条件：自己场上表侧表示的机械族怪兽。
function c93211810.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 结束阶段破坏效果的触发条件：自己场上存在表侧表示的机械族怪兽。
function c93211810.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的机械族怪兽。
	return Duel.IsExistingMatchingCard(c93211810.desfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 结束阶段破坏效果的处理：获取并破坏自己场上所有的机械族怪兽。
function c93211810.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的机械族怪兽。
	local g=Duel.GetMatchingGroup(c93211810.desfilter,tp,LOCATION_MZONE,0,nil)
	-- 破坏获取到的机械族怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
