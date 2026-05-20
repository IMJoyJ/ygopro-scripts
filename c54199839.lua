--メタファイズ・アセンション
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡丢弃1张「玄化」卡才能发动。自己从卡组抽1张。那之后，可以从卡组把1只「玄化」怪兽除外。
-- ②：这张卡被除外的场合才能发动。从卡组把「玄化升天」以外的1张「玄化」卡加入手卡。
function c54199839.initial_effect(c)
	-- ①：从手卡丢弃1张「玄化」卡才能发动。自己从卡组抽1张。那之后，可以从卡组把1只「玄化」怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,54199839)
	e1:SetCost(c54199839.cost)
	e1:SetTarget(c54199839.target)
	e1:SetOperation(c54199839.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。从卡组把「玄化升天」以外的1张「玄化」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,54199839)
	e2:SetTarget(c54199839.thtg)
	e2:SetOperation(c54199839.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中可以丢弃的「玄化」卡
function c54199839.cfilter(c)
	return c:IsSetCard(0x105) and c:IsDiscardable()
end
-- ①号效果的发动代价（Cost）处理函数
function c54199839.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外可以丢弃的「玄化」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c54199839.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手卡中的「玄化」卡作为发动代价
	Duel.DiscardHand(tp,c54199839.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- ①号效果的发动准备（Target）处理函数
function c54199839.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 向系统宣告此效果包含抽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 过滤条件：卡组中可以被除外的「玄化」怪兽
function c54199839.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x105) and c:IsAbleToRemove()
end
-- ①号效果的实际效果处理（Operation）函数
function c54199839.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡，并检查是否成功抽卡
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 获取卡组中所有满足条件的「玄化」怪兽
		local g=Duel.GetMatchingGroup(c54199839.filter,tp,LOCATION_DECK,0,nil)
		-- 若卡组中存在可除外的「玄化」怪兽，则询问玩家是否进行除外
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(54199839,0)) then  --"是否把1只「玄化」怪兽除外？"
			-- 中断当前效果，使后续的除外处理与抽卡不视为同时处理
			Duel.BreakEffect()
			-- 在客户端显示“请选择要除外的卡”的提示信息
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的「玄化」怪兽表侧表示除外
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 过滤条件：卡组中「玄化升天」以外可以加入手卡的「玄化」卡
function c54199839.thfilter(c)
	return c:IsSetCard(0x105) and not c:IsCode(54199839) and c:IsAbleToHand()
end
-- ②号效果的发动准备（Target）处理函数
function c54199839.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「玄化升天」以外可以加入手卡的「玄化」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c54199839.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统宣告此效果包含从卡组将卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的实际效果处理（Operation）函数
function c54199839.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端显示“请选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「玄化」卡
	local g=Duel.SelectMatchingCard(tp,c54199839.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
