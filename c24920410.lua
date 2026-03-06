--オーバー・レンチ
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「发条」的怪兽发动。选择的怪兽的攻击力·守备力变成2倍，这个回合的结束阶段时回到手卡。「过度猛拧」在1回合只能发动1张。
function c24920410.initial_effect(c)
	-- 创建效果对象e1，设置为魔法卡发动效果，具有改变攻击力分类，提示在伤害步骤时点发动，具有取对象和伤害步骤发动属性，代码为自由连锁，发动次数限制为1次，条件为aux.dscon，目标函数为c24920410.target，发动效果为c24920410.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,24920410+EFFECT_COUNT_CODE_OATH)
	-- 设置效果发动条件为aux.dscon，即不能在伤害计算后发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c24920410.target)
	e1:SetOperation(c24920410.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于筛选场上表侧表示且名字带有「发条」的怪兽
function c24920410.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x58)
end
-- 目标选择函数，用于选择场上表侧表示的1只名字带有「发条」的怪兽
function c24920410.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c24920410.filter(chkc) end
	-- 检查阶段判断是否满足选择目标条件，即场上存在至少1只名字带有「发条」的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c24920410.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上表侧表示的1只名字带有「发条」的怪兽作为目标
	Duel.SelectTarget(tp,c24920410.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 发动效果函数，对目标怪兽的攻击力和守备力变为2倍，并在结束阶段送回手卡
function c24920410.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()*2
		local def=tc:GetDefense()*2
		-- 设置攻击力变为2倍的效果，该效果在结束阶段重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
		-- 设置守备力变为2倍的效果，该效果在结束阶段重置
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(def)
		tc:RegisterEffect(e2)
		-- 设置在结束阶段将目标怪兽送回手卡的效果，该效果为持续效果，仅触发一次
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetOperation(c24920410.retop)
		tc:RegisterEffect(e3)
	end
end
-- 返回手卡效果的处理函数，用于将目标怪兽送回手卡
function c24920410.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽送回手卡，原因为其效果
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
