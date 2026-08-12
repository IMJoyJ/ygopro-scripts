--蘇りし天空神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，那些发动和效果不会被无效化。
-- ①：从自己墓地选1只「奥西里斯之天空龙」特殊召唤。那之后，双方各自直到手卡变成6张为止从卡组抽卡。
-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地选1张「死者苏生」在卡组最上面放置。自己墓地有幻神兽族怪兽存在的场合，再让自己从卡组抽1张。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 建立卡片与「奥西里斯之天空龙」的关联，用于卡片检索或效果关联判定
	aux.AddCodeList(c,10000020)
	-- ①：从自己墓地选1只「奥西里斯之天空龙」特殊召唤。那之后，双方各自直到手卡变成6张为止从卡组抽卡。这个卡名的效果的发动和效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地选1张「死者苏生」在卡组最上面放置。自己墓地有幻神兽族怪兽存在的场合，再让自己从卡组抽1张。这个卡名的效果的发动和效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	-- 发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.dttg)
	e2:SetOperation(s.dtop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地中可以特殊召唤的「奥西里斯之天空龙」
function s.spfilter(c,e,tp)
	return c:IsCode(10000020) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己手卡到6张为止需要抽卡的数量
	local ct1=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 计算对方手卡到6张为止需要抽卡的数量
	local ct2=6-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「奥西里斯之天空龙」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查双方是否都需要抽卡且都可以执行抽卡
		and ct1>0 and Duel.IsPlayerCanDraw(tp,ct1) and ct2>0 and Duel.IsPlayerCanDraw(1-tp,ct2) end
	-- 设置连锁处理信息：从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	-- 设置连锁处理信息：双方玩家抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,ct1+ct2)
end
-- ①号效果的执行逻辑函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有空余的怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「奥西里斯之天空龙」（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 若成功将选中的怪兽以表侧表示特殊召唤
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local bk=true
		-- 遍历双方玩家（从当前回合玩家开始）
		for p in aux.TurnPlayers() do
			-- 获取当前遍历玩家的手卡数量
			local ct=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
			if 6-ct>0 then
				if bk then
					bk=false
					-- 中断效果连接，使后续的抽卡处理与特殊召唤不视为同时进行
					Duel.BreakEffect()
				end
				-- 让该玩家从卡组抽卡，直到手卡变成6张
				Duel.Draw(p,6-ct,REASON_EFFECT)
			end
		end
	end
end
-- 过滤条件：卡名为「死者苏生」且在卡组中或可以回到卡组
function s.cfilter(c)
	return c:IsCode(83764718) and (c:IsLocation(LOCATION_DECK) or c:IsAbleToDeck())
end
-- ②号效果的发动准备与合法性检测函数
function s.dttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在「死者苏生」
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 检查自己墓地是否存在幻神兽族怪兽
	if Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_DIVINE) then
		-- 若墓地有幻神兽族，则设置连锁处理信息：自己抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- ②号效果的执行逻辑函数
function s.dtop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到卡组最上面的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要放置到卡组最上面的卡"
	-- 从自己的卡组或墓地选择1张「死者苏生」（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.cfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		if tc:IsLocation(LOCATION_DECK) then
			-- 若选中的卡在卡组中，则将其移动到卡组最上面
			Duel.MoveSequence(tc,SEQ_DECKTOP)
		else
			-- 若选中的卡在墓地，则将其送回卡组最上面
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
		-- 确认自己卡组最上方的一张卡
		Duel.ConfirmDecktop(tp,1)
		-- 检查自己墓地是否存在幻神兽族怪兽
		if Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_DIVINE) then
			-- 中断效果连接，使后续的抽卡处理与放置卡片不视为同时进行
			Duel.BreakEffect()
			-- 从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
