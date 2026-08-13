--巨星墜とし
-- 效果：
-- 不能对应这张卡的发动让不持有等级的怪兽的效果发动。
-- ①：以不持有等级的场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽直到回合结束时攻击力变成0，不能把效果发动，不会被战斗破坏。这个回合，那只表侧表示怪兽的战斗发生的对双方的战斗伤害变成一半。
function c43986064.initial_effect(c)
	-- 对应卡牌效果原文的整体描述：不能对应这张卡的发动让不持有等级的怪兽的效果发动。①：以不持有等级的场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽直到回合结束时攻击力变成0，不能把效果发动，不会被战斗破坏。这个回合，那只表侧表示怪兽的战斗发生的对双方的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	-- 设置效果只能在伤害步骤且伤害计算前满足条件时才能发动，即限制为通常魔法卡的发动时机并适用伤害步骤规则。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c43986064.target)
	e1:SetOperation(c43986064.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：选择表侧表示且等级为0（即不持有等级）的怪兽。
function c43986064.filter(c)
	return c:IsFaceup() and c:IsLevel(0)
end
-- 发动时的目标处理函数：确认对象是对方场上表侧表示且不持有等级的怪兽，选择1只这样的怪兽作为对象，并在发动魔法卡时设置连锁限制以禁止不持有等级的怪兽连锁发动效果。
function c43986064.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c43986064.filter(chkc) end
	-- 发动时检查是否能在场上存在满足条件的表侧表示不持有等级的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c43986064.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择表侧表示怪兽的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让自己选择1只对方场上表侧表示且不持有等级的怪兽作为效果对象。
	Duel.SelectTarget(tp,c43986064.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设定连锁限制，使后续不能连锁发动不持有等级的怪兽的效果。
		Duel.SetChainLimit(c43986064.chainlm)
	end
end
-- 连锁限制函数：如果尝试连锁的效果的发动者是不持有等级的怪兽，则不允许该效果发动。
function c43986064.chainlm(e,rp,tp)
	return not (e:GetHandler():IsType(TYPE_MONSTER) and e:GetHandler():IsLevel(0))
end
-- 效果处理函数：对对象怪兽赋予攻击力变成0、不能发动效果、不会被战斗破坏，以及其战斗伤害减半的多个效果。
function c43986064.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这张卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 对应效果原文“那只表侧表示怪兽直到回合结束时攻击力变成0”。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 对应效果原文“不能把效果发动，不会被战斗破坏。这个回合，那只表侧表示怪兽的战斗发生的对双方的战斗伤害变成一半。”
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
