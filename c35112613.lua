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
	-- ②：这张卡在墓地存在的场合，从手卡把「光子栗子」以外的1只「光子」怪兽送去墓地才能发动。墓地的这张卡加入手卡。
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
-- 支付2000基本分并把自身送去墓地作为cost
function c35112613.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付2000基本分并确认自身可以作为cost送去墓地
	if chk==0 then return Duel.CheckLPCost(tp,2000) and e:GetHandler():IsAbleToGraveAsCost() end
	-- 支付2000基本分
	Duel.PayLPCost(tp,2000)
	-- 将自身送去墓地作为cost
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 使自己在本回合受到的全部伤害变为0
function c35112613.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 创建一个影响自己玩家的伤害变更效果，使伤害变为0，并创建一个效果使自己不受效果伤害
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册伤害变更效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不受效果伤害效果
	Duel.RegisterEffect(e2,tp)
end
-- 过滤函数，用于筛选手牌中非光子栗子的光子怪兽
function c35112613.cfilter(c)
	return c:IsSetCard(0x55) and c:IsType(TYPE_MONSTER) and not c:IsCode(35112613) and c:IsAbleToGraveAsCost()
end
-- 从手牌中选择1只非光子栗子的光子怪兽送去墓地作为cost
function c35112613.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的光子怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35112613.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只光子怪兽
	local g=Duel.SelectMatchingCard(tp,c35112613.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的光子怪兽送去墓地作为cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果处理时要将自身加入手牌的操作信息
function c35112613.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置将自身加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 将自身从墓地加入手牌
function c35112613.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
