--ライトニング・ウォリアー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡战斗破坏对方怪兽送去墓地时，给与对方基本分对方手卡数量×300的数值的伤害。
function c87259077.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡战斗破坏对方怪兽送去墓地时，给与对方基本分对方手卡数量×300的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87259077,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCondition(c87259077.damcon)
	e1:SetTarget(c87259077.damtg)
	e1:SetOperation(c87259077.damop)
	c:RegisterEffect(e1)
end
-- 判定发动条件：这张卡战斗破坏怪兽并将其送去墓地。
function c87259077.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取战斗的攻击目标。
	local t=Duel.GetAttackTarget()
	-- 如果是这张卡被攻击，则将攻击怪兽作为被破坏的目标。
	if ev==1 then t=Duel.GetAttacker() end
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	return t:IsLocation(LOCATION_GRAVE) and t:IsType(TYPE_MONSTER)
end
-- 判定发动并设置效果目标：将对方玩家设为目标玩家，并注册伤害操作信息。
function c87259077.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设定为效果的对象玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁的操作信息，表明此效果会造成伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果处理：给与对方玩家其手卡数量×300的数值的伤害。
function c87259077.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的玩家（即对方玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 给与目标玩家其手卡数量×300的数值的效果伤害。
	Duel.Damage(p,Duel.GetFieldGroupCount(p,LOCATION_HAND,0)*300,REASON_EFFECT)
end
