--キーマウス
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只3星以下的兽族怪兽加入手卡。
function c135598.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只3星以下的兽族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(135598,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c135598.condition)
	e1:SetTarget(c135598.target)
	e1:SetOperation(c135598.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：这张卡在墓地且是被战斗破坏送去墓地。
function c135598.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义检索过滤条件：等级3以下、兽族且能够加入手卡的怪兽。
function c135598.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_BEAST) and c:IsAbleToHand()
end
-- 效果发动时的目标处理：确认卡组存在符合条件的怪兽，并设置将卡组中的卡加入手卡的操作信息。
function c135598.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己卡组中存在至少1只符合条件的兽族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c135598.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理的操作信息：将1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从自己卡组挑选1只符合条件的兽族怪兽加入手卡，并让对方确认。
function c135598.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示，并让玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中选择1张满足条件的兽族怪兽。
	local g=Duel.SelectMatchingCard(tp,c135598.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
