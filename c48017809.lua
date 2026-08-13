--蜃気楼の筒
-- 效果：
-- 这张卡不能从手卡发动。自己场上表侧表示存在的怪兽被选择作为攻击对象时才能发动。给与对方基本分1000分伤害。
function c48017809.initial_effect(c)
	-- 这张卡不能从手卡发动。自己场上表侧表示存在的怪兽被选择作为攻击对象时才能发动。给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c48017809.condition)
	e1:SetTarget(c48017809.target)
	e1:SetOperation(c48017809.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：这张卡不在手卡（不能从手卡发动），且被选择作为攻击对象的怪兽是自己场上表侧表示存在的怪兽。
function c48017809.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsLocation(LOCATION_HAND)
		and eg:GetFirst():IsControler(tp) and eg:GetFirst():IsFaceup()
end
-- 效果发动时确认可发动，并设定伤害对象为对方玩家、伤害数值为1000，同时登记伤害效果的操作信息。
function c48017809.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的对象玩家设为对方玩家，以指定伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将本次连锁的对象参数设为1000，表示给予的伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：伤害分类，对象为对方玩家，伤害数值为1000（不取对象），便于后续连锁的时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果处理阶段：读取连锁中记录的对象玩家与伤害数值，对对方玩家造成1000点效果伤害。
function c48017809.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家（伤害承受者）和对象参数（伤害数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式，向玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
