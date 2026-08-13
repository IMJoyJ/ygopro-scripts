--聖鳥クレイン
-- 效果：
-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张。
function c30914564.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30914564,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c30914564.target)
	e1:SetOperation(c30914564.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的检查与登记函数：chk==0时返回true表示可以发动，然后设定抽卡玩家为发动者自己、抽卡数量为1，并登记抽卡的操作信息。
function c30914564.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为效果发动者自身，即指定由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 设置效果的对象参数为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 登记本次效果处理的操作信息：效果分类为抽卡，不指定对象卡，抽卡玩家为tp，抽卡张数为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时的执行函数：从连锁信息中取得目标玩家和抽卡张数，让该玩家执行抽卡。
function c30914564.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出效果的对象玩家和参数值（即抽卡玩家和抽卡张数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，完成“自己从卡组抽1张”的处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
