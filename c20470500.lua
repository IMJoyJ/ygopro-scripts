--アームズ・シーハンター
-- 效果：
-- 自己场上有这张卡以外的水属性怪兽表侧表示存在的场合，和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化。这张卡被破坏的场合，可以作为代替把自己场上表侧表示存在的1只3星以下的水属性怪兽破坏。
function c20470500.initial_effect(c)
	-- 效果原文：自己场上有这张卡以外的水属性怪兽表侧表示存在的场合，和这张卡进行战斗的效果怪兽的效果在伤害计算后无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20470500,0))  --"效果无效"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c20470500.condition)
	e1:SetOperation(c20470500.operation)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡被破坏的场合，可以作为代替把自己场上表侧表示存在的1只3星以下的水属性怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c20470500.desreptg)
	e2:SetOperation(c20470500.desrepop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否存在表侧表示的水属性怪兽。
function c20470500.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 条件函数：判断是否满足效果发动条件，即战斗怪兽为效果怪兽且自己场上有其他水属性怪兽。
function c20470500.condition(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	-- 判断战斗怪兽是否为效果怪兽，并且自己场上有其他水属性怪兽。
	return bc and bc:IsType(TYPE_EFFECT) and Duel.IsExistingMatchingCard(c20470500.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果处理函数：使战斗怪兽的效果无效。
function c20470500.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	-- 使战斗怪兽的效果无效。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x57a0000)
	bc:RegisterEffect(e1)
	-- 使战斗怪兽的效果无效。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x57a0000)
	bc:RegisterEffect(e2)
end
-- 代替破坏的过滤函数：检查场上是否存在表侧表示、3星以下、水属性且可被破坏的怪兽。
function c20470500.repfilter(c,e)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsDestructable(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代替破坏的条件判断函数：检查是否满足代替破坏的条件。
function c20470500.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE)
		-- 检查场上是否存在满足代替破坏条件的怪兽。
		and Duel.IsExistingMatchingCard(c20470500.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问玩家是否发动代替破坏效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择代替破坏的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择满足条件的1只怪兽作为代替破坏对象。
		local g=Duel.SelectMatchingCard(tp,c20470500.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的处理函数：将选中的怪兽破坏。
function c20470500.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选中的怪兽以效果和代替破坏的原因进行破坏。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
