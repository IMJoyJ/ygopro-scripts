--魔法の国の王女－クラン
-- 效果：
-- 这张卡不能通常召唤。这张卡只能通过「王女的试炼」的效果才能特殊召唤。自己准备阶段时，给与对方基本分对方场上存在的怪兽数量×600分数值的伤害。
function c2316186.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。这张卡只能通过「王女的试炼」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己准备阶段时，给与对方基本分对方场上存在的怪兽数量×600分数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2316186,0))  --"LP伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c2316186.condition)
	e2:SetTarget(c2316186.target)
	e2:SetOperation(c2316186.operation)
	c:RegisterEffect(e2)
end
-- 效果发动条件判断：仅当此卡的控制者是当前回合玩家（自己的准备阶段）时才满足条件，从而在己方准备阶段发动。
function c2316186.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否等于效果发动者tp，若是则条件成立，保证只在控制者的准备阶段发动。
	return tp==Duel.GetTurnPlayer()
end
-- 发动时的目标与操作信息设定：计算对方场上怪兽数量×600作为伤害值，设置对方为对象玩家，并登记伤害操作信息。
function c2316186.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得对方场上（tp的对方区域）存在的怪兽数量，作为伤害倍率基数。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 将本连锁的对象玩家设置为对方（1-tp），使效果以对方为对象。
	Duel.SetTargetPlayer(1-tp)
	-- 登记操作信息：此连锁将造成伤害，伤害数值为对方怪兽数量×600，目标玩家为对方。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*600)
end
-- 效果处理实际执行：取出对象玩家，重新取得对方场上怪兽数量，并给予对方相应伤害。
function c2316186.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家，即之前设定的对方玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 处理时再次计算对方场上存在的怪兽数量，以确定最终伤害数值。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 给予对象玩家（对方）对方场上怪兽数量×600的伤害，原因为效果伤害。
	Duel.Damage(p,ct*600,REASON_EFFECT)
end
