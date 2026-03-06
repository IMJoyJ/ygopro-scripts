--ジェムレシス
-- 效果：
-- ①：这张卡召唤时才能发动。从卡组把1只「宝石骑士」怪兽加入手卡。
function c27004302.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤时才能发动。从卡组把1只「宝石骑士」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27004302,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c27004302.target)
	e1:SetOperation(c27004302.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选卡组中满足条件的「宝石骑士」怪兽（怪兽卡且可以送去手卡）
function c27004302.filter(c)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理时的判断函数，检查是否满足发动条件并设置操作信息
function c27004302.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断条件：检查玩家卡组中是否存在至少1张满足filter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c27004302.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将从卡组检索1张卡加入手牌的效果分类
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果处理函数，执行检索并加入手牌的操作
function c27004302.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c27004302.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被送去手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
