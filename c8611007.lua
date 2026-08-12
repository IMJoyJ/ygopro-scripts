--ラヴァルバル・ドラグーン
-- 效果：
-- 调整＋调整以外的炎属性怪兽1只以上
-- ①：1回合1次，自己主要阶段才能发动。从卡组把1只「熔岩」怪兽加入手卡。那之后，从手卡选1只「熔岩」怪兽送去墓地。
function c8611007.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的炎属性怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_FIRE),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己主要阶段才能发动。从卡组把1只「熔岩」怪兽加入手卡。那之后，从手卡选1只「熔岩」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8611007,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c8611007.target)
	e1:SetOperation(c8611007.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡组中可以加入手卡的「熔岩」怪兽
function c8611007.filter(c)
	return c:IsSetCard(0x39) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备与合法性检测
function c8611007.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只可以加入手卡的「熔岩」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c8611007.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：从手卡将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 过滤条件：手卡中的「熔岩」怪兽
function c8611007.tgfilter(c)
	return c:IsSetCard(0x39) and c:IsType(TYPE_MONSTER)
end
-- 效果①的效果处理
function c8611007.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的「熔岩」怪兽
	local g=Duel.SelectMatchingCard(tp,c8611007.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 将选中的怪兽加入手卡
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 给对方玩家确认加入手卡的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自身手卡
	Duel.ShuffleHand(tp)
	-- 中断当前效果，使后续的送去墓地处理不与加入手卡同时处理
	Duel.BreakEffect()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选择1只「熔岩」怪兽
	local dg=Duel.SelectMatchingCard(tp,c8611007.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手卡怪兽送去墓地
	Duel.SendtoGrave(dg,REASON_EFFECT)
end
