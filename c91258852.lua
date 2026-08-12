--SPYRAL－グレース
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，自己主要阶段才能发动。从卡组把1张「秘旋谍任务」卡加入手卡。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「秘旋谍-高雅女士」以外的1只「秘旋谍」怪兽和1张「秘旋谍的秘密胜地」加入手卡。
function c91258852.initial_effect(c)
	-- 注册卡片记载了「秘旋谍的秘密胜地」的卡片密码
	aux.AddCodeList(c,54631665)
	-- ①：1回合1次，自己主要阶段才能发动。从卡组把1张「秘旋谍任务」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91258852,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c91258852.thtg1)
	e1:SetOperation(c91258852.thop1)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「秘旋谍-高雅女士」以外的1只「秘旋谍」怪兽和1张「秘旋谍的秘密胜地」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91258852,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,91258852)
	e2:SetCondition(c91258852.thcon2)
	e2:SetTarget(c91258852.thtg2)
	e2:SetOperation(c91258852.thop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中可加入手牌的「秘旋谍任务」卡
function c91258852.thfilter1(c)
	return c:IsSetCard(0x20ee) and c:IsAbleToHand()
end
-- 效果①的发动准备与可行性检查
function c91258852.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可加入手牌的「秘旋谍任务」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c91258852.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理逻辑：从卡组将1张「秘旋谍任务」卡加入手牌
function c91258852.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张「秘旋谍任务」卡
	local g=Duel.SelectMatchingCard(tp,c91258852.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检查发动条件：这张卡是否从场上送去墓地
function c91258852.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡组中的「秘旋谍的秘密胜地」且卡组中存在其他可检索的「秘旋谍」怪兽
function c91258852.thfilter2(c,tp)
	return c:IsCode(54631665) and c:IsAbleToHand()
		-- 检查卡组中是否存在除该卡以外的、满足过滤条件3的「秘旋谍」怪兽
		and Duel.IsExistingMatchingCard(c91258852.thfilter3,tp,LOCATION_DECK,0,1,c)
end
-- 过滤条件：卡组中除「秘旋谍-高雅女士」以外的「秘旋谍」怪兽
function c91258852.thfilter3(c)
	return c:IsSetCard(0xee) and c:IsType(TYPE_MONSTER) and not c:IsCode(91258852) and c:IsAbleToHand()
end
-- 效果②的发动准备与可行性检查
function c91258852.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否能同时检索「秘旋谍的秘密胜地」和另一只「秘旋谍」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91258852.thfilter2,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：从卡组将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理逻辑：从卡组将「秘旋谍的秘密胜地」和1只「秘旋谍」怪兽加入手牌
function c91258852.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张「秘旋谍的秘密胜地」
	local g1=Duel.SelectMatchingCard(tp,c91258852.thfilter2,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g1:GetCount()>0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从卡组中选择1只「秘旋谍-高雅女士」以外的「秘旋谍」怪兽
		local g2=Duel.SelectMatchingCard(tp,c91258852.thfilter3,tp,LOCATION_DECK,0,1,1,g1:GetFirst())
		g1:Merge(g2)
		-- 将选中的两张卡加入手牌
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g1)
	end
end
