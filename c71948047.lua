--REINFORCE！
-- 效果：
-- 这个卡名在规则上也当作「救援ACE队」卡使用。这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1只「救援ACE队」怪兽为对象才能发动。那只自己怪兽在这个回合攻击力·守备力上升1500，不受对方怪兽的效果影响，只有1次不会被战斗破坏。
-- ②：把墓地的这张卡除外，以自己墓地1张「救援ACE队」魔法卡为对象才能发动。那张卡在自己场上盖放。
function c71948047.initial_effect(c)
	-- ①：以自己场上1只「救援ACE队」怪兽为对象才能发动。那只自己怪兽在这个回合攻击力·守备力上升1500，不受对方怪兽的效果影响，只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果在伤害步骤中只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c71948047.target)
	e1:SetOperation(c71948047.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1张「救援ACE队」魔法卡为对象才能发动。那张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,71948047)
	-- 把墓地的这张卡除外作为效果发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c71948047.settg)
	e2:SetOperation(c71948047.setop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示的「救援ACE队」怪兽
function c71948047.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x18b)
end
-- 效果①的发动准备与对象选择
function c71948047.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c71948047.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「救援ACE队」怪兽
	if chk==0 then return Duel.IsExistingTarget(c71948047.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「救援ACE队」怪兽作为效果对象
	Duel.SelectTarget(tp,c71948047.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的处理，为目标怪兽适用攻击力/守备力上升、效果免疫以及战斗破坏抗性
function c71948047.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 那只自己怪兽在这个回合攻击力·守备力上升1500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1500)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		-- 不受对方怪兽的效果影响
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(c71948047.efilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetOwnerPlayer(tp)
		tc:RegisterEffect(e3)
		-- 只有1次不会被战斗破坏
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e4:SetCountLimit(1)
		e4:SetValue(c71948047.valcon)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4)
	end
end
-- 过滤不受影响的效果类型，限定为对方玩家发动的怪兽效果
function c71948047.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
-- 过滤破坏原因，限定为战斗破坏
function c71948047.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 过滤墓地中可以盖放的「救援ACE队」魔法卡
function c71948047.setfilter(c)
	return c:IsSetCard(0x18b) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 效果②的发动准备与对象选择
function c71948047.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c71948047.setfilter(chkc) end
	-- 检查自己墓地是否存在可以盖放的「救援ACE队」魔法卡
	if chk==0 then return Duel.IsExistingTarget(c71948047.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择自己墓地1张「救援ACE队」魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c71948047.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将墓地的卡移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果②的处理，将目标魔法卡在自己场上盖放
function c71948047.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
