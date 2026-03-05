--シンクロ・フュージョニスト
-- 效果：
-- ①：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张「融合」魔法卡加入手卡。
function c15839054.initial_effect(c)
	-- 效果原文：①：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张「融合」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15839054,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c15839054.condition)
	e1:SetTarget(c15839054.target)
	e1:SetOperation(c15839054.operation)
	c:RegisterEffect(e1)
end
-- 规则层面：判断此卡是否因同调召唤而被送入墓地
function c15839054.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 规则层面：过滤满足「融合」字段、魔法卡类型且能加入手牌的卡
function c15839054.filter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 规则层面：设置连锁处理信息，表示将从卡组检索1张「融合」魔法卡加入手牌
function c15839054.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查卡组中是否存在满足条件的「融合」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c15839054.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面：设置连锁操作信息，表示将从卡组检索1张「融合」魔法卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面：执行效果处理，提示玩家选择卡组中的「融合」魔法卡并加入手牌
function c15839054.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面：选择满足条件的1张「融合」魔法卡
	local g=Duel.SelectMatchingCard(tp,c15839054.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面：将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面：向对方确认被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
