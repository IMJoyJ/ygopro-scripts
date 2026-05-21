--フュージョニストキラー
-- 效果：
-- 和这张卡进行战斗的融合怪兽的攻击力在伤害步骤内变成0。
function c98336111.initial_effect(c)
	-- 和这张卡进行战斗的融合怪兽的攻击力在伤害步骤内变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetCondition(c98336111.condtion)
	e1:SetTarget(c98336111.target)
	e1:SetValue(0)
	c:RegisterEffect(e1)
end
-- 定义效果生效的条件函数，判断是否在伤害步骤内且此卡参与了战斗
function c98336111.condtion(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否处于伤害步骤或伤害计算时，且场上存在攻击对象（即发生了战斗）
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and Duel.GetAttackTarget()~=nil
		-- 判断攻击怪兽或被攻击怪兽是否为这张卡自身（即此卡参与了战斗）
		and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler())
end
-- 定义效果影响的目标过滤函数，筛选出与此卡进行战斗的融合怪兽
function c98336111.target(e,c)
	return c==e:GetHandler():GetBattleTarget() and c:IsType(TYPE_FUSION)
end
