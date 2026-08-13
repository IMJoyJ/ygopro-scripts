--エンペラー・オーダー
-- 效果：
-- ①：需怪兽召唤成功时发动的怪兽的效果发动时才能把这个效果发动。那个发动无效。那之后，发动无效的玩家从卡组抽1张。
function c35011819.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：需怪兽召唤成功时发动的怪兽的效果发动时才能把这个效果发动。那个发动无效。那之后，发动无效的玩家从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35011819,0))  --"无效并抽卡"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c35011819.condition)
	e2:SetTarget(c35011819.target)
	e2:SetOperation(c35011819.activate)
	c:RegisterEffect(e2)
end
-- 此函数为效果e2的发动条件判断：确认当前连锁的效果re是怪兽效果，且该效果是在怪兽召唤成功时发动的效果（re的Code为EVENT_SUMMON_SUCCESS），并且该连锁的发动能够被无效。
function c35011819.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 该行条件判断明确三点：re是怪兽效果；re的触发事件为召唤成功（EVENT_SUMMON_SUCCESS）；该连锁可被无效化，三者同时满足时才允许发动本卡。
	return re:IsActiveType(TYPE_MONSTER) and re:GetCode()==EVENT_SUMMON_SUCCESS and Duel.IsChainNegatable(ev)
end
-- 发动时确定对象与抽卡信息：在合法性检查阶段确认被无效的玩家rp能够抽1张卡；然后写入无效对象为eg、数目为1，记录对象玩家为rp、抽卡参数为1，并设置抽卡操作信息，使效果处理时可对rp执行抽1张。
function c35011819.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动的合法性检查（chk==0）中，判断该连锁的发动玩家rp是否能抽1张卡，若不能则本效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(rp,1) end
	-- 将eg（即正在发动的需怪兽召唤成功时发动的怪兽效果所对应的卡）写入连锁的无效对象，数量为1，使该发动在规则上被标记为将被无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 将当前连锁的对象玩家记录为rp，即那个被无效的发动所属的玩家，以便后续由该玩家抽卡。
	Duel.SetTargetPlayer(rp)
	-- 将当前连锁的对象参数记录为1，表示后续抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置抽卡的操作信息：目标玩家为rp，数量为1，但具体抽的卡在效果处理时确定，因此targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,rp,1)
end
-- 效果处理的执行：首先尝试无效当前连锁（ev）的发动，若无效成功，则取出之前记录的玩家p和抽卡数量d，让p抽d张卡。
function c35011819.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 对当前连锁ev执行发动无效；若无效失败（例如因其他效果保护而未能无效），则直接终止本次效果处理。
	if not Duel.NegateActivation(ev) then return end
	-- 从当前连锁的信息中取出之前保存的对象玩家p（由SetTargetPlayer记录）和对象参数d（由SetTargetParam记录的抽卡张数），用于后续抽卡。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 令玩家p从卡组抽d张卡（d为1），抽卡原因是效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
