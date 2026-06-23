--炎舞－「天璇」
-- 效果：
-- 这张卡的发动时，选择自己场上1只兽战士族怪兽。选择的怪兽的攻击力直到结束阶段时上升700。此外，只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升300。
function c44920699.initial_effect(c)
	-- 这张卡的发动时，选择自己场上1只兽战士族怪兽。选择的怪兽的攻击力直到结束阶段时上升700。此外，只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c44920699.target)
	e1:SetOperation(c44920699.activate)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	-- 选择自己场上1只兽战士族怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEASTWARRIOR))
	e3:SetValue(300)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否为表侧表示的兽战士族怪兽
function c44920699.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEASTWARRIOR)
end
-- 选择自己场上1只兽战士族怪兽作为效果对象
function c44920699.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c44920699.filter(chkc) end
	-- 判断是否存在满足条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c44920699.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c44920699.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将选择的怪兽的攻击力直到结束阶段时上升700
function c44920699.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将选择的怪兽的攻击力直到结束阶段时上升700
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(700)
		tc:RegisterEffect(e1)
	end
end
