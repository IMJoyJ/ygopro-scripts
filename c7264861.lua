--インフェルニティ・ビースト
-- 效果：
-- 自己手卡是0张的场合，得到以下效果。这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
function c7264861.initial_effect(c)
	-- 自己手卡是0张的场合，得到以下效果。这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c7264861.aclimit)
	e1:SetCondition(c7264861.condition)
	c:RegisterEffect(e1)
end
-- 设置效果生效的条件函数，即自己手卡为0且这张卡进行攻击
function c7264861.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己手卡数量是否为0，且当前进行攻击的怪兽是否为这张卡自身
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 and Duel.GetAttacker()==e:GetHandler()
end
-- 定义限制发动的类型，即限制魔法·陷阱卡卡片本身的发动
function c7264861.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
