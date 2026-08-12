--虚無械アイン
-- 效果：
-- ①：这张卡只在场上表侧表示存在才有1次不会被对方的效果破坏。
-- ②：1回合1次，可以从以下效果选择1个发动。
-- ●从手卡丢弃1只10星怪兽才能发动。自己从卡组抽1张。
-- ●自己的魔法与陷阱区域没有这张卡以外的卡存在的场合，以自己墓地1只「时械神」怪兽为对象才能发动。那只怪兽回到卡组。那之后，可以从手卡·卡组选1张「无限械」在自己的魔法与陷阱区域盖放。
function c9409625.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这张卡只在场上表侧表示存在才有1次不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_NO_TURN_RESET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c9409625.valcon)
	c:RegisterEffect(e2)
	-- ②：1回合1次，可以从以下效果选择1个发动。●从手卡丢弃1只10星怪兽才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9409625,0))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c9409625.drcost)
	e3:SetTarget(c9409625.drtg)
	e3:SetOperation(c9409625.drop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，可以从以下效果选择1个发动。●自己的魔法与陷阱区域没有这张卡以外的卡存在的场合，以自己墓地1只「时械神」怪兽为对象才能发动。那只怪兽回到卡组。那之后，可以从手卡·卡组选1张「无限械」在自己的魔法与陷阱区域盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(9409625,1))  --"墓地回收"
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(c9409625.tdcon)
	e4:SetCost(c9409625.cost)
	e4:SetTarget(c9409625.tdtg)
	e4:SetOperation(c9409625.tdop)
	c:RegisterEffect(e4)
end
-- 抗性判定函数：判定是否为对方的效果破坏
function c9409625.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetHandlerPlayer()
end
-- 1回合1次选择效果发动的公共Cost函数，通过注册Flag限制每回合只能发动其中一个效果
function c9409625.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(9409625)==0 end
	c:RegisterFlagEffect(9409625,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数：筛选手卡中可以丢弃的10星怪兽
function c9409625.drfilter(c)
	return c:IsLevel(10) and c:IsDiscardable()
end
-- 抽卡效果的Cost函数：检查并执行丢弃手卡10星怪兽以及公共1回合1次限制
function c9409625.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的10星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c9409625.drfilter,tp,LOCATION_HAND,0,1,nil)
		and c9409625.cost(e,tp,eg,ep,ev,re,r,rp,0) end
	-- 让玩家选择并丢弃1张手卡中的10星怪兽作为Cost
	Duel.DiscardHand(tp,c9409625.drfilter,1,1,REASON_COST+REASON_DISCARD)
	c9409625.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 抽卡效果的Target函数：检查玩家是否能抽卡并设置抽卡操作信息
function c9409625.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置效果处理的操作信息为抽卡，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的Operation函数：执行抽卡处理
function c9409625.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤函数：筛选魔法与陷阱区域中除场地魔陷区以外的卡
function c9409625.ctfilter(c)
	return c:GetSequence()<5
end
-- 回收效果的Condition函数：检查自己的魔法与陷阱区域是否没有这张卡以外的卡存在
function c9409625.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的魔法与陷阱区域（不含场地）是否存在除这张卡以外的卡，若不存在则满足条件
	return not Duel.IsExistingMatchingCard(c9409625.ctfilter,tp,LOCATION_SZONE,0,1,e:GetHandler())
end
-- 过滤函数：筛选墓地中可以回到卡组的「时械神」怪兽
function c9409625.tdfilter(c)
	return c:IsSetCard(0x4a) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 回收效果的Target函数：选择墓地1只「时械神」怪兽作为对象，并设置回收操作信息
function c9409625.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c9409625.tdfilter(chkc) end
	-- 检查自己墓地是否存在可以回到卡组的「时械神」怪兽
	if chk==0 then return Duel.IsExistingTarget(c9409625.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只「时械神」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c9409625.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理的操作信息为将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 过滤函数：筛选手卡或卡组中可以盖放的「无限械」
function c9409625.setfilter(c)
	return c:IsCode(36894320) and c:IsSSetable()
end
-- 回收效果的Operation函数：执行将对象怪兽送回卡组，并可选择从手卡·卡组盖放「无限械」的处理
function c9409625.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡（即墓地的「时械神」怪兽）
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与效果相关，并将其送回卡组洗卡
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK) then
		-- 获取自己手卡和卡组中所有可以盖放的「无限械」
		local g=Duel.GetMatchingGroup(c9409625.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		-- 若存在可盖放的「无限械」，询问玩家是否选择盖放
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(9409625,2)) then  --"是否盖放「无限械」？"
			local sc=g:Select(tp,1,1,nil):GetFirst()
			-- 将选中的「无限械」在自己的魔法与陷阱区域盖放
			Duel.SSet(tp,sc)
		end
	end
end
