--クリフォトン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把这张卡从手卡送去墓地，支付2000基本分才能发动。这个回合，自己受到的全部伤害变成0。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在的场合，从手卡把「光子栗子」以外的1只「光子」怪兽送去墓地才能发动。墓地的这张卡加入手卡。
function c35112613.initial_effect(c)
	-- ①：把这张卡从手卡送去墓地，支付2000基本分才能发动。这个回合，自己受到的全部伤害变成0。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35112613,0))  --"伤害变成0"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c35112613.cost)
	e1:SetOperation(c35112613.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的场合，从手卡把「光子栗子」以外的1只「光子」怪兽送去墓地才能发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35112613,1))  --"返回手牌"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,35112613)
	e2:SetCost(c35112613.thcost)
	e2:SetTarget(c35112613.thtg)
	e2:SetOperation(c35112613.thop)
	c:RegisterEffect(e2)
end
-- 效果①的代价处理：先检测能否支付2000基本分且将自身从手卡送去墓地，随后实际支付LP并将自身作为代价送去墓地。
function c35112613.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认玩家tp可以支付2000基本分，且此卡可以作为代价从手卡送去墓地。
	if chk==0 then return Duel.CheckLPCost(tp,2000) and e:GetHandler():IsAbleToGraveAsCost() end
	-- 实际支付2000基本分作为发动代价。
	Duel.PayLPCost(tp,2000)
	-- 把发动效果的这张卡从手卡送去墓地，作为代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果①处理：为tp玩家注册本回合受到的所有伤害变为0的场地效果，并额外注册一个效果伤害归零的标记效果，持续到结束阶段。
function c35112613.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个卡名的②的效果1回合只能使用1次。①：把这张卡从手卡送去墓地，支付2000基本分才能发动。这个回合，自己受到的全部伤害变成0。这个效果在对方回合也能发动。②：这张卡在墓地存在的场合，从手卡把「光子栗子」以外的1只「光子」怪兽送去墓地才能发动。墓地的这张卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将由e1表示的“己方受到伤害变为0”的效果注册给tp玩家，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将e2这一“效果伤害变为0”的标记效果注册给tp玩家，持续到结束阶段，用于配合其他卡片检测。
	Duel.RegisterEffect(e2,tp)
end
-- ②效果代价的筛选条件：选择手牌中1只「光子」系列怪兽，卡名不是「光子栗子」（35112613），且可作为代价送去墓地。
function c35112613.cfilter(c)
	return c:IsSetCard(0x55) and c:IsType(TYPE_MONSTER) and not c:IsCode(35112613) and c:IsAbleToGraveAsCost()
end
-- ②效果代价处理：先检查手牌中是否存在满足条件的「光子」怪兽可作为代价，然后让玩家选择1只并送去墓地。
function c35112613.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认手牌中存在至少1只满足cfilter条件的「光子」怪兽可作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c35112613.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 给出选择提示，提示玩家选择一张要送去墓地的卡（HINTMSG_TOGRAVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌中选择1只满足条件的「光子」怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c35112613.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的那只怪兽送去墓地，作为发动②效果的代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的发动条件/目标判定：确认墓地的这张卡能够加入手牌，并设置处理时将其加入手牌的操作信息。
function c35112613.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置本次效果处理的信息：将墓地的这张卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若墓地的这张卡仍与效果有联系，则将其加入持有者的手牌。
function c35112613.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地加入其持有者的手牌（REASON_EFFECT）。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
