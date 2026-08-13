--The blazing MARS
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，从自己墓地把这张卡以外的3只怪兽除外才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
-- ②：自己主要阶段1，把自己场上的其他怪兽全部送去墓地才能发动。给与对方为送去墓地的怪兽数量×500伤害。
function c15033525.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，从自己墓地把这张卡以外的3只怪兽除外才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15033525,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCost(c15033525.spcost)
	e1:SetTarget(c15033525.sptg)
	e1:SetOperation(c15033525.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段1，把自己场上的其他怪兽全部送去墓地才能发动。给与对方为送去墓地的怪兽数量×500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15033525,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,15033525)
	e2:SetCondition(c15033525.damcon)
	e2:SetCost(c15033525.damcost)
	e2:SetTarget(c15033525.damtg)
	e2:SetOperation(c15033525.damop)
	c:RegisterEffect(e2)
end
-- 筛选可作为除外代价的怪兽卡（需是怪兽且能作为代价除外）。
function c15033525.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ①效果的代价：从自己墓地选择这张卡以外的3只怪兽除外。若在检查阶段则确认是否有3张可除外的怪兽；实际执行时选择3张并除外。
function c15033525.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价确认：检查自己墓地是否存在3张满足条件的怪兽（且不包含这张卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(c15033525.costfilter,tp,LOCATION_GRAVE,0,3,e:GetHandler()) end
	-- 向玩家显示选择提示，要求选择要除外的卡（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择3张满足costfilter的怪兽卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c15033525.costfilter,tp,LOCATION_GRAVE,0,3,3,e:GetHandler())
	-- 将选中的卡以表侧表示除外，作为发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的目标：确认自己主要怪兽区有空位，且这张卡可以被特殊召唤。满足条件时发动效果并设置特殊召唤的操作信息。
function c15033525.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时的操作信息：将这张卡特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果相关，将其特殊召唤；然后给自己附加直到回合结束不能特殊召唤怪兽的限制。
function c15033525.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的主要怪兽区（无视苏生限制等条件检查）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。②：自己主要阶段1，把自己场上的其他怪兽全部送去墓地才能发动。给与对方为送去墓地的怪兽数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将为发动①效果后附加的‘不能特殊召唤’限制效果注册到当前玩家（持续到回合结束）。
	Duel.RegisterEffect(e1,tp)
end
-- ②效果的发动条件：当前为自己主要阶段1。
function c15033525.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段1。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 过滤出原始类型包含怪兽的卡（用于统计送去墓地的怪兽数量）。
function c15033525.stfilter(c)
	return c:GetOriginalType()&(TYPE_MONSTER)~=0
end
-- ②效果的代价：把自己场上的其他怪兽全部送去墓地，并记录被送去墓地的怪兽数量。若在检查阶段，确认存在怪兽且场上其他卡都能作为代价送去墓地。
function c15033525.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上主要怪兽区的所有卡（包括自身和其他卡）。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	g:RemoveCard(e:GetHandler())
	local mg=g:Filter(c15033525.stfilter,nil)
	-- 检查是否存在可送入墓地的怪兽（排除自身后），且场上所有其他卡都能作为代价送去墓地。
	if chk==0 then return #mg>0 and not g:IsExists(aux.NOT(Card.IsAbleToGraveAsCost),1,nil) end
	-- 把自己场上的其他所有卡（除自身外）送去墓地，作为发动代价。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(mg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE))
end
-- ②效果的目标：以对方玩家为对象，设置伤害数值为（送去墓地的怪兽数量×500），并设定伤害操作信息。
function c15033525.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果对象玩家设置为对方（1-tp），表示伤害对象为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 将效果参数设置为：此前记录的怪兽数量×500，作为伤害数值。
	Duel.SetTargetParam(e:GetLabel()*500)
	-- 设置操作信息为对对方造成该数值的伤害（CATEGORY_DAMAGE）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel()*500)
end
-- ②效果处理：根据记录的对象玩家和伤害数值，给对方造成效果伤害。
function c15033525.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中读取目标玩家和伤害参数（由目标阶段设置）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成对应伤害，伤害原因为效果（REASON_EFFECT）。
	Duel.Damage(p,d,REASON_EFFECT)
end
