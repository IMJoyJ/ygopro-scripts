--名工 虎鉄
-- 效果：
-- ①：这张卡反转的场合发动。从卡组把1张装备魔法卡加入手卡。
function c73431236.initial_effect(c)
	-- ①：这张卡反转的场合发动。从卡组把1张装备魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73431236,0))  --"检索装备魔法"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c73431236.target)
	e1:SetOperation(c73431236.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标过滤与检测函数，反转效果为强制发动，chk为0时直接返回true
function c73431236.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示此效果的处理为将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：卡片是装备魔法卡且可以加入手卡
function c73431236.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 效果处理的执行函数：从卡组检索1张装备魔法卡加入手卡并展示给对方确认
function c73431236.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端显示提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c73431236.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
