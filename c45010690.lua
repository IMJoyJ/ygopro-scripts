--フラボット
-- 效果：
-- ①：这张卡被送去墓地的场合发动。自己从卡组抽1张。那之后，1张手卡回到持有者卡组最上面。
function c45010690.initial_effect(c)
	-- ①：这张卡被送去墓地的场合发动。自己从卡组抽1张。那之后，1张手卡回到持有者卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45010690,0))  --"把自己1张手卡放在卡组最上面"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c45010690.target)
	e1:SetOperation(c45010690.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时进行合法性检查（必发效果，无条件可发动），记录发动玩家与抽卡数量，并设置抽卡和回卡组的操作信息。
function c45010690.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为发动者tp，明确效果影响的玩家（自己）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，表示接下来要抽1张卡。
	Duel.SetTargetParam(1)
	-- 登记抽卡效果的操作信息：玩家tp抽1张卡（CATEGORY_DRAW）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 登记回卡组效果的操作信息：从玩家tp的手卡选1张卡返回卡组（CATEGORY_TODECK）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：玩家抽1张卡；若抽卡成功，则中断时点，提示选1张手卡，并将其返回持有者卡组最上面。
function c45010690.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家p和对象参数d（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 玩家p以效果原因抽d张卡，若实际抽卡数为0则终止处理，不执行后续回卡组。
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	-- 中断当前效果处理，使抽卡和之后的回卡组视为不同时处理，避免错过时点。
	Duel.BreakEffect()
	-- 向玩家p显示选择提示“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家p从自己的手卡中选择1张能够返回卡组的卡。
	local g=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手卡g以效果原因返回持有者卡组最顶端。
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
end
