--イービル・マインド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有恶魔族怪兽存在的场合，可以从对方墓地的怪兽数量的以下效果选择1个发动。
-- ●1只以上：自己从卡组抽1张。
-- ●4只以上：从卡组把1只「英雄」怪兽或者1张「暗黑融合」加入手卡。
-- ●10只以上：从卡组把1张「融合」魔法卡加入手卡。
function c18438874.initial_effect(c)
	-- 记录「暗黑融合」（94820406）为这张卡记载的卡名，用于支持从卡组检索「暗黑融合」。
	aux.AddCodeList(c,94820406)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有恶魔族怪兽存在的场合，可以从对方墓地的怪兽数量的以下效果选择1个发动。●1只以上：自己从卡组抽1张。
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
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有恶魔族怪兽存在的场合，可以从对方墓地的怪兽数量的以下效果选择1个发动。●4只以上：从卡组把1只「英雄」怪兽或者1张「暗黑融合」加入手卡。
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
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有恶魔族怪兽存在的场合，可以从对方墓地的怪兽数量的以下效果选择1个发动。●10只以上：从卡组把1张「融合」魔法卡加入手卡。
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
-- 过滤函数：判断卡片是否为表侧表示且种族为恶魔族，用于检查自己场上是否存在满足条件的恶魔族怪兽。
function c18438874.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 效果发动条件：自己场上存在至少1只表侧表示且种族为恶魔族的怪兽时，效果才允许发动。
function c18438874.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以我方（tp）视角的场上主要怪兽区是否存在至少1只满足cfilter的怪兽（表侧表示恶魔族），存在则返回true。
	return Duel.IsExistingMatchingCard(c18438874.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 抽卡效果的目标判定与选择：统计对方墓地怪兽数量，确认满足「1只以上」且我方可以抽卡；设置目标玩家为自己、抽卡数为1，并登记抽卡操作信息。
function c18438874.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计对方墓地中怪兽卡的数量，作为选择发动分支（1只/4只/10只以上）的条件依据。
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_GRAVE,nil,TYPE_MONSTER)
	-- 发动时合法性检查（chk==0）：对方墓地怪兽数量>0且我方可以抽1张卡，才允许发动此分支。
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,1) end
	-- 向对方玩家提示我方发动的是「抽1张卡」这一效果分支，使用对应效果描述文本。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将当前连锁效果的目标玩家设置为我方，表示抽卡动作的对象是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁效果的目标参数设置为1，表示抽卡张数为1。
	Duel.SetTargetParam(1)
	-- 向系统登记本次操作信息：类别为抽卡（CATEGORY_DRAW），目标玩家为自己，抽卡数为1，供其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：从连锁信息中取得目标玩家和抽卡数，并让该玩家以效果原因抽相应数量的卡，即自己抽1张卡。
function c18438874.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家（CHAININFO_TARGET_PLAYER）和目标参数（CHAININFO_TARGET_PARAM），分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽d张卡；此处即自己抽1张。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤函数：判断卡片能否加入手牌，且卡片为「英雄」字段怪兽或卡号94820406（「暗黑融合」），用于检索条件。
function c18438874.thfilter1(c)
	return c:IsAbleToHand() and (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8) or c:IsCode(94820406))
end
-- 检索「英雄」怪兽或「暗黑融合」的目标判定：统计对方墓地怪兽数量，确认≥4且卡组存在符合条件的卡，并登记检索操作信息。
function c18438874.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计对方墓地中怪兽卡的数量，作为判断是否满足「4只以上」分支的条件。
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_GRAVE,nil,TYPE_MONSTER)
	-- 发动时合法性检查（chk==0）：对方墓地怪兽数量≥4且卡组中存在至少1张满足thfilter1的卡，才允许发动此分支。
	if chk==0 then return ct>=4 and Duel.IsExistingMatchingCard(c18438874.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示我方发动的是「检索「英雄」怪兽或「暗黑融合」」这一效果分支。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 向系统登记本次操作信息：类别为回手牌+检索（CATEGORY_TOHAND+CATEGORY_SEARCH），从卡组选1张加入手牌，目标玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：显示从卡组选择加入手牌的提示，选出1张满足条件的卡加入手牌，并向对方公开确认。
function c18438874.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选出1张满足thfilter1条件（「英雄」怪兽或「暗黑融合」）的卡。
	local g=Duel.SelectMatchingCard(tp,c18438874.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的那张卡，使检索过程公开。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：判断卡片能否加入手牌，且是魔法卡并属于「融合」（字段0x46）魔法卡，用于检索“「融合」魔法卡”。
function c18438874.thfilter2(c)
	return c:IsAbleToHand() and c:IsType(TYPE_SPELL) and c:IsSetCard(0x46)
end
-- 检索「融合」魔法卡的目标判定：统计对方墓地怪兽数量，确认≥10且卡组存在符合条件的卡，并登记检索操作信息。
function c18438874.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计对方墓地中怪兽卡的数量，作为判断是否满足「10只以上」分支的条件。
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_GRAVE,nil,TYPE_MONSTER)
	-- 发动时合法性检查（chk==0）：对方墓地怪兽数量≥10且卡组中存在至少1张满足thfilter2的卡，才允许发动此分支。
	if chk==0 then return ct>=10 and Duel.IsExistingMatchingCard(c18438874.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示我方发动的是「检索「融合」魔法卡」这一效果分支。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 向系统登记本次操作信息：类别为回手牌+检索，从卡组选1张魔法卡加入手牌，目标玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：显示从卡组选择加入手牌的提示，选出1张「融合」魔法卡加入手牌，并向对方公开确认。
function c18438874.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选出1张满足thfilter2条件的卡（「融合」魔法卡）。
	local g=Duel.SelectMatchingCard(tp,c18438874.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的那张卡，使检索过程公开。
		Duel.ConfirmCards(1-tp,g)
	end
end
