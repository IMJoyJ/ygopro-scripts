--オーバーテクス・ゴアトルス
-- 效果：
-- 这张卡不能通常召唤。让除外的5只自己的恐龙族怪兽回到卡组的场合才能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，对方把魔法·陷阱卡发动时才能发动。选自己的手卡·场上1只恐龙族怪兽破坏，那个发动无效并破坏。
-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把1张「进化药」魔法卡加入手卡。
function c41782653.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 让自己的除外状态的5只恐龙族怪兽回到卡组的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c41782653.sprcon)
	e2:SetTarget(c41782653.sprtg)
	e2:SetOperation(c41782653.sprop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，对方把魔法·陷阱卡发动时才能发动。自己的手卡·场上（表侧表示）1只恐龙族怪兽破坏，那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41782653,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c41782653.negcon)
	e3:SetTarget(c41782653.negtg)
	e3:SetOperation(c41782653.negop)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被效果送去墓地的场合才能发动。从卡组把1张「进化药」魔法卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41782653,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,41782653)
	e4:SetCondition(c41782653.thcon)
	e4:SetTarget(c41782653.thtg)
	e4:SetOperation(c41782653.thop)
	c:RegisterEffect(e4)
end
-- 筛选可作为特殊召唤代价的除外区表侧表示恐龙族怪兽：表侧表示、恐龙族且可作为COST返回卡组。
function c41782653.sprfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR) and c:IsAbleToDeckAsCost()
end
-- 特殊召唤规则的发动条件判定：当c为空时视为可发动；否则要求我方主要怪兽区有空位，且除外区存在至少5只可返回卡组的表侧恐龙族怪兽。
function c41782653.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查我方主要怪兽区是否有可用空位，确保特殊召唤后有格子。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方除外区是否存在至少5只满足sprfilter条件的恐龙族怪兽，作为特殊召唤的返回卡组代价素材。
		and Duel.IsExistingMatchingCard(c41782653.sprfilter,tp,LOCATION_REMOVED,0,5,nil)
end
-- 特殊召唤手续的选择阶段：从我方除外区符合条件的恐龙族怪兽中选择5张作为返回卡组的代价；选择成功则保存该组并返回true，否则返回false取消特殊召唤。
function c41782653.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取我方除外区所有满足sprfilter条件的恐龙族怪兽，组成候选组。
	local g=Duel.GetMatchingGroup(c41782653.sprfilter,tp,LOCATION_REMOVED,0,nil)
	-- 弹出选择提示，要求玩家选择要返回卡组的恐龙族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:CancelableSelect(tp,5,5,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤手续：将之前选中的5张恐龙族怪兽返回持有者卡组并洗牌，随后由规则完成特殊召唤。
function c41782653.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 向玩家展示选中的将返回卡组的卡片，并记录这些卡被选为对象。
	Duel.HintSelection(g)
	-- 将选中的恐龙族怪兽返回持有者卡组并洗牌，作为特殊召唤的代价。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ①效果的发动条件：这张卡未被战斗破坏，且连锁的发动者为对方，对方发动的是魔法·陷阱卡，且该连锁可以被无效。
function c41782653.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
		-- 且该连锁为魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），并且该连锁效果可以被无效。
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 筛选可作为①效果破坏对象的卡：自己手卡的恐龙族怪兽，或自己场上表侧表示的恐龙族怪兽。
function c41782653.desfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DINOSAUR)
end
-- ①效果的发动合法性检查与操作信息设定：确认自己有可破坏的恐龙族怪兽；设定破坏自己一张恐龙族怪兽、无效对方发动，并可能破坏对方发动的卡。
function c41782653.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查我方手卡·场上是否存在至少1只满足条件的恐龙族怪兽，作为①效果的发动前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c41782653.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设定操作信息：我方手卡·场上将会有1张卡被破坏（具体卡片在效果处理时选择，因此目标暂不指定）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	-- 设定操作信息：将要无效对方发动的魔法·陷阱卡的发动，对象为eg（对方发动的那张卡）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 当对方发动的卡可被破坏且仍与那个发动效果关联时，设定操作信息：将该卡破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ①效果处理：选择并破坏自己手卡·场上1只恐龙族怪兽；若破坏成功，则无效对方魔法·陷阱卡的发动，并进一步破坏那张卡。
function c41782653.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的恐龙族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己手卡·场上选择1只恐龙族怪兽作为破坏对象。
	local g1=Duel.SelectMatchingCard(tp,c41782653.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 若成功选择了破坏对象且破坏处理成功（至少1张被破坏），则继续执行后续无效处理。
	if g1:GetCount()>0 and Duel.Destroy(g1,REASON_EFFECT)~=0 then
		-- 若成功无效对方发动的连锁，且对方发动的卡仍与那个发动效果相关联（未离场等），则将其破坏。
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 将对方发动的魔法·陷阱卡以效果破坏。
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：这张卡是被效果（REASON_EFFECT）送去墓地。
function c41782653.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 筛选卡组中满足检索条件的卡：属于「进化药」字段的魔法卡且能被加入手卡。
function c41782653.thfilter(c)
	return c:IsSetCard(0x10e) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ②效果的发动合法性检查与操作信息设定：确认卡组存在可检索的「进化药」魔法卡，并设定检索加入手卡。
function c41782653.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张符合条件的「进化药」魔法卡，作为②效果的发动前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c41782653.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定操作信息：我方卡组中1张卡将被加入手卡（具体处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张「进化药」魔法卡加入手卡，并向对方展示确认。
function c41782653.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的「进化药」魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「进化药」魔法卡。
	local g=Duel.SelectMatchingCard(tp,c41782653.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「进化药」魔法卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的「进化药」魔法卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
