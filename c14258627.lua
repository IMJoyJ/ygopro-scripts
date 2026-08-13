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
	-- ②：和这张卡进行战斗的对方怪兽的攻击力·守备力只在伤害计算时变成一半。（此处实现攻击力部分）
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
-- 过滤函数：判断卡片是否满足条件——是岩石族怪兽且可以作为代价除外，用于筛选墓地中可除外的岩石族。
function c14258627.filter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则效果的发动条件：当c为空时允许规则询问；否则要求自己场上存在可用的主要怪兽区空格，且墓地至少有2只满足过滤条件的岩石族怪兽。
function c14258627.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否还有可用的主要怪兽区空格，作为从手卡进行特殊召唤的必要条件之一。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 进一步检查自己墓地是否存在至少2只满足过滤条件（岩石族且可除外）的岩石族怪兽，供特殊召唤除外使用。
		and Duel.IsExistingMatchingCard(c14258627.filter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 特殊召唤手续的目标选择函数：从墓地的岩石族怪兽中选择2张作为除外代价；选择成功则保存选择组并返回true，否则返回false。
function c14258627.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己墓地中所有满足条件的岩石族怪兽，构成本次特殊召唤可选的除外候选组。
	local g=Duel.GetMatchingGroup(c14258627.filter,tp,LOCATION_GRAVE,0,nil)
	-- 向操作玩家显示‘请选择要除外的卡’的提示信息，用于选择墓地卡片时的人机提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的处理函数：将之前选择保存的岩石族怪兽除外，完成从手卡特殊召唤的代价处理。
function c14258627.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以表侧表示形式将选中的岩石族怪兽除外，作为从手卡特殊召唤手续的一部分。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ②效果的适用条件：仅在伤害计算阶段且这张卡正在与对方怪兽战斗时，攻击力·守备力减半效果才适用。
function c14258627.adcon(e)
	-- 判断当前阶段是否为伤害计算阶段，且此卡存在战斗对象（即正在进行战斗）。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and e:GetHandler():GetBattleTarget()
end
-- 效果目标过滤：只对与此卡进行战斗的对方怪兽适用攻击力·守备力减半效果。
function c14258627.adtg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
-- 攻击力变化值计算：将目标怪兽当前攻击力除以2后向上取整（即变成一半）。
function c14258627.atkval(e,c)
	return math.ceil(c:GetAttack()/2)
end
-- 守备力变化值计算：将目标怪兽当前守备力除以2后向上取整（即变成一半）。
function c14258627.defval(e,c)
	return math.ceil(c:GetDefense()/2)
end
-- 准备阶段效果的触发条件：当前回合玩家是此卡的控制者，即只在控制者的准备阶段触发。
function c14258627.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于效果控制者，确保只在控制者自己的准备阶段处理维持效果。
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段效果处理：如果墓地存在岩石族怪兽且玩家选择除外1张，则执行除外；否则将这张卡自身送去墓地。
function c14258627.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少1只可作为代价除外的岩石族怪兽，以决定是否给出除外的选择。
	if Duel.IsExistingMatchingCard(c14258627.filter,tp,LOCATION_GRAVE,0,1,nil)
		-- 询问玩家是否把墓地1只岩石族怪兽除外（选择‘是’则除外，选‘否’则把此卡送去墓地）。
		and Duel.SelectYesNo(tp,aux.Stringid(14258627,0)) then  --"是否要把墓地的一只岩石族怪兽除外？"
		-- 显示‘请选择要除外的卡’的提示信息，在选择除外怪兽前进行提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家从自己墓地的岩石族怪兽中选择1张卡，作为本次要除外的对象。
		local g=Duel.SelectMatchingCard(tp,c14258627.filter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的岩石族怪兽以表侧表示除外，作为不把此卡送去墓地的代价（cost）。
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	else
		-- 当玩家不除外墓地岩石族怪兽时，将这张卡自身以规则效果送去墓地。
		Duel.SendtoGrave(e:GetHandler(),REASON_RULE)
	end
end
