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
-- 判断是否为当前回合玩家触发效果
function c2316186.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 只有在自己的准备阶段时才会发动
	return tp==Duel.GetTurnPlayer()
end
-- 设置伤害效果的目标玩家和伤害值
function c2316186.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 设置连锁效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁效果的伤害值为对方场上怪兽数量乘以600
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*600)
end
-- 执行伤害效果
function c2316186.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 再次获取对方场上怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,ct*600,REASON_EFFECT)
end
