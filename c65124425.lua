--虚ろなる龍輪
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只幻龙族怪兽送去墓地。自己场上有效果怪兽以外的表侧表示怪兽存在的场合，可以再把和送去墓地的那只怪兽卡名不同的1只「天威」怪兽从卡组加入手卡。
function c65124425.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只幻龙族怪兽送去墓地。自己场上有效果怪兽以外的表侧表示怪兽存在的场合，可以再把和送去墓地的那只怪兽卡名不同的1只「天威」怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,65124425+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c65124425.target)
	e1:SetOperation(c65124425.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡组中可以送去墓地的幻龙族怪兽
function c65124425.tgfilter(c)
	return c:IsRace(RACE_WYRM) and c:IsAbleToGrave()
end
-- 效果的发动准备与合法性检测
function c65124425.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查卡组中是否存在至少1只可以送去墓地的幻龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c65124425.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：自己场上表侧表示的效果怪兽以外的怪兽
function c65124425.thcfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 过滤条件：卡组中与送去墓地的怪兽卡名不同、且可以加入手卡的「天威」怪兽
function c65124425.thfilter(c,tc)
	return c:IsSetCard(0x12c) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand() and not c:IsCode(tc:GetCode())
end
-- 效果处理：将卡组的幻龙族怪兽送去墓地，若满足条件则可选择将1只卡名不同的「天威」怪兽从卡组加入手卡
function c65124425.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只满足条件的幻龙族怪兽
	local tc=Duel.SelectMatchingCard(tp,c65124425.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 将选择的怪兽送去墓地，并确认其成功送去墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE)
		-- 检查自己场上是否存在效果怪兽以外的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c65124425.thcfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查卡组中是否存在与送去墓地的怪兽卡名不同的「天威」怪兽
		and Duel.IsExistingMatchingCard(c65124425.thfilter,tp,LOCATION_DECK,0,1,nil,tc)
		-- 询问玩家是否选择将「天威」怪兽加入手卡
		and Duel.SelectYesNo(tp,aux.Stringid(65124425,0)) then  --"是否要把1只「天威」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只与送去墓地的怪兽卡名不同的「天威」怪兽
		local g=Duel.SelectMatchingCard(tp,c65124425.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
		-- 中断当前效果，使后续的检索处理与送去墓地不视为同时处理
		Duel.BreakEffect()
		-- 将选择的「天威」怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
