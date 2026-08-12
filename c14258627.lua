--地球巨人 ガイア・プレート
-- 效果：
-- 这张卡的控制者在每次自己准备阶段从自己墓地把1只岩石族怪兽除外。或者不除外让这张卡送去墓地。
-- ①：这张卡可以把自己墓地2只岩石族怪兽除外，从手卡特殊召唤。
-- ②：和这张卡进行战斗的对方怪兽的攻击力·守备力只在伤害计算时变成一半。
function c14258627.initial_effect(c)
	-- ①：这张卡可以把自己墓地2只岩石族怪兽除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c14258627.spcon)
	e1:SetTarget(c14258627.sptg)
	e1:SetOperation(c14258627.spop)
	c:RegisterEffect(e1)
	-- ②：和这张卡进行战斗的对方怪兽的攻击力·守备力只在伤害计算时变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_ATTACK_FINAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c14258627.adcon)
	e2:SetTarget(c14258627.adtg)
	e2:SetValue(c14258627.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e3:SetValue(c14258627.defval)
	c:RegisterEffect(e3)
	-- 这张卡的控制者在每次自己准备阶段从自己墓地把1只岩石族怪兽除外。或者不除外让这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c14258627.mtcon)
	e4:SetOperation(c14258627.mtop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断墓地中的岩石族怪兽是否可以除外作为代价。
function c14258627.filter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToRemoveAsCost()
end
-- 判断特殊召唤条件是否满足，即是否有足够的怪兽区域和2只岩石族怪兽除外。
function c14258627.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家的怪兽区域是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查当前玩家墓地是否存在至少2只岩石族怪兽。
		and Duel.IsExistingMatchingCard(c14258627.filter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 设置特殊召唤的目标选择函数，用于选择2只岩石族怪兽除外。
function c14258627.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家墓地中所有满足条件的岩石族怪兽。
	local g=Duel.GetMatchingGroup(c14258627.filter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家提示选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 设置特殊召唤的操作函数，用于执行除外2只岩石族怪兽并特殊召唤。
function c14258627.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的岩石族怪兽从墓地除外，作为特殊召唤的代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断是否处于伤害计算阶段且有战斗对手。
function c14258627.adcon(e)
	-- 判断是否处于伤害计算阶段且当前卡有战斗对手。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and e:GetHandler():GetBattleTarget()
end
-- 设置攻击值调整的目标函数，用于指定哪些怪兽的攻击值会被调整。
function c14258627.adtg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
-- 设置攻击值调整的计算函数，将目标怪兽的攻击值减半。
function c14258627.atkval(e,c)
	return math.ceil(c:GetAttack()/2)
end
-- 设置守备值调整的计算函数，将目标怪兽的守备值减半。
function c14258627.defval(e,c)
	return math.ceil(c:GetDefense()/2)
end
-- 判断是否为当前回合玩家的准备阶段。
function c14258627.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为该卡的控制者。
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段效果的操作函数，用于处理墓地除外或送去墓地。
function c14258627.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家墓地是否存在至少1只岩石族怪兽。
	if Duel.IsExistingMatchingCard(c14258627.filter,tp,LOCATION_GRAVE,0,1,nil)
		-- 询问玩家是否要除外墓地中的1只岩石族怪兽。
		and Duel.SelectYesNo(tp,aux.Stringid(14258627,0)) then  --"是否要把墓地的一只岩石族怪兽除外？"
		-- 向玩家提示选择要除外的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		-- 选择1只岩石族怪兽从墓地除外。
		local g=Duel.SelectMatchingCard(tp,c14258627.filter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的岩石族怪兽从墓地除外，作为准备阶段的代价。
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	else
		-- 将该卡送去墓地，作为不除外的后果。
		Duel.SendtoGrave(e:GetHandler(),REASON_RULE)
	end
end
