--荒魂
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤·反转时才能发动。从卡组把「荒魂」以外的1只灵魂怪兽加入手卡。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到手卡。
function c16889337.initial_effect(c)
	-- 为卡片添加灵魂怪兽在召唤或反转成功时回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为始终返回假值，使特殊召唤条件无法满足
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·反转时才能发动。从卡组把「荒魂」以外的1只灵魂怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16889337,0))  --"返回手卡"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c16889337.thtg)
	e4:SetOperation(c16889337.thop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
-- 定义过滤函数，用于筛选满足条件的灵魂怪兽（非荒魂且可加入手牌）
function c16889337.filter(c)
	return c:IsType(TYPE_SPIRIT) and not c:IsCode(16889337) and c:IsAbleToHand()
end
-- 设置效果的发动条件，检查卡组中是否存在满足条件的卡片
function c16889337.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c16889337.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡牌类别为加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 设置效果的处理函数，执行选择并加入手牌的操作
function c16889337.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c16889337.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
