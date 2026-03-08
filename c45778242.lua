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
	-- 筛选场上我方电子界族怪兽作为攻击力上升效果的对象
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
-- 判断是否为通常召唤且为我方回合
function c45778242.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断是否为我方回合且为通常召唤
	return Duel.GetTurnPlayer()==tp and e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 筛选手卡或场上可被破坏的电子界族怪兽作为代替破坏对象
function c45778242.repfilter(c,e)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsRace(RACE_CYBERSE)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 判断是否满足代替破坏条件
function c45778242.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 检查场上是否存在满足条件的代替破坏对象
		and Duel.IsExistingMatchingCard(c45778242.repfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,c,e) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择代替破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择1只满足条件的电子界族怪兽作为代替破坏对象
		local g=Duel.SelectMatchingCard(tp,c45778242.repfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 执行代替破坏操作，将选定怪兽破坏
function c45778242.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选定怪兽以效果破坏的方式进行代替破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
