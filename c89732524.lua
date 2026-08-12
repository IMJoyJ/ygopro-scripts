--魔界発冥界行きバス
-- 效果：
-- ①：这张卡反转的场合发动。从卡组把1只光·暗属性以外的恶魔族怪兽加入手卡。
function c89732524.initial_effect(c)
	-- ①：这张卡反转的场合发动。从卡组把1只光·暗属性以外的恶魔族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89732524,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c89732524.target)
	e1:SetOperation(c89732524.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与检测函数，由于是强制发动的反转效果，直接返回true并设置操作信息
function c89732524.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明此效果包含从卡组将1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：卡组中光·暗属性以外的恶魔族怪兽，且该卡可以加入手卡
function c89732524.filter(c)
	return c:IsRace(RACE_FIEND) and c:IsNonAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果处理的执行函数，从卡组将1只符合条件的怪兽加入手卡并给对方确认
function c89732524.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端显示提示信息，提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c89732524.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
