--巨星墜とし
-- 效果：
-- 不能对应这张卡的发动让不持有等级的怪兽的效果发动。
-- ①：以不持有等级的场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽直到回合结束时攻击力变成0，不能把效果发动，不会被战斗破坏。这个回合，那只表侧表示怪兽的战斗发生的对双方的战斗伤害变成一半。
function c43986064.initial_effect(c)
	-- 效果发动条件：以不持有等级的场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	-- 限制效果不能在伤害计算后发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c43986064.target)
	e1:SetOperation(c43986064.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断目标是否为表侧表示且等级为0的怪兽。
function c43986064.filter(c)
	return c:IsFaceup() and c:IsLevel(0)
end
-- 效果处理函数：选择目标怪兽并设置连锁限制。
function c43986064.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c43986064.filter(chkc) end
	-- 判断是否满足选择目标的条件。
	if chk==0 then return Duel.IsExistingTarget(c43986064.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,c43986064.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制，防止怪兽效果被连锁。
		Duel.SetChainLimit(c43986064.chainlm)
	end
end
-- 连锁限制函数：禁止等级为0的怪兽发动效果。
function c43986064.chainlm(e,rp,tp)
	return not (e:GetHandler():IsType(TYPE_MONSTER) and e:GetHandler():IsLevel(0))
end
-- 效果发动处理函数：对目标怪兽施加效果。
function c43986064.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 效果原文内容：直到回合结束时攻击力变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果原文内容：不能把效果发动，不会被战斗破坏。这个回合，那只表侧表示怪兽的战斗发生的对双方的战斗伤害变成一半。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2,true)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e3:SetValue(1)
		tc:RegisterEffect(e3)
		local e4=e2:Clone()
		e4:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
		e4:SetValue(HALF_DAMAGE)
		tc:RegisterEffect(e4)
	end
end
