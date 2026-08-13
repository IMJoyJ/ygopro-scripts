--三眼の死霊
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把场上的这张卡送去墓地才能发动。从卡组把1只暗属性·10星怪兽加入手卡。
function c31464658.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把场上的这张卡送去墓地才能发动。从卡组把1只暗属性·10星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31464658,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,31464658)
	e1:SetCost(c31464658.cost)
	e1:SetTarget(c31464658.target)
	e1:SetOperation(c31464658.operation)
	c:RegisterEffect(e1)
end
-- 发动代价函数：确认这张卡能否作为代价送去墓地，若可以则支付代价，将这张卡从场上送去墓地。
function c31464658.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将这张卡以发动代价（REASON_COST）的形式从场上送去墓地。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 检索过滤条件：选择暗属性、10星且可以加入手卡的怪兽。
function c31464658.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(10) and c:IsAbleToHand()
end
-- 发动目标函数：检查卡组是否存在符合条件的暗属性·10星怪兽，并设置将1张卡从卡组加入手卡的操作信息。
function c31464658.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查卡组是否存在至少1张满足条件的暗属性·10星怪兽，不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c31464658.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理的操作信息：将从卡组把1只符合条件的怪兽加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：玩家选择1张符合条件的暗属性·10星怪兽，将其加入手牌，并向对方确认。
function c31464658.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中不取对象地选择1张满足检索条件的暗属性·10星怪兽。
	local g=Duel.SelectMatchingCard(tp,c31464658.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的那张卡以效果原因（REASON_EFFECT）加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的那张卡，用于确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
