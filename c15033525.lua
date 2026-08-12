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
	-- ②：自己主要阶段1，把自己场上的其他怪兽全部送去墓地才能发动。给与对方为送去墓地的怪兽数量×500伤害。
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
-- 用于筛选可以作为除外代价的怪兽（必须是怪兽卡且可以除外）
function c15033525.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 检查是否满足除外3张墓地怪兽的条件，并选择并除外这些怪兽
function c15033525.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外3张墓地怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c15033525.costfilter,tp,LOCATION_GRAVE,0,3,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择满足条件的3张墓地怪兽
	local g=Duel.SelectMatchingCard(tp,c15033525.costfilter,tp,LOCATION_GRAVE,0,3,3,e:GetHandler())
	-- 将选中的怪兽除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检查是否满足特殊召唤的条件
function c15033525.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，并设置不能在本回合特殊召唤的限制效果
function c15033525.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建一个回合结束时重置的不能特殊召唤的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将不能特殊召唤的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否处于主要阶段1
function c15033525.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 用于筛选场上怪兽的过滤函数
function c15033525.stfilter(c)
	return c:GetOriginalType()&(TYPE_MONSTER)~=0
end
-- 检查是否满足将场上怪兽送去墓地的条件，并执行送去墓地的操作
function c15033525.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	g:RemoveCard(e:GetHandler())
	local mg=g:Filter(c15033525.stfilter,nil)
	-- 检查是否满足将场上怪兽送去墓地的条件
	if chk==0 then return #mg>0 and not g:IsExists(aux.NOT(Card.IsAbleToGraveAsCost),1,nil) end
	-- 将场上怪兽送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(mg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE))
end
-- 设置伤害效果的目标玩家和伤害值
function c15033525.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害值为送去墓地的怪兽数量乘以500
	Duel.SetTargetParam(e:GetLabel()*500)
	-- 设置伤害效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel()*500)
end
-- 执行伤害效果
function c15033525.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
