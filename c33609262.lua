--帝王の深怨
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把手卡1只攻击力2400/守备力1000的怪兽或者1只攻击力2800/守备力1000的怪兽给对方观看才能发动。从卡组把「帝王的深怨」以外的1张「帝王」魔法·陷阱卡加入手卡。
function c33609262.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把手卡1只攻击力2400/守备力1000的怪兽或者1只攻击力2800/守备力1000的怪兽给对方观看才能发动。从卡组把「帝王的深怨」以外的1张「帝王」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,33609262+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c33609262.cost)
	e1:SetTarget(c33609262.target)
	e1:SetOperation(c33609262.operation)
	c:RegisterEffect(e1)
end
-- 定义手卡怪兽的筛选条件：攻击力为2400或2800、守备力为1000，且该卡当前不为公开状态。
function c33609262.cfilter(c)
	return c:IsAttack(2400,2800) and c:IsDefense(1000) and not c:IsPublic()
end
-- 支付展示手卡怪兽的费用：确认满足条件的怪兽存在后，选择1张手卡怪兽给对方观看，然后洗切手卡。
function c33609262.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己手卡是否存在1张以上满足条件的怪兽；若不存在则无法发动效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c33609262.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，让玩家从手卡选择一张要展示给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡中选择1张攻击力2400/2800且守备力1000的怪兽卡，用于支付展示费用。
	local g=Duel.SelectMatchingCard(tp,c33609262.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切自己的手卡，避免手牌顺序信息被对方获知。
	Duel.ShuffleHand(tp)
end
-- 定义卡组检索的筛选条件：是「帝王」魔法·陷阱卡、不是「帝王的深怨」本身、且能够被加入手卡。
function c33609262.filter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(33609262) and c:IsAbleToHand()
end
-- 效果发动的目标阶段：确认卡组存在可检索的「帝王」魔法·陷阱卡，并设置本次操作信息为从卡组把1张卡加入手卡。
function c33609262.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在1张以上满足检索条件的「帝王」魔法·陷阱卡；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c33609262.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息：将从卡组把1张卡加入手卡（数量为1，对象为卡组中的卡）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段：从卡组选择1张符合条件的「帝王」魔法·陷阱卡加入手卡，并让对方确认加入手卡的卡。
function c33609262.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家从卡组选择一张要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「帝王」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c33609262.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果缘故加入手卡（默认加入持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
