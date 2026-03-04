--悪魂邪苦止
-- 效果：
-- 自己场上存在的这张卡被战斗破坏送去墓地时，可以从自己卡组把「恶魂邪苦止」加入手卡。之后卡组洗切。
function c10456559.initial_effect(c)
	-- 自己场上存在的这张卡被战斗破坏送去墓地时，可以从自己卡组把「恶魂邪苦止」加入手卡。之后卡组洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetDescription(aux.Stringid(10456559,0))  --"把「恶魂邪苦止」加入手牌"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c10456559.condition)
	e1:SetTarget(c10456559.target)
	e1:SetOperation(c10456559.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件判断，确保卡片在墓地、是自己控制者且因战斗破坏被送去墓地
function c10456559.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE)
end
-- 过滤函数，用于筛选卡组中可以加入手牌的「恶魂邪苦止」
function c10456559.filter(c)
	return c:IsCode(10456559) and c:IsAbleToHand()
end
-- 效果的处理目标设定，检查卡组中是否存在满足条件的卡片
function c10456559.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果发动条件，检查卡组中是否存在至少1张「恶魂邪苦止」
	if chk==0 then return Duel.IsExistingMatchingCard(c10456559.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，指定将要处理的卡为卡组中的一张「恶魂邪苦止」
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理执行函数，负责实际执行将卡片加入手牌的操作
function c10456559.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择1到3张「恶魂邪苦止」
	local g=Duel.SelectMatchingCard(tp,c10456559.filter,tp,LOCATION_DECK,0,1,3,nil)
	-- 将选中的卡片以效果原因加入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
