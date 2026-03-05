--イービル・マインド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有恶魔族怪兽存在的场合，可以从对方墓地的怪兽数量的以下效果选择1个发动。
-- ●1只以上：自己从卡组抽1张。
-- ●4只以上：从卡组把1只「英雄」怪兽或者1张「暗黑融合」加入手卡。
-- ●10只以上：从卡组把1张「融合」魔法卡加入手卡。
function c18438874.initial_effect(c)
	-- 记录此卡与「暗黑融合」的关联
	aux.AddCodeList(c,94820406)
	-- ①：自己场上有恶魔族怪兽存在的场合，可以从对方墓地的怪兽数量的以下效果选择1个发动。●1只以上：自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18438874,0))  --"抽1张卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,18438874+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c18438874.condition)
	e1:SetTarget(c18438874.drtg)
	e1:SetOperation(c18438874.drop)
	c:RegisterEffect(e1)
	-- ①：自己场上有恶魔族怪兽存在的场合，可以从对方墓地的怪兽数量的以下效果选择1个发动。●4只以上：从卡组把1只「英雄」怪兽或者1张「暗黑融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18438874,1))  --"检索「英雄」怪兽或「暗黑融合」"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,18438874+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(c18438874.condition)
	e2:SetTarget(c18438874.thtg1)
	e2:SetOperation(c18438874.thop1)
	c:RegisterEffect(e2)
	-- ①：自己场上有恶魔族怪兽存在的场合，可以从对方墓地的怪兽数量的以下效果选择1个发动。●10只以上：从卡组把1张「融合」魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18438874,2))  --"检索「融合」魔法卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,18438874+EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(c18438874.condition)
	e3:SetTarget(c18438874.thtg2)
	e3:SetOperation(c18438874.thop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在恶魔族怪兽
function c18438874.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 效果发动条件，判断自己场上是否存在恶魔族怪兽
function c18438874.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在恶魔族怪兽
	return Duel.IsExistingMatchingCard(c18438874.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 抽卡效果的处理函数，用于设置抽卡效果的目标和信息
function c18438874.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计对方墓地中的怪兽数量
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_GRAVE,nil,TYPE_MONSTER)
	-- 检查是否满足抽卡条件（对方墓地有怪兽）
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,1) end
	-- 向对方提示发动了抽卡效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽1张卡
	Duel.SetTargetParam(1)
	-- 设置效果操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的执行函数，用于实际执行抽卡
function c18438874.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤函数，用于检索「英雄」怪兽或「暗黑融合」
function c18438874.thfilter1(c)
	return c:IsAbleToHand() and (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8) or c:IsCode(94820406))
end
-- 检索「英雄」怪兽或「暗黑融合」效果的处理函数，用于设置检索效果的目标和信息
function c18438874.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计对方墓地中的怪兽数量
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_GRAVE,nil,TYPE_MONSTER)
	-- 检查是否满足检索「英雄」怪兽或「暗黑融合」的条件（对方墓地有4只以上怪兽）
	if chk==0 then return ct>=4 and Duel.IsExistingMatchingCard(c18438874.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方提示发动了检索「英雄」怪兽或「暗黑融合」效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果操作信息为检索效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索「英雄」怪兽或「暗黑融合」效果的执行函数，用于实际执行检索
function c18438874.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c18438874.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于检索「融合」魔法卡
function c18438874.thfilter2(c)
	return c:IsAbleToHand() and c:IsType(TYPE_SPELL) and c:IsSetCard(0x46)
end
-- 检索「融合」魔法卡效果的处理函数，用于设置检索效果的目标和信息
function c18438874.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计对方墓地中的怪兽数量
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_GRAVE,nil,TYPE_MONSTER)
	-- 检查是否满足检索「融合」魔法卡的条件（对方墓地有10只以上怪兽）
	if chk==0 then return ct>=10 and Duel.IsExistingMatchingCard(c18438874.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方提示发动了检索「融合」魔法卡效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果操作信息为检索效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索「融合」魔法卡效果的执行函数，用于实际执行检索
function c18438874.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c18438874.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
