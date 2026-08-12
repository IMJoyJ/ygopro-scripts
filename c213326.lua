--E－エマージェンシーコール
-- 效果：
-- ①：从卡组把1只「元素英雄」怪兽加入手卡。
function c213326.initial_effect(c)
	-- ①：从卡组把1只「元素英雄」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c213326.target)
	e1:SetOperation(c213326.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检索满足条件的「元素英雄」怪兽
function c213326.filter(c)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果的发动条件判断
function c213326.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c213326.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示将要执行回手牌和检索卡组的效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，执行实际的检索和加入手牌操作
function c213326.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c213326.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
