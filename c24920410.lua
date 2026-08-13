--オーバー・レンチ
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「发条」的怪兽发动。选择的怪兽的攻击力·守备力变成2倍，这个回合的结束阶段时回到手卡。「过度猛拧」在1回合只能发动1张。
function c24920410.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「发条」的怪兽发动。选择的怪兽的攻击力·守备力变成2倍，这个回合的结束阶段时回到手卡。「过度猛拧」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,24920410+EFFECT_COUNT_CODE_OATH)
	-- 设置效果发动条件：限制在伤害步骤内只能在伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c24920410.target)
	e1:SetOperation(c24920410.activate)
	c:RegisterEffect(e1)
end
-- 定义选择对象时的过滤条件：表侧表示且卡名带有「发条」的怪兽。
function c24920410.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x58)
end
-- 发动时的取对象处理：检查合法对象、给出选择提示，并从自己场上选择1只表侧表示的名字带有「发条」的怪兽作为对象。
function c24920410.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c24920410.filter(chkc) end
	-- 发动条件检查：确认自己场上存在满足条件的表侧表示「发条」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c24920410.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示选择表侧表示卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1张表侧表示且名字带有「发条」的怪兽作为效果对象。
	Duel.SelectTarget(tp,c24920410.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：将对象怪兽的攻击力与守备力变为2倍，并于结束阶段将其返回手卡。
function c24920410.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁上被选择为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()*2
		local def=tc:GetDefense()*2
		-- 攻击力·守备力变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
		-- 攻击力·守备力变成2倍。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(def)
		tc:RegisterEffect(e2)
		-- 这个回合的结束阶段时回到手卡。
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
-- 结束阶段触发时的处理：将持有该效果的怪兽返回持有者手卡。
function c24920410.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对象怪兽以效果原因送回持有者手卡。
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
