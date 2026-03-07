--英知の代行者 マーキュリー
-- 效果：
-- ①：对方回合结束时，这张卡在自己的怪兽区域表侧表示存在，自己手卡是0张的场合，下次的自己准备阶段发动。自己从卡组抽1张。
function c38730226.initial_effect(c)
	-- 创建一个场地区域的永续效果，于对方回合结束时发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c38730226.con)
	e1:SetOperation(c38730226.op)
	c:RegisterEffect(e1)
end
-- 判断条件：当前回合玩家不是自己且自己手卡为0张
function c38730226.con(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己并且自己手卡数量为0
	return Duel.GetTurnPlayer()~=tp and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 创建一个诱发必发效果，于自己的准备阶段发动
function c38730226.op(e,tp,eg,ep,ev,re,r,rp)
	-- 设置效果为准备阶段抽卡效果，且该效果在自己场上发动
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(38730226,0))  --"下一个准备阶段时抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c38730226.dtg)
	e1:SetOperation(c38730226.dop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY)
	e:GetHandler():RegisterEffect(e1)
end
-- 设置效果处理时的目标玩家和抽卡数量
function c38730226.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置效果处理信息为抽卡效果，目标玩家为自己，抽卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 设置效果处理时执行抽卡操作
function c38730226.dop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
