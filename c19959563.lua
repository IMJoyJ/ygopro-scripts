--戒めの龍
-- 效果：
-- 这张卡不能通常召唤。自己的除外状态的「光道」怪兽是4种类以上的场合才能特殊召唤。
-- ①：自己·对方回合1次，支付1000基本分才能发动。「光道」怪兽以外的双方的墓地·除外状态（表侧）的卡全部回到卡组。
-- ②：1回合1次，自己的「光道」怪兽的效果发动的场合发动。从自己卡组上面把4张卡送去墓地。
function c19959563.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 自己的除外状态的「光道」怪兽是4种类以上的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19959563.spcon)
	c:RegisterEffect(e1)
	-- 自己·对方回合1次，支付1000基本分才能发动。「光道」怪兽以外的双方的墓地·除外状态（表侧）的卡全部回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19959563,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(c19959563.cost)
	e2:SetTarget(c19959563.target)
	e2:SetOperation(c19959563.operation)
	c:RegisterEffect(e2)
	-- 1回合1次，自己的「光道」怪兽的效果发动的场合发动。从自己卡组上面把4张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(19959563,1))
	e4:SetCategory(CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c19959563.ddcon)
	e4:SetTarget(c19959563.ddtg)
	e4:SetOperation(c19959563.ddop)
	c:RegisterEffect(e4)
end
-- 筛选出表侧表示、属于「光道」系列且为怪兽卡的卡，用于统计除外区「光道」怪兽的种类数量。
function c19959563.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER)
end
-- 判断能否从手牌进行本卡的特殊召唤：若c非空，需自己场上有空位，且除外区表侧「光道」怪兽的种类数大于4；c为空时返回true以回应规则查询。
function c19959563.spcon(e,c)
	if c==nil then return true end
	-- 检查该玩家的主要怪兽区是否有空位；若无空位则不能特殊召唤。
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	-- 获取该玩家除外区中所有满足spfilter的「光道」怪兽。
	local g=Duel.GetMatchingGroup(c19959563.spfilter,c:GetControler(),LOCATION_REMOVED,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>3
end
-- 效果的发动代价：检查并支付1000基本分。
function c19959563.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段确认玩家tp能否支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际扣除玩家tp的1000基本分，完成代价支付。
	Duel.PayLPCost(tp,1000)
end
-- 筛选可作为①效果对象的卡：位于墓地或表侧除外区，不是「光道」怪兽，且可以回到卡组。
function c19959563.filter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and not (c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER)) and c:IsAbleToDeck()
end
-- ①效果的目标处理：确认至少存在1张符合条件的卡，并取得全部符合条件的卡，登记为返回卡组的操作信息。
function c19959563.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标合法性检查时，确认双方的墓地/表侧除外区存在至少1张符合条件的非「光道」怪兽且不包括本卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c19959563.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,e:GetHandler()) end
	-- 取出双方墓地及表侧除外区中所有满足filter的卡。
	local g=Duel.GetMatchingGroup(c19959563.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	-- 将本次操作信息登记为把这些卡返回卡组，数量为g中卡数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ①效果处理：若未因王家长眠之谷等效果被无效，则将满足条件的卡全部返回持有者卡组并洗牌。
function c19959563.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次取出双方墓地及表侧除外区中所有满足filter的卡。
	local g=Duel.GetMatchingGroup(c19959563.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	-- 若王家长眠之谷效果检测成立，则本次效果被无效，不执行回卡组处理。
	if aux.NecroValleyNegateCheck(g) then return end
	-- 将目标卡全部返回持有者卡组并洗牌，原因为效果。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- ②效果的发动条件：检测到本回合有自己控制的「光道」怪兽效果发动，且该效果不是本卡自身的效果（满足时强制发动）。
function c19959563.ddcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc~=c
		and rc:IsSetCard(0x38) and rc:IsControler(tp)
end
-- ②效果的无对象目标阶段：直接返回可发动，并登记将4张卡送去墓地的操作信息。
function c19959563.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：把玩家tp卡组上方4张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,4)
end
-- ②效果的处理：从玩家tp卡组上方把4张卡送去墓地。
function c19959563.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行从玩家tp卡组最上方丢弃4张卡到墓地，原因为效果。
	Duel.DiscardDeck(tp,4,REASON_EFFECT)
end
