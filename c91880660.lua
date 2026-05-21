--仇すれば通図
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：双方玩家在自己主要阶段才能发动。把最多有对方场上的卡数量的卡从自己卡组上面翻开，从那之中选1张加入手卡。那之后，剩下的卡以及自己1张手卡用喜欢的顺序回到卡组下面。
-- ②：这张卡的①的效果是1次有9张以上翻开的玩家在那个回合的结束阶段才能发动。对方的场上·墓地的卡全部回到卡组。
local s,id,o=GetID()
-- 注册卡片发动时的效果，以及①、②效果的定义与注册
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：双方玩家在自己主要阶段才能发动。把最多有对方场上的卡数量的卡从自己卡组上面翻开，从那之中选1张加入手卡。那之后，剩下的卡以及自己1张手卡用喜欢的顺序回到卡组下面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
	-- ②：这张卡的①的效果是1次有9张以上翻开的玩家在那个回合的结束阶段才能发动。对方的场上·墓地的卡全部回到卡组。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e6:SetCategory(CATEGORY_TODECK)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCountLimit(1)
	e6:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCondition(s.tdcon)
	e6:SetTarget(s.tdtg)
	e6:SetOperation(s.tdop)
	c:RegisterEffect(e6)
end
-- ①效果的发动准备与合法性检测函数
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的卡片数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if chk==0 then
		-- 若自身卡组没有卡，则不能发动
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return false end
		-- 获取自身卡组最上方等同于对方场上卡片数量的卡片组
		local g=Duel.GetDecktopGroup(tp,ct)
		local result=g:FilterCount(Card.IsAbleToHand,nil)>0
		return result
	end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- ①效果的处理函数：翻开卡片、选卡加入手卡、将剩余卡及1张手卡放回卡组最下方
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取对方场上的卡片数量
	local ct=Duel.GetFieldGroupCount(p,0,LOCATION_ONFIELD)
	-- 获取自身卡组的卡片数量
	local dt=Duel.GetFieldGroupCount(p,LOCATION_DECK,0)
	ct=math.min(ct,dt)
	if ct==0 then return end
	local t={}
	for i=1,ct do t[i]=i end
	-- 让玩家选择并宣言一个数字，作为要翻开的卡片数量
	local ac=Duel.AnnounceNumber(p,table.unpack(t))
	-- 向双方玩家确认卡组最上方宣言数量的卡片
	Duel.ConfirmDecktop(p,ac)
	-- 获取卡组最上方宣言数量的卡片组
	local g=Duel.GetDecktopGroup(p,ac)
	if #g>0 then
		-- 提示玩家选择加入手卡的卡片
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(p,1,1,nil)
		if sg:GetFirst():IsAbleToHand() then
			-- 使接下来的操作不进行洗卡检测
			Duel.DisableShuffleCheck()
			-- 将选中的卡加入手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡
			Duel.ConfirmCards(1-p,sg)
			-- 洗切玩家的手卡
			Duel.ShuffleHand(p)
		else
			-- 使接下来的操作不进行洗卡检测
			Duel.DisableShuffleCheck()
			-- 若选中的卡无法加入手卡，则因规则送去墓地
			Duel.SendtoGrave(sg,REASON_RULE)
		end
		if #g>8 then
			-- 若翻开的卡片数量在9张以上，为该玩家和此卡注册回合结束阶段发动效果的标识
			Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
			e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
		end
	end
	-- 中断当前效果处理，使后续处理不视为同时进行
	Duel.BreakEffect()
	-- 获取玩家手卡中可以回到卡组的卡片组
	local hg=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
	if #hg>0 then
		-- 提示玩家选择要返回卡组的卡片
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=hg:Select(p,1,1,nil)
		if sg:GetFirst():GetOwner()==p then
			-- 若选中的手卡原本持有者是自己，则将其送回卡组最上方（以便后续与翻开的卡一起排序并放回卡组最下方）
			Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			-- 若选中的手卡原本持有者是对方，则直接送回对方卡组最下方，并减少需要排序移动的卡片数量
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			ac=ac-1
		end
	end
	if ac>0 then
		-- 让玩家对卡组最上方剩余的翻开卡片（及放回卡组顶的手卡）进行排序
		Duel.SortDecktop(p,p,ac)
		for i=1,ac do
			-- 获取卡组最上方的一张卡
			local mg=Duel.GetDecktopGroup(p,1)
			-- 将该卡移动到卡组最下方
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- ②效果的发动条件函数
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否在本回合翻开了9张以上的卡，且此卡仍带有相应的标识
	return Duel.GetFlagEffect(tp,id)>0 and e:GetHandler():GetFlagEffect(id)>0
end
-- ②效果的发动准备与合法性检测函数
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上或墓地是否存在可以回到卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 获取对方场上及墓地的所有卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 设置操作信息：将对方场上及墓地的卡片全部送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- ②效果的处理函数：将对方场上·墓地的卡全部回到卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上及墓地可以回到卡组的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 进行王家长眠之谷的无效化检测
	if aux.NecroValleyNegateCheck(g) then return end
	if g:GetCount()>0 then
		-- 将目标卡片全部送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
