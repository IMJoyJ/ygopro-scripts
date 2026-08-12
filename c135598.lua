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
-- 检查触发效果的条件：卡片在墓地且因战斗破坏
function c135598.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数：选择3星以下的兽族怪兽
function c135598.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_BEAST) and c:IsAbleToHand()
end
-- 设置效果的目标：从卡组检索1只符合条件的怪兽
function c135598.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件：卡组中是否存在至少1张3星以下的兽族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c135598.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数：执行检索并加入手牌的操作
function c135598.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组选择1张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c135598.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
