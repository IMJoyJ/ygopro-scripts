--マシンナーズ・ディフェンダー
-- 效果：
-- ①：这张卡反转的场合发动。从卡组把1只「督战官 科文顿」加入手卡。
function c96384007.initial_effect(c)
	-- ①：这张卡反转的场合发动。从卡组把1只「督战官 科文顿」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96384007,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c96384007.target)
	e1:SetOperation(c96384007.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中卡名为「督战官 科文顿」且可以加入手牌的怪兽
function c96384007.filter(c)
	return c:IsCode(22666164) and c:IsAbleToHand()
end
-- 效果发动的目标处理，设置将卡组的卡加入手牌的操作信息
function c96384007.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行：从卡组将1只「督战官 科文顿」加入手牌并给对方确认
function c96384007.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中获取第一张满足过滤条件的卡片（即「督战官 科文顿」）
	local tc=Duel.GetFirstMatchingCard(c96384007.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将目标卡片因效果加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
