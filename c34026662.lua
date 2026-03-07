--進化の奇跡
-- 效果：
-- 选择名字带有「进化虫」的怪兽的效果特殊召唤的1只怪兽发动。这个回合，选择的怪兽不会被战斗以及卡的效果破坏。
function c34026662.initial_effect(c)
	-- 效果发动时点为自由时点，且为取对象效果，目标为名字带有「进化虫」的怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c34026662.target)
	e1:SetOperation(c34026662.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断目标是否为表侧表示的怪兽，并且是「进化虫」召唤或特殊召唤的怪兽
function c34026662.filter(c)
	local typ=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)
	return c:IsFaceup() and c:IsSummonType(SUMMON_VALUE_EVOLTILE) or (typ&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x304e))
end
-- 选择目标：选择满足条件的1只表侧表示怪兽作为效果对象
function c34026662.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c34026662.filter(chkc) end
	-- 检查阶段：确认是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c34026662.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示选择：向玩家提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽：从场上选择1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c34026662.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：为选择的怪兽设置不会被战斗破坏和效果破坏的效果
function c34026662.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象：获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 设置不会被战斗破坏的效果：使目标怪兽在本回合内不会被战斗破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
