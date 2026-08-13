--ジェムナイト・パーズ
-- 效果：
-- 「宝石骑士·黄碧」＋「宝石骑士」怪兽
-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ②：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c49597193.initial_effect(c)
	c:EnableReviveLimit()
	-- 为此卡添加融合召唤手续：融合素材为卡号54620698的“宝石骑士·黄碧”1只和1只满足“宝石骑士”字段（0x1047）的怪兽，且不能使用融合素材代用品。
	aux.AddFusionProcCodeFun(c,54620698,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),1,false,false)
	-- 效果外文本：这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c49597193.splimit)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49597193,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c49597193.damcon)
	e3:SetTarget(c49597193.damtg)
	e3:SetOperation(c49597193.damop)
	c:RegisterEffect(e3)
	-- ①：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 特殊召唤条件限制函数：若此卡在额外卡组，则只允许通过融合召唤方式特殊召唤；若已不在额外卡组则不受此限制。
function c49597193.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 伤害诱发效果的发动条件：此卡与本次战斗关联，且其战斗对象（被战斗破坏的怪兽）在墓地并且是怪兽。
function c49597193.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 效果发动时的目标处理：锁定伤害对象为对方玩家，伤害数值为被战斗破坏怪兽的当前攻击力（若小于0则按0计算），并登记操作信息。
function c49597193.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	-- 将当前连锁的对象玩家设置为对方玩家（作为伤害的承受者）。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为伤害数值dam。
	Duel.SetTargetParam(dam)
	-- 登记当前连锁的操作信息：效果分类为伤害，目标玩家为对方，伤害数值为dam（不指定卡片对象）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理时：从连锁信息中取得对象玩家和伤害数值，对对方玩家造成效果伤害。
function c49597193.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取设置的对象玩家和对象参数（伤害数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对玩家p造成d点效果伤害，伤害原因为效果。
	Duel.Damage(p,d,REASON_EFFECT)
end
