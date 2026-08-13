--凡骨の意地
-- 效果：
-- 当抽卡阶段抽到的卡是通常怪兽的场合，向对方展示抽到的卡，就可以再抽1张卡。
function c35762283.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 当抽卡阶段抽到的卡是通常怪兽的场合，向对方展示抽到的卡，就可以再抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35762283,0))  --"抽卡"
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetCondition(c35762283.drcon)
	e2:SetCost(c35762283.drcost)
	e2:SetTarget(c35762283.drtg)
	e2:SetOperation(c35762283.drop)
	c:RegisterEffect(e2)
end
-- 定义凡骨的意志的诱发效果发动条件：仅当这张卡的控制者是回合玩家且当前为抽卡阶段时才满足，即只能在自己抽卡阶段发动。
function c35762283.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真条件：当前回合玩家是效果控制者且当前阶段为抽卡阶段，确保效果只在己方抽卡阶段可以发动。
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW
end
-- 定义筛选函数：抽到的卡必须是通常怪兽且当前不处于公开状态（即需要展示的手牌）。
function c35762283.filter(c)
	return c:IsType(TYPE_NORMAL) and not c:IsPublic()
end
-- 定义效果的代价：从这次抽到的卡中筛选出通常怪兽；若只有一张则直接向对方展示，若有多张则让控制者选择一张展示，随后洗切手牌以隐藏手牌顺序信息。
function c35762283.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ep==tp and eg:IsExists(c35762283.filter,1,nil) end
	local g=eg:Filter(c35762283.filter,nil)
	if g:GetCount()==1 then
		-- 将抽到的通常怪兽卡组展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示后洗切己方手牌，使手牌顺序重新随机化，防止暴露手牌排列信息。
		Duel.ShuffleHand(tp)
	else
		-- 弹出选择提示，让控制者选择一张要展示给对方确认的卡；HINTMSG_CONFIRM表示“请选择给对方确认的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将玩家选出的那张通常怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
		-- 展示后洗切己方手牌，避免手牌顺序信息泄露。
		Duel.ShuffleHand(tp)
	end
end
-- 定义效果发动时的目标设定：确认可以抽卡后，将效果的对象玩家设为控制者自己、抽卡数量设为1，并登记抽卡效果的操作信息。
function c35762283.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认当前玩家可以抽1张卡，若不能则不能发动此效果。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为这张卡的控制者（自己），表示随后抽卡的玩家是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，表示随后抽卡的数量为1张。
	Duel.SetTargetParam(1)
	-- 登记操作信息：本次连锁包含抽卡效果，目标玩家为tp，预计抽1张；由于抽卡数量在效果处理时确定，目标卡组为nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果处理操作：从连锁信息中取出设定的对象玩家和抽卡数量，让该玩家以效果原因抽对应数量的卡。
function c35762283.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁中记录的对象玩家（要抽卡的玩家）和对象参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽d张卡，完成“再抽1张卡”的效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
