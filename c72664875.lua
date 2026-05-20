--暗黒方界邪神クリムゾン・ノヴァ・トリニティ
-- 效果：
-- 「暗黑方界神 深红之挪婆」×3
-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
-- ①：场上的这张卡不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：这张卡的攻击宣言时发动。对方基本分变成一半。
-- ③：这张卡的攻击破坏怪兽时才能发动。这次战斗阶段中，这张卡只再1次可以攻击。
-- ④：自己受到效果伤害的场合发动。给与对方为受到的伤害数值的伤害。
function c72664875.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置「暗黑方界神 深红之挪婆」3只作为融合素材
	aux.AddFusionProcCodeRep(c,30270176,3,false,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过融合召唤进行特殊召唤
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ①：场上的这张卡不会成为对方的效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置不会成为对方卡的效果对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被对方卡的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：这张卡的攻击宣言时发动。对方基本分变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetOperation(c72664875.hvop)
	c:RegisterEffect(e3)
	-- ③：这张卡的攻击破坏怪兽时才能发动。这次战斗阶段中，这张卡只再1次可以攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检查此卡是否在战斗中将怪兽破坏
	e4:SetCondition(aux.bdcon)
	e4:SetTarget(c72664875.atktg)
	e4:SetOperation(c72664875.atkop)
	c:RegisterEffect(e4)
	-- ④：自己受到效果伤害的场合发动。给与对方为受到的伤害数值的伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_DAMAGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCondition(c72664875.damcon)
	e5:SetTarget(c72664875.damtg)
	e5:SetOperation(c72664875.damop)
	c:RegisterEffect(e5)
end
-- 攻击宣言时使对方基本分变成一半的效果处理函数
function c72664875.hvop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方玩家的当前基本分向上取整后减半
	Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
end
-- 攻击破坏怪兽时追加攻击效果的发动条件与目标检查函数
function c72664875.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToBattle() and not e:GetHandler():IsHasEffect(EFFECT_EXTRA_ATTACK) end
end
-- 攻击破坏怪兽时追加攻击效果的操作处理函数
function c72664875.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() then return end
	-- 这次战斗阶段中，这张卡只再1次可以攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
end
-- 检查是否为自己受到效果伤害的触发条件
function c72664875.damcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and ep==tp
end
-- 受到效果伤害时给与对方同等伤害效果的目标设置函数
function c72664875.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果伤害的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果伤害的数值为自己受到的伤害值
	Duel.SetTargetParam(ev)
	-- 声明该效果的操作信息为给与对方玩家同等数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
-- 受到效果伤害时给与对方同等伤害效果的操作处理函数
function c72664875.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
