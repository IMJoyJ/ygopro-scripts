--空牙団の叡智 ウィズ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。自己回复「空牙团的睿智 薇兹」以外的自己场上的「空牙团」怪兽种类×500基本分。
-- ②：对方把魔法·陷阱卡的效果发动时，从手卡丢弃1张「空牙团」卡才能发动。那个发动无效。
function c1527418.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡特殊召唤的场合才能发动。自己回复「空牙团的睿智 薇兹」以外的自己场上的「空牙团」怪兽种类×500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1527418,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,1527418)
	e1:SetTarget(c1527418.rectg)
	e1:SetOperation(c1527418.recop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：对方把魔法·陷阱卡的效果发动时，从手卡丢弃1张「空牙团」卡才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1527418,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,1527419)
	e2:SetCondition(c1527418.negcon)
	e2:SetCost(c1527418.negcost)
	e2:SetTarget(c1527418.negtg)
	e2:SetOperation(c1527418.negop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡片须为表侧表示、持有「空牙团」字段，且不是卡号1527418（「空牙团的睿智 薇兹」自身）。
function c1527418.recfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114) and not c:IsCode(1527418)
end
-- ①效果的发动条件和操作信息设置：先检查场上是否存在符合条件的「空牙团」怪兽，若存在则统计其种类数×500作为回复值，并登记为回复效果。
function c1527418.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：在效果发动的场合（chk==0）确认我方场上存在至少1只表侧表示且满足recfilter的「空牙团」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c1527418.recfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取我方场上所有满足recfilter的「空牙团」怪兽集合，用于计算回复数值。
	local g=Duel.GetMatchingGroup(c1527418.recfilter,tp,LOCATION_MZONE,0,nil)
	local rec=g:GetClassCount(Card.GetCode)*500
	-- 登记操作信息：本次效果将回复LP，对象为无特定卡（nil），数量为0，回复方为tp，预计回复值为rec。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- ①效果处理：重新获取当前场上符合条件的「空牙团」怪兽集合，计算种类数×500对我方LP进行回复。
function c1527418.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理阶段再次获取场上符合条件的「空牙团」怪兽集合，以防发动后怪兽数量变化，按实际种类数计算。
	local g=Duel.GetMatchingGroup(c1527418.recfilter,tp,LOCATION_MZONE,0,nil)
	local rec=g:GetClassCount(Card.GetCode)*500
	-- 使我方玩家tp回复rec点基本分，回复原因标记为效果（REASON_EFFECT）。
	Duel.Recover(tp,rec,REASON_EFFECT)
end
-- ②效果发动条件：本卡未被战斗破坏确定，且该连锁由对方发动，发动的是魔法·陷阱卡的效果，并且该发动可以被无效化。
function c1527418.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 进一步判定：连锁的发动者不是我方（ep~=tp）、发动效果为魔法/陷阱卡类型、且该连锁是可被无效的连锁。
		and ep~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 代价卡过滤函数：在手牌中可为可丢弃的「空牙团」卡；在墓地中需持有53557529效果且可除外代替丢弃，同时本卡（薇兹）必须属于「空牙团」字段。
function c1527418.cfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x114) and c:IsDiscardable()
	else
		return e:GetHandler():IsSetCard(0x114) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(53557529,tp)
	end
end
-- ②效果代价的发动和支付：检查有可用代价卡后，提示玩家选择一张手牌或墓地的「空牙团」卡，若选择的是带有代替丢弃除外效果的卡则除外，否则丢弃到墓地。
function c1527418.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：在代价确认阶段（chk==0）判断手牌或墓地是否存在至少1张满足cfilter的「空牙团」卡，若没有则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c1527418.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示框，提示玩家选择一张要丢弃（或除外代替丢弃）的手牌/墓地的「空牙团」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手牌或墓地中选出1张符合cfilter的「空牙团」卡作为代价，返回选卡集合。
	local g=Duel.SelectMatchingCard(tp,c1527418.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(53557529,tp)
	if te then
		te:UseCountLimit(tp)
		-- 若被选卡拥有53557529效果，则将其以表侧除外的方式代替丢弃，作为代价的一部分。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		-- 否则，将被选的「空牙团」卡送去墓地，以正常丢弃作为发动代价。
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- ②效果的目标阶段：无需选择其他对象，只要代价和条件满足即可发动；随后登记本次无效对象为当前连锁中的魔法/陷阱卡发动。
function c1527418.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将当前连锁中发动的魔法/陷阱卡（eg）作为无效对象，类别为无效发动（CATEGORY_NEGATE）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ②效果处理：直接无效对方发动的魔法·陷阱卡效果的发动。
function c1527418.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 对连锁ev执行发动无效化，若成功则使该魔法/陷阱卡的发动无效。
	Duel.NegateActivation(ev)
end
