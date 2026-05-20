--戦華の暴－董穎
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只7星以上的「战华」怪兽或者1张「战华」永续魔法·永续陷阱卡加入手卡。
-- ②：只要自己场上有7星以上的「战华」怪兽存在，对方若不支付400基本分，则不能把卡的效果发动。
-- ③：怪兽被送去对方墓地的场合，以对方墓地1张卡为对象才能发动。那张卡除外，自己从卡组抽1张。
local s,id,o=GetID()
-- 初始化卡片效果：注册召唤/特殊召唤成功时检索「战华」卡的效果、只要场上有7星以上「战华」怪兽存在对方发动效果需支付400基本分的效果，以及怪兽送去对方墓地时除外对方墓地卡片并抽卡的效果。
function c79582540.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只7星以上的「战华」怪兽或者1张「战华」永续魔法·永续陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79582540,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,79582540)
	e1:SetTarget(c79582540.thtg)
	e1:SetOperation(c79582540.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要自己场上有7星以上的「战华」怪兽存在，对方若不支付400基本分，则不能把卡的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_ACTIVATE_COST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c79582540.costcon)
	e3:SetCost(c79582540.costchk)
	e3:SetOperation(c79582540.costop)
	c:RegisterEffect(e3)
	-- ②：只要自己场上有7星以上的「战华」怪兽存在，对方若不支付400基本分，则不能把卡的效果发动。（用于标记对方玩家以适用发动代价的效果）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_FLAG_EFFECT+79582540)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(c79582540.costcon)
	c:RegisterEffect(e4)
	-- ③：怪兽被送去对方墓地的场合，以对方墓地1张卡为对象才能发动。那张卡除外，自己从卡组抽1张。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(79582540,1))
	e5:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,79582540+o)
	e5:SetCondition(c79582540.rmcon)
	e5:SetTarget(c79582540.rmtg)
	e5:SetOperation(c79582540.rmop)
	c:RegisterEffect(e5)
end
-- 过滤条件：卡组中7星以上的「战华」怪兽，或者「战华」永续魔法·永续陷阱卡。
function c79582540.thfilter(c)
	return c:IsSetCard(0x137) and ((c:IsLevelAbove(7) and c:IsType(TYPE_MONSTER)) or (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS))) and c:IsAbleToHand()
end
-- 召唤·特殊召唤成功时检索效果的靶指向（Target）函数：检查卡组是否存在可检索卡，并设置检索的操作信息。
function c79582540.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时的可行性检查：检查己方卡组是否存在满足条件的「战华」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c79582540.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息：从己方卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 召唤·特殊召唤成功时检索效果的执行（Operation）函数：从卡组选择1张满足条件的「战华」卡加入手卡并给对方确认。
function c79582540.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「战华」卡。
	local g=Duel.SelectMatchingCard(tp,c79582540.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上表侧表示的7星以上的「战华」怪兽。
function c79582540.costcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137) and c:IsLevelAbove(7)
end
-- 对方发动效果需支付基本分效果的适用条件：自己场上存在7星以上的「战华」怪兽。
function c79582540.costcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在表侧表示的7星以上的「战华」怪兽。
	return Duel.IsExistingMatchingCard(c79582540.costcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 检查对方玩家是否能够支付相应的基本分（每次发动需支付400基本分）。
function c79582540.costchk(e,te_or_c,tp)
	-- 获取对方玩家身上该效果的标记数量，用于计算需要支付的基本分。
	local ct=Duel.GetFlagEffect(tp,79582540)
	-- 检查对方玩家是否拥有足够的生命值来支付累计的基本分代价。
	return Duel.CheckLPCost(tp,ct*400)
end
-- 对方发动效果时支付基本分代价的执行函数。
function c79582540.costop(e,tp,eg,ep,ev,re,r,rp)
	-- 让对方玩家支付400基本分。
	Duel.PayLPCost(tp,400)
end
-- 过滤条件：属于对方控制的怪兽卡。
function c79582540.cfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_MONSTER)
end
-- 效果③的发动条件：有怪兽被送去对方墓地。
function c79582540.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c79582540.cfilter,1,nil,1-tp)
end
-- 效果③的靶指向（Target）函数：检查对方墓地是否有可除外的卡，且自己是否能抽卡，并选择对方墓地1张卡作为对象。
function c79582540.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 效果发动时的可行性检查：检查对方墓地是否存在可以除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
		-- 并且检查自己当前是否可以从卡组抽1张卡。
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择对方墓地1张可以除外的卡作为效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置连锁的操作信息：除外指定的卡片。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置连锁的操作信息：自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果③的执行（Operation）函数：将作为对象的卡除外，若除外成功则自己从卡组抽1张卡。
function c79582540.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的那张卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍适用该效果，并将其表侧表示除外，确认其已成功移至除外区。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		-- 玩家因效果从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
