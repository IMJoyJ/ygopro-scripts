--神鳥の来寇
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡丢弃1只鸟兽族怪兽才能发动。从卡组把2只「斯摩夫」怪兽加入手卡（相同属性最多1只）。
-- ②：把墓地的这张卡除外才能发动。手卡1只鸟兽族怪兽给对方观看。这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
function c28617139.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡丢弃1只鸟兽族怪兽才能发动。从卡组把2只「斯摩夫」怪兽加入手卡（相同属性最多1只）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28617139,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,28617139+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c28617139.cost)
	e1:SetTarget(c28617139.target)
	e1:SetOperation(c28617139.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。手卡1只鸟兽族怪兽给对方观看。这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28617139,1))  --"等级下降"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置②效果的发动代价：将墓地中的这张卡自身除外（使用通用除外代价函数aux.bfgcost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c28617139.lvtg)
	e2:SetOperation(c28617139.lvop)
	c:RegisterEffect(e2)
end
-- 定义①效果的代价筛选：手卡中为鸟兽族且可以作为丢弃代价的怪兽。
function c28617139.costfilter(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsDiscardable()
end
-- ①效果的代价函数：先检查手卡是否存在可丢弃的鸟兽族怪兽；实际发动时选择并丢弃1只鸟兽族怪兽作为代价。
function c28617139.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手卡中是否存在至少1只满足costfilter条件的鸟兽族怪兽，存在才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c28617139.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃代价：从手卡选择并丢弃1只鸟兽族怪兽（丢弃原因为代价+丢弃）。
	Duel.DiscardHand(tp,c28617139.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义①效果的检索筛选：卡组中属于‘斯摩夫’字段的怪兽卡，且可以被加入手卡。
function c28617139.thfilter(c)
	return c:IsSetCard(0x12d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的目标设定：获取卡组中所有符合条件的‘斯摩夫’怪兽；若不同属性的种类达到2种以上，则登记将从卡组把2张卡加入手卡的操作信息。
function c28617139.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标判定阶段，获取卡组中所有满足检索条件的‘斯摩夫’怪兽，暂存至g。
	local g=Duel.GetMatchingGroup(c28617139.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetAttribute)>=2 end
	-- 登记操作信息：本次效果处理会从卡组将2张卡加入手卡（不指定具体卡，供连锁检测使用）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- ①效果处理：从符合条件的‘斯摩夫’怪兽中，选择2只属性互不相同的卡加入手卡，并将它们展示给对方确认。
function c28617139.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理阶段，重新获取卡组中当前所有符合条件的‘斯摩夫’怪兽。
	local g=Duel.GetMatchingGroup(c28617139.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetAttribute)<2 then return end
	-- 向发动者发出选择提示，提示文字为‘请选择要加入手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从候选卡中选择2张，且所选怪兽属性互不相同（相同属性最多1只）。
	local sg=g:SelectSubGroup(tp,aux.dabcheck,false,2,2)
	-- 将选中的2张‘斯摩夫’怪兽加入其持有者的手卡（处理原因为效果）。
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	-- 将加入手卡的2张卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,sg)
end
-- 定义②效果展示对象的筛选：手卡中为鸟兽族、等级2以上且当前不是公开状态的怪兽。
function c28617139.cffilter(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsLevelAbove(2) and not c:IsPublic()
end
-- ②效果的发动条件：检查自己手卡中是否存在满足cffilter的怪兽（鸟兽族、等级2以上且未公开），存在则满足发动条件。
function c28617139.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检测：确认手卡中是否存在至少1只满足展示条件的鸟兽族怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c28617139.cffilter,tp,LOCATION_HAND,0,1,nil) end
end
-- ②效果处理：选择并展示手卡中1只鸟兽族怪兽，然后洗切手卡；再给手卡中所有与该怪兽同名的卡，在此回合内附加等级下降1星的效果。
function c28617139.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动者发出选择提示，提示文字为‘请选择给对方确认的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 效果处理时，让发动者从手卡中选择1只满足cffilter条件的鸟兽族怪兽用于展示。
	local g=Duel.SelectMatchingCard(tp,c28617139.cffilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		-- 将选中的手卡怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示后洗切自己的手卡，以掩盖手牌顺序信息。
		Duel.ShuffleHand(tp)
		-- 获取自己手卡中所有与所选展示怪兽卡名相同的卡（包括展示的那张），用于等级下降。
		local sg=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND,0,nil,g:GetFirst():GetCode())
		local tc=sg:GetFirst()
		while tc do
			-- 这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(-1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc=sg:GetNext()
		end
	end
end
