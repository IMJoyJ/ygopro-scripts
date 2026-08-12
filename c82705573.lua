--バックファイア
-- 效果：
-- ①：每次自己场上的表侧表示的炎属性怪兽被破坏送去墓地发动。给与对方500伤害。
function c82705573.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次自己场上的表侧表示的炎属性怪兽被破坏送去墓地发动。给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82705573,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c82705573.condition)
	e2:SetTarget(c82705573.target)
	e2:SetOperation(c82705573.operation)
	c:RegisterEffect(e2)
end
-- 过滤出原本在自己场上表侧表示存在、因破坏而送去自己墓地的炎属性怪兽。
function c82705573.filter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsControler(tp) and c:IsReason(REASON_DESTROY) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 检查送去墓地的卡片中是否存在满足条件的怪兽，作为效果发动的条件。
function c82705573.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c82705573.filter,1,nil,tp)
end
-- 效果发动时的目标处理，设置伤害对象为对方玩家，伤害数值为500，并向系统申报伤害操作信息。
function c82705573.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为500。
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息，表示该效果会给与对方玩家500点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理时，获取设定的目标玩家和伤害数值，并给与对方玩家对应的效果伤害。
function c82705573.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和对象参数（伤害数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
