--超戦士の魂
-- 效果：
-- 「超战士之魂」的①②的效果1回合各能使用1次。
-- ①：把手卡1只「混沌战士」怪兽送去墓地才能发动。这张卡直到下次的对方结束阶段攻击力变成3000，卡名当作「混沌战士」使用。
-- ②：把墓地的这张卡除外才能发动。从卡组把1只「开辟之骑士」或者「宵暗之骑士」加入手卡。
function c79234734.initial_effect(c)
	-- ①：把手卡1只「混沌战士」怪兽送去墓地才能发动。这张卡直到下次的对方结束阶段攻击力变成3000，卡名当作「混沌战士」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,79234734)
	e1:SetCost(c79234734.atkcost)
	e1:SetOperation(c79234734.atkop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1只「开辟之骑士」或者「宵暗之骑士」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,79234735)
	-- 设置把墓地的这张卡除外作为效果发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c79234734.thtg)
	e2:SetOperation(c79234734.thop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中属于「混沌战士」系列的怪兽
function c79234734.cfilter(c)
	return c:IsSetCard(0x10cf) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果①的代价处理：从手卡将1只「混沌战士」怪兽送去墓地
function c79234734.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以送去墓地的「混沌战士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c79234734.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择手卡中1只满足条件的怪兽送去墓地
	Duel.DiscardHand(tp,c79234734.cfilter,1,1,REASON_COST)
end
-- 效果①的效果处理：使这张卡直到下次的对方结束阶段攻击力变成3000，且卡名当作「混沌战士」使用
function c79234734.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 卡名当作「混沌战士」使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(5405694)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
		-- 这张卡直到下次的对方结束阶段攻击力变成3000
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(3000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e2)
	end
end
-- 过滤卡组中的「开辟之骑士」或「宵暗之骑士」
function c79234734.thfilter(c)
	return c:IsCode(6628343,32013448) and c:IsAbleToHand()
end
-- 效果②的靶向处理：检查卡组中是否存在目标怪兽，并设置检索的操作信息
function c79234734.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「开辟之骑士」或「宵暗之骑士」
	if chk==0 then return Duel.IsExistingMatchingCard(c79234734.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组的1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组将1只「开辟之骑士」或「宵暗之骑士」加入手卡
function c79234734.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c79234734.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
