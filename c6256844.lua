--レアル・ジェネクス・ターボ
-- 效果：
-- ①：这张卡召唤时才能发动。从卡组把1只1星「次世代」怪兽加入手卡。
function c6256844.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把1只1星「次世代」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6256844,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c6256844.target)
	e1:SetOperation(c6256844.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡组中等级为1且卡名含有「次世代」并能加入手牌的怪兽
function c6256844.filter(c)
	return c:IsLevel(1) and c:IsSetCard(0x2) and c:IsAbleToHand()
end
-- 效果发动的目标与检测函数
function c6256844.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检测己方卡组是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c6256844.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示将己方卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c6256844.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送提示信息，提示其选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从己方卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c6256844.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 因效果将选中的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
