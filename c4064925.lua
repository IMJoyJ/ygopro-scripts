--古代の進軍
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能把卡盖放。
-- ①：作为这张卡的发动时的效果处理，从卡组把「古代的进军」以外的1张「古代的机械」魔法·陷阱卡加入手卡。
-- ②：1回合1次，把自己场上1只怪兽解放才能发动。自己抽1张，这个回合中，以下效果适用。
-- ●自己在「古代的机械巨人」或者有那个卡名记述的5星以上的怪兽召唤的场合需要的解放可以不用。
function c4064925.initial_effect(c)
	-- 记录此卡效果文本上记载着「古代的机械巨人」这张卡
	aux.AddCodeList(c,83104731)
	-- ①：作为这张卡的发动时的效果处理，从卡组把「古代的进军」以外的1张「古代的机械」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,4064925+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c4064925.cost)
	e1:SetTarget(c4064925.target)
	e1:SetOperation(c4064925.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把自己场上1只怪兽解放才能发动。自己抽1张，这个回合中，以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4064925,0))  --"解放怪兽并抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c4064925.drcost)
	e2:SetTarget(c4064925.drtg)
	e2:SetOperation(c4064925.drop)
	c:RegisterEffect(e2)
	if not c4064925.global_check then
		c4064925.global_check=true
		-- 注册全局时点效果，用于检测玩家是否在回合中设置了卡
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(c4064925.checkop)
		-- 将效果e1注册给全局环境，用于记录玩家是否在回合中设置了卡
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_MSET)
		-- 将效果e2注册给全局环境，用于记录玩家是否在回合中设置了卡
		Duel.RegisterEffect(ge2,0)
		local ge3=ge1:Clone()
		ge3:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge3:SetCondition(c4064925.ssetcon)
		-- 将效果e3注册给全局环境，用于记录玩家是否在回合中设置了卡
		Duel.RegisterEffect(ge3,0)
		local ge4=ge1:Clone()
		ge4:SetCode(EVENT_CHANGE_POS)
		ge4:SetCondition(c4064925.cpcon)
		-- 将效果e4注册给全局环境，用于记录玩家是否在回合中设置了卡
		Duel.RegisterEffect(ge4,0)
	end
end
-- 当玩家设置卡时，为该玩家注册标识效果
function c4064925.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家注册标识效果，用于记录玩家是否在回合中设置了卡
	Duel.RegisterFlagEffect(rp,4064925,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数，用于判断卡是否为里侧表示
function c4064925.cfilter(c)
	return c:IsFacedown()
end
-- 判断是否设置了里侧表示的卡
function c4064925.ssetcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c4064925.cfilter,1,nil)
end
-- 过滤函数，用于判断卡是否从表侧表示变为里侧表示
function c4064925.cfilter2(c)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown()
end
-- 判断是否发生了卡从表侧表示变为里侧表示的情况
function c4064925.cpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c4064925.cfilter2,1,nil)
end
-- 发动时的费用处理，检查是否已使用过此卡的发动次数
function c4064925.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否已使用过此卡的发动次数
	if chk==0 then return Duel.GetFlagEffect(tp,4064925)==0 end
	-- ①：作为这张卡的发动时的效果处理，从卡组把「古代的进军」以外的1张「古代的机械」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetTargetRange(1,0)
	-- 设置效果目标为任意卡
	e1:SetTarget(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SSET)
	-- 将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_TURN_SET)
	-- 将效果e3注册给玩家tp
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e4:SetTarget(c4064925.sumlimit)
	-- 将效果e4注册给玩家tp
	Duel.RegisterEffect(e4,tp)
end
-- 限制特殊召唤位置的效果处理函数
function c4064925.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumpos,POS_FACEDOWN)>0
end
-- 过滤函数，用于筛选「古代的机械」魔法·陷阱卡
function c4064925.filter(c)
	return not c:IsCode(4064925) and c:IsSetCard(0x7) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsAbleToHand()
end
-- 设置连锁操作信息，用于检索满足条件的卡
function c4064925.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否拥有满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c4064925.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，用于检索满足条件的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 发动效果，选择并检索满足条件的卡
function c4064925.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c4064925.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认玩家看到被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②：1回合1次，把自己场上1只怪兽解放才能发动。自己抽1张，这个回合中，以下效果适用。
function c4064925.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以解放至少1张卡
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择要解放的卡
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil,tp)
	-- 解放卡
	Duel.Release(g,REASON_COST)
end
-- 设置连锁操作信息，用于抽卡
function c4064925.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作信息的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作信息的目标参数
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息，用于抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 发动效果，抽卡并注册召唤限制效果
function c4064925.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 判断是否成功抽卡且未使用过召唤限制效果
	if Duel.Draw(p,d,REASON_EFFECT)~=0 and Duel.GetFlagEffect(tp,4064926)==0 then
		-- ②：1回合1次，把自己场上1只怪兽解放才能发动。自己抽1张，这个回合中，以下效果适用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(4064925,2))  --"使用「古代的进军」的效果召唤"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetTargetRange(LOCATION_HAND,0)
		e1:SetCountLimit(1,4064925)
		e1:SetCondition(c4064925.ntcon)
		e1:SetTarget(c4064925.nttg)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果e1注册给玩家tp
		Duel.RegisterEffect(e1,tp)
		-- 为玩家注册标识效果，用于记录是否已使用过召唤限制效果
		Duel.RegisterFlagEffect(tp,4064926,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
	end
end
-- 召唤限制效果的条件函数
function c4064925.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断召唤是否满足条件
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 召唤限制效果的目标函数
function c4064925.nttg(e,c)
	-- 判断召唤目标是否满足条件
	return c:IsLevelAbove(5) and (c:IsCode(83104731) or aux.IsCodeListed(c,83104731))
end
