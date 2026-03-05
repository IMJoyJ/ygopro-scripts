--ジュラック・デイノ
-- 效果：
-- ①：这张卡战斗破坏对方怪兽的回合的结束阶段，把自己场上1只「朱罗纪」怪兽解放才能发动。自己抽2张。
function c17948378.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽的回合的结束阶段，把自己场上1只「朱罗纪」怪兽解放才能发动。自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测本次战斗是否为该卡与对方怪兽的战斗破坏
	e1:SetCondition(aux.bdocon)
	e1:SetOperation(c17948378.regop)
	c:RegisterEffect(e1)
	-- ①：这张卡战斗破坏对方怪兽的回合的结束阶段，把自己场上1只「朱罗纪」怪兽解放才能发动。自己抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17948378,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c17948378.drcon)
	e2:SetCost(c17948378.drcost)
	e2:SetTarget(c17948378.drtg)
	e2:SetOperation(c17948378.drop)
	c:RegisterEffect(e2)
end
-- 在战斗破坏对方怪兽时，为该卡注册一个标记，用于在结束阶段判断是否满足发动条件
function c17948378.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(17948378,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断该卡是否在战斗破坏对方怪兽的回合中被标记过，以确认是否可以发动效果
function c17948378.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(17948378)~=0
end
-- 检查玩家是否可以解放1只「朱罗纪」怪兽作为效果的代价
function c17948378.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以解放1只「朱罗纪」怪兽作为效果的代价
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x22) end
	-- 让玩家从场上选择1只「朱罗纪」怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x22)
	-- 将选中的「朱罗纪」怪兽从场上解放，作为效果的代价
	Duel.Release(g,REASON_COST)
end
-- 设置效果的目标为发动者本人，并设定抽卡数量为2
function c17948378.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的目标玩家为当前处理效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为2（表示抽2张卡）
	Duel.SetTargetParam(2)
	-- 设置效果的操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为2
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行抽卡效果，使目标玩家抽2张卡
function c17948378.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标玩家和目标参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家按照目标参数（抽卡数量）抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
