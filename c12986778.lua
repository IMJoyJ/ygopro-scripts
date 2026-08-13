--機皇帝の賜与
-- 效果：
-- 场上表侧表示存在的怪兽只有名字带有「机皇」的怪兽2只的场合才能发动。从自己卡组抽2张卡。这张卡发动的回合，自己不能进行战斗阶段。
function c12986778.initial_effect(c)
	-- 场上表侧表示存在的怪兽只有名字带有「机皇」的怪兽2只的场合才能发动。从自己卡组抽2张卡。这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c12986778.condition)
	e1:SetCost(c12986778.cost)
	e1:SetTarget(c12986778.target)
	e1:SetOperation(c12986778.activate)
	c:RegisterEffect(e1)
end
-- 检查场上表侧表示的怪兽是否恰好只有2只，且这2只都是名字带有「机皇」的怪兽，只有满足该条件时才能发动。
function c12986778.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方怪兽区域所有表侧表示怪兽的集合，用于统计场上表侧表示怪兽的数量和种族。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	return g:GetCount()==2 and g:GetFirst():IsSetCard(0x13) and g:GetNext():IsSetCard(0x13)
end
-- 作为发动代价阶段处理：确认当前处于主要阶段1，并给发动者附加本回合不能进入战斗阶段的誓约效果。
function c12986778.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定：当前阶段必须是主要阶段1，否则不能发动。
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1 end
	-- 从自己卡组抽2张卡。这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把“不能进入战斗阶段”的誓约效果注册到玩家tp身上，使其在本回合内生效。
	Duel.RegisterEffect(e1,tp)
end
-- 效果发动的目标设定：检查玩家能否抽2张卡，并将对象玩家设为发动者、参数设为2，同时登记抽卡操作信息。
function c12986778.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定玩家tp是否可以通过效果抽2张卡（检查是否有不能抽卡的限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将本次效果的对象玩家设置为tp，即最终抽卡的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将本次效果的对象参数设置为2，即抽卡数量。
	Duel.SetTargetParam(2)
	-- 向系统登记本次连锁处理将进行抽2张卡的操作，使其他卡能正确响应抽卡行为。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理阶段：根据之前设定的对象玩家和抽卡数量，实际执行抽卡。
function c12986778.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取出本次连锁记录中的对象玩家p和对象参数d，即抽卡者和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，完成抽卡处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
