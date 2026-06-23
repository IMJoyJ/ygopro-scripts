--魔砲戦機ダルマ・カルマ
-- 效果：
-- ①：场上的怪兽全部变成里侧守备表示。那之后，场上有表侧表示怪兽存在的场合，那控制者必须把自身场上的表侧表示怪兽全部送去墓地。
local s,id,o=GetID()
-- 注册卡片效果，设置为发动时点，可触发自由连锁，包含改变表示形式、送去墓地和盖放怪兽的分类
function s.initial_effect(c)
	-- ①：场上的怪兽全部变成里侧守备表示。那之后，场上有表侧表示怪兽存在的场合，那控制者必须把自身场上的表侧表示怪兽全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOGRAVE+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果处理时的判断函数，获取所有可以变为里侧表示的怪兽组
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取所有在主要怪兽区且可以变为里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息，表示将要改变怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
-- 效果发动时的处理函数，先将所有怪兽变为里侧守备表示，再判断是否需要将表侧表示怪兽送去墓地
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有在主要怪兽区且为表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将所有表侧表示怪兽变为里侧守备表示，若无怪兽被改变则返回
	if Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)<1 then return end
	-- 获取所有在主要怪兽区且为表侧表示的怪兽，用于后续处理
	local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for p=0,1 do
		-- 若某玩家无法将怪兽送去墓地，则从目标怪兽组中移除该玩家的怪兽
		if not Duel.IsPlayerCanSendtoGrave(p) then tg:Remove(Card.IsControler,nil,p) end
	end
	if #tg>0 then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 遍历当前回合玩家和对方玩家，分别处理各自场上的表侧表示怪兽
		for p in aux.TurnPlayers() do
			local sg=tg:Filter(Card.IsControler,nil,p)
			-- 将指定玩家场上的表侧表示怪兽以规则原因送去墓地
			Duel.SendtoGrave(sg,REASON_RULE,p)
		end
	end
end
