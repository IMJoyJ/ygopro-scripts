--召喚師のスキル
-- 效果：
-- ①：从卡组把1只5星以上的通常怪兽加入手卡。
function c79816536.initial_effect(c)
	-- ①：从卡组把1只5星以上的通常怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c79816536.target)
	e1:SetOperation(c79816536.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡组中等级5星以上、属于通常怪兽且可以加入手牌的卡
function c79816536.filter(c)
	return c:IsLevelAbove(5) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与检测函数
function c79816536.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查己方卡组是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c79816536.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会将己方卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（激活）函数
function c79816536.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从己方卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c79816536.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 因效果将选中的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
