--コアキメイル・ロック
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1张「核成兽的钢核」或者1只4星以下的名字带有「核成」的怪兽加入手卡。
function c6320631.initial_effect(c)
	-- 注册卡片记述了「核成兽的钢核」（卡号36623431）的事实
	aux.AddCodeList(c,36623431)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1张「核成兽的钢核」或者1只4星以下的名字带有「核成」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6320631,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c6320631.condition)
	e1:SetTarget(c6320631.target)
	e1:SetOperation(c6320631.operation)
	c:RegisterEffect(e1)
end
-- 判断发动条件：自身被战斗破坏并送去墓地
function c6320631.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：卡名为「核成兽的钢核」或者等级4以下的名字带有「核成」的怪兽，且能加入手卡
function c6320631.filter(c)
	return (c:IsCode(36623431) or (c:IsLevelBelow(4) and c:IsSetCard(0x1d))) and c:IsAbleToHand()
end
-- 效果发动的目标：检查卡组中是否存在符合条件的卡，并设置将卡加入手卡的操作信息
function c6320631.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查卡组中是否存在至少1张符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c6320631.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张符合条件的卡加入手卡，并给对方确认
function c6320631.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c6320631.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
