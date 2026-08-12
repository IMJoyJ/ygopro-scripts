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
-- 效果处理时设置抽卡目标玩家和抽卡数量
function c30914564.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的目标玩家设置为当前处理的玩家
	Duel.SetTargetPlayer(tp)
	-- 将效果的目标参数设置为1（表示抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果发动时执行的抽卡操作
function c30914564.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家从卡组抽指定数量的卡，原因设为效果
	Duel.Draw(p,d,REASON_EFFECT)
end
