--ライディング・デュエル！アクセラレーション！
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，自己场上没有其他卡存在的场合，可以从卡组把1只「同调士」怪兽加入手卡。
-- ②：自己准备阶段发动。给这张卡放置1个信号指示物。
-- ③：把自己场上2个信号指示物取除，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。自己抽2张。那之后，选自己1张手卡送去墓地。
function c31006879.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，自己场上没有其他卡存在的场合，可以从卡组把1只「同调士」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31006879+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c31006879.activate)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段发动。给这张卡放置1个信号指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c31006879.ctcon)
	e2:SetTarget(c31006879.cttg)
	e2:SetOperation(c31006879.ctop)
	c:RegisterEffect(e2)
	-- ③：把自己场上2个信号指示物取除，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。自己抽2张。那之后，选自己1张手卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c31006879.drcost)
	e3:SetTarget(c31006879.drtg)
	e3:SetOperation(c31006879.drop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「同调士」怪兽
function c31006879.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1017) and c:IsAbleToHand()
end
-- 效果处理函数，当满足条件时从卡组检索1只「同调士」怪兽加入手牌
function c31006879.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在其他卡，若存在则不发动效果
	if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) then return end
	-- 获取满足条件的「同调士」怪兽组
	local g=Duel.GetMatchingGroup(c31006879.filter,tp,LOCATION_DECK,0,nil)
	-- 判断是否有满足条件的怪兽且玩家选择发动效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31006879,0)) then  --"是否从卡组把1只「同调士」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 判断是否为当前回合玩家
function c31006879.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 设置指示物效果的处理信息
function c31006879.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置要放置1个信号指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x104d)
end
-- 指示物放置效果的处理函数
function c31006879.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x104d,1)
end
-- 效果发动所需费用的检查函数
function c31006879.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除2个信号指示物作为费用
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x104d,2,REASON_COST)
		and e:GetHandler():IsAbleToGraveAsCost() end
	-- 移除2个信号指示物作为费用
	Duel.RemoveCounter(tp,1,0,0x104d,2,REASON_COST)
	-- 将自身送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置效果发动的目标和处理信息
function c31006879.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为2
	Duel.SetTargetParam(2)
	-- 设置效果处理为抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置效果处理为丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果发动的处理函数，抽2张卡并丢弃1张手牌
function c31006879.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 判断是否成功抽2张卡
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		-- 洗切玩家手牌
		Duel.ShuffleHand(p)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 丢弃玩家1张手牌
		Duel.DiscardHand(p,nil,1,1,REASON_EFFECT)
	end
end
