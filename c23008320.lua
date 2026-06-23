--コール・リゾネーター
-- 效果：
-- ①：从卡组把1只「共鸣者」怪兽加入手卡。
function c23008320.initial_effect(c)
	-- ①：从卡组把1只「共鸣者」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c23008320.target)
	e1:SetOperation(c23008320.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检索满足条件的「共鸣者」怪兽
function c23008320.filter(c)
	return c:IsSetCard(0x57) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果的发动条件判断与操作信息设置
function c23008320.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的「共鸣者」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c23008320.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为检索并加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数
function c23008320.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的「共鸣者」怪兽
	local g=Duel.SelectMatchingCard(tp,c23008320.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
