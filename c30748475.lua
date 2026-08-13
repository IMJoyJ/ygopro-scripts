--魔砲戦機ダルマ・カルマ
-- 效果：
-- ①：场上的怪兽全部变成里侧守备表示。那之后，场上有表侧表示怪兽存在的场合，那控制者必须把自身场上的表侧表示怪兽全部送去墓地。
local s,id,o=GetID()
-- 定义初始化函数，创建并注册效果e1：设置效果分类为变更表示形式/送去墓地/盖放怪兽，类型为自由时点发动的效果，设置提示时点、目标函数和操作函数，使这张卡获得该效果。
function s.initial_effect(c)
	-- 对应效果原文：①：场上的怪兽全部变成里侧守备表示。那之后，场上有表侧表示怪兽存在的场合，那控制者必须把自身场上的表侧表示怪兽全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOGRAVE+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件检测与操作信息设置：获取双方场上所有可以变成里侧守备表示的怪兽；若没有则不能发动，若可以发动则登记本次将要进行的变更表示形式操作。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取以tp为视角、双方主要怪兽区中所有满足可以变成里侧守备表示的怪兽，存入组g。
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 将本次处理将执行的‘变更表示形式’分类、对象组g及数量写入连锁操作信息，供后续时点和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
-- 效果处理：先将双方场上所有表侧表示怪兽变为里侧守备表示，若没有变动则终止；随后获取仍为表侧表示的怪兽，排除控制者不能把卡送去墓地的情况；若还有剩余，则中断效果处理，按回合玩家顺序将每位玩家控制的表侧表示怪兽以规则理由全部送去墓地。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取以tp为视角、双方场上所有当前表侧表示的怪兽，存入组g。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将组g中的全部怪兽变为里侧守备表示；若变更数量少于1（没有怪兽被变里侧）则直接结束效果处理。
	if Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)<1 then return end
	-- 在变里侧处理后，再次获取双方场上仍存在的表侧表示怪兽，作为后续送墓处理的候选对象组tg。
	local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for p=0,1 do
		-- 如果玩家p不能把卡送去墓地，则从候选对象组tg中移除该玩家所控制的怪兽。
		if not Duel.IsPlayerCanSendtoGrave(p) then tg:Remove(Card.IsControler,nil,p) end
	end
	if #tg>0 then
		-- 调用Duel.BreakEffect()中断当前效果，使后续送墓处理与前面的变里侧守备处理被视为不同时点，避免错失时点。
		Duel.BreakEffect()
		-- 使用aux.TurnPlayers()依次获得当前回合玩家和对方，遍历两位玩家p。
		for p in aux.TurnPlayers() do
			local sg=tg:Filter(Card.IsControler,nil,p)
			-- 将玩家p控制的所有候选怪兽sg（即该玩家场上的表侧表示怪兽）以规则理由REASON_RULE全部送去墓地。
			Duel.SendtoGrave(sg,REASON_RULE,p)
		end
	end
end
