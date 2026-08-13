--クラインアント
-- 效果：
-- ①：只要通常召唤的这张卡在怪兽区域存在，自己场上的电子界族怪兽的攻击力·守备力在自己回合内上升500。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己的手卡·场上1只电子界族怪兽破坏。
function c45778242.initial_effect(c)
	-- ①：只要通常召唤的这张卡在怪兽区域存在，自己场上的电子界族怪兽的攻击力·守备力在自己回合内上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c45778242.atkcon)
	-- 设置效果适用对象为持有者场上的电子界族怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_CYBERSE))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己的手卡·场上1只电子界族怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(c45778242.reptg)
	e3:SetOperation(c45778242.repop)
	c:RegisterEffect(e3)
end
-- 判定①效果的适用条件：这张卡以通常召唤方式存在于怪兽区域，且当前为持有者（控制者）的回合。
function c45778242.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 条件成立需满足：当前回合玩家是这张卡的控制者，且这张卡的召唤类型为通常召唤。
	return Duel.GetTurnPlayer()==tp and e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 筛选可代替破坏的卡：自己场上表侧表示或手牌的电子界族怪兽，可被该效果破坏且未被预定破坏。
function c45778242.repfilter(c,e)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsRace(RACE_CYBERSE)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代替破坏效果的发动条件判定与目标选择准备：确认本卡将被战斗或效果破坏且不是由代替破坏引起，并存在可代替破坏的合法对象。
function c45778242.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 检查自己场上或手牌是否存在至少1张满足repfilter条件且不是本卡的电子界族怪兽，作为代替破坏的候选。
		and Duel.IsExistingMatchingCard(c45778242.repfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,c,e) end
	-- 询问控制者是否发动代替破坏效果（选择是才继续）。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 向操作者显示“请选择要代替破坏的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让控制者从自己场上或手牌中选择1只满足repfilter条件且不是本卡的电子界族怪兽作为代替破坏的卡片。
		local g=Duel.SelectMatchingCard(tp,c45778242.repfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的处理：将选定的代替破坏对象从预定破坏状态解除，然后将其破坏，以代替原卡片被破坏。
function c45778242.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果破坏且破坏原因为“代替”破坏选定的电子界族怪兽，从而代替原卡片承受破坏。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
