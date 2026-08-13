--ジュラック・デイノ
-- 效果：
-- ①：这张卡战斗破坏对方怪兽的回合的结束阶段，把自己场上1只「朱罗纪」怪兽解放才能发动。自己抽2张。
function c17948378.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的回合的结束阶段
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置e1的发动条件为aux.bdocon，即此卡只有与对方怪兽战斗并战斗破坏对方怪兽时才触发
	e1:SetCondition(aux.bdocon)
	e1:SetOperation(c17948378.regop)
	c:RegisterEffect(e1)
	-- 把自己场上1只「朱罗纪」怪兽解放才能发动。自己抽2张。
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
-- 战斗破坏对方怪兽时，给自身注册一个flag标记，标记持续到结束阶段后重置，用于记录本回合曾战斗破坏过对方怪兽
function c17948378.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(17948378,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 抽卡效果的发动条件：检查自身存在本回合战斗破坏对方怪兽的flag标记（即满足“这张卡战斗破坏对方怪兽的回合的结束阶段”）
function c17948378.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(17948378)~=0
end
-- 抽卡效果的发动代价：解放自己场上1只「朱罗纪」怪兽
function c17948378.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）检查自己场上是否存在至少1只满足「朱罗纪」字段且可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x22) end
	-- 选择自己场上1只满足「朱罗纪」字段的怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x22)
	-- 将选择的怪兽解放，作为发动代价（REASON_COST）
	Duel.Release(g,REASON_COST)
end
-- 抽卡效果的发动时目标设定：确认可以抽2张卡，并指定抽卡玩家、抽卡数量及操作信息
function c17948378.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）确认玩家tp是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将本次效果的对象玩家设置为发动玩家tp
	Duel.SetTargetPlayer(tp)
	-- 将本次效果的对象参数设置为2，即抽卡数量
	Duel.SetTargetParam(2)
	-- 向系统登记操作信息：本次效果分类为抽卡（CATEGORY_DRAW），预计影响玩家tp，处理时抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理时，根据连锁中保存的目标玩家和抽卡数量执行抽卡
function c17948378.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取出之前设置的目标玩家p和抽卡参数d
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p抽d张卡（d=2），抽卡原因记为效果（REASON_EFFECT）
	Duel.Draw(p,d,REASON_EFFECT)
end
