--オシャレオン
-- 效果：
-- 只要这张卡在自己场上表侧攻击表示存在，对方不能选择「文色龙」以外的怪兽作为攻击对象。这张卡被战斗破坏送去墓地时，可以从自己卡组把1只攻击力500以下的爬虫类族怪兽加入手卡。
function c71519605.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只攻击力500以下的爬虫类族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71519605,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c71519605.condition)
	e1:SetTarget(c71519605.target)
	e1:SetOperation(c71519605.operation)
	c:RegisterEffect(e1)
	-- 只要这张卡在自己场上表侧攻击表示存在，对方不能选择「文色龙」以外的怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c71519605.atcon)
	e2:SetValue(c71519605.atlimit)
	c:RegisterEffect(e2)
end
-- 检查自身是否处于表侧攻击表示
function c71519605.atcon(e)
	return e:GetHandler():IsAttackPos()
end
-- 限制对方不能选择里侧表示的怪兽以及「文色龙」以外的怪兽作为攻击对象
function c71519605.atlimit(e,c)
	return c:IsFacedown() or not c:IsCode(71519605)
end
-- 检查此卡是否因战斗破坏被送去墓地
function c71519605.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤卡组中攻击力500以下且可以加入手牌的爬虫类族怪兽
function c71519605.filter(c)
	return c:IsAttackBelow(500) and c:IsRace(RACE_REPTILE) and c:IsAbleToHand()
end
-- 检索效果的发动准备，检查卡组中是否存在符合条件的怪兽，并设置将卡加入手牌的操作信息
function c71519605.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c71519605.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理的操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理，让玩家从卡组选择1只符合条件的怪兽加入手牌并给对方确认
function c71519605.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c71519605.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
