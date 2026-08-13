--アームズ・シーハンター
-- 效果：
-- 自己场上有这张卡以外的水属性怪兽表侧表示存在的场合，和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化。这张卡被破坏的场合，可以作为代替把自己场上表侧表示存在的1只3星以下的水属性怪兽破坏。
function c20470500.initial_effect(c)
	-- 自己场上有这张卡以外的水属性怪兽表侧表示存在的场合，和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20470500,0))  --"效果无效"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c20470500.condition)
	e1:SetOperation(c20470500.operation)
	c:RegisterEffect(e1)
	-- 这张卡被破坏的场合，可以作为代替把自己场上表侧表示存在的1只3星以下的水属性怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c20470500.desreptg)
	e2:SetOperation(c20470500.desrepop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示且水属性的怪兽。
function c20470500.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 第一效果的发动条件：这张卡进行战斗，且战斗对方怪兽为效果怪兽，并且自己场上有除这张卡以外的表侧表示水属性怪兽存在。
function c20470500.condition(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	-- 战斗对象存在且为效果怪兽，并且自己场上存在至少1只满足 cfilter 的怪兽（不包括这张卡自身）时，条件成立。
	return bc and bc:IsType(TYPE_EFFECT) and Duel.IsExistingMatchingCard(c20470500.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 第一效果处理：对与这张卡战斗的效果怪兽附加怪兽效果无效（EFFECT_DISABLE）和效果无效化（EFFECT_DISABLE_EFFECT），持续到该怪兽离场等重置条件触发为止。
function c20470500.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	-- 对应『和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化』中的怪兽效果无效（EFFECT_DISABLE）处理。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x57a0000)
	bc:RegisterEffect(e1)
	-- 对应『和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化』中的效果无效化（EFFECT_DISABLE_EFFECT）处理。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x57a0000)
	bc:RegisterEffect(e2)
end
-- 代替破坏候选条件：表侧表示、等级3以下、水属性、可被效果破坏，且未被预定破坏。
function c20470500.repfilter(c,e)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsDestructable(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 发动判定：这张卡即将被破坏（且不是因代替破坏而被破坏），并且自己场上存在符合条件的可代替破坏的怪兽。
function c20470500.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE)
		-- 并且自己场上存在至少1张满足 repfilter 的卡（不包括这张卡自身）。
		and Duel.IsExistingMatchingCard(c20470500.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问控制者是否发动代替破坏效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 显示选择提示，让玩家选择要代替破坏的卡（『请选择要代替破坏的卡』）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 从自己场上选择1张满足 repfilter 的怪兽，作为代替破坏的替代品。
		local g=Duel.SelectMatchingCard(tp,c20470500.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 执行代替破坏：清除所选怪兽的预定破坏状态，并把它破坏。
function c20470500.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将所选怪兽以『效果』和『代替』为破坏原因破坏。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
