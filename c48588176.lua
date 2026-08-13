--ダニポン
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只守备力1000以下的昆虫族怪兽加入手卡。
function c48588176.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只守备力1000以下的昆虫族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48588176,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c48588176.condition)
	e1:SetTarget(c48588176.target)
	e1:SetOperation(c48588176.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：确认效果发动者（这张卡）当前位于墓地，且被战斗破坏送去墓地。
function c48588176.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 检索滤卡条件：必须是守备力1000以下的昆虫族怪兽，且能够加入手卡。
function c48588176.filter(c)
	return c:IsDefenseBelow(1000) and c:IsRace(RACE_INSECT) and c:IsAbleToHand()
end
-- 发动目标处理：检查卡组是否存在符合条件的昆虫族怪兽，并设置效果处理时加入手卡的操作信息。
function c48588176.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：判断自己卡组是否存在1只符合条件的昆虫族怪兽，不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c48588176.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预定效果处理时将从卡组把1张卡加入手卡（对象在处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的昆虫族怪兽加入手卡，并让对手确认。
function c48588176.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：提示当前玩家从卡组选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组筛选并选择1张符合条件的昆虫族怪兽（守备力≤1000且能加入手卡）。
	local g=Duel.SelectMatchingCard(tp,c48588176.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选的卡加入其持有者的手卡（此处nil表示回到持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
