--ジェスター・ロード
-- 效果：
-- 场上没有这张卡以外的怪兽存在的场合，双方的魔法与陷阱卡区域存在的卡每有1张，这张卡的攻击力上升1000。
function c72992744.initial_effect(c)
	-- 场上没有这张卡以外的怪兽存在的场合，双方的魔法与陷阱卡区域存在的卡每有1张，这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c72992744.atkcon)
	e1:SetValue(c72992744.atkval)
	c:RegisterEffect(e1)
end
-- 定义攻击力上升效果的生效条件函数
function c72992744.atkcon(e)
	-- 判断双方场上是否存在除自身以外的怪兽，若不存在则满足效果生效条件
	return not Duel.IsExistingMatchingCard(nil,0,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
-- 过滤函数：筛选出位于魔法与陷阱区域（序号小于5，即不含场地魔法格）的卡片
function c72992744.filter(c)
	return c:GetSequence()<5
end
-- 定义攻击力上升数值的计算函数
function c72992744.atkval(e,c)
	-- 获取双方魔法与陷阱区域存在的卡片数量，并乘以1000作为攻击力上升的数值
	return Duel.GetMatchingGroupCount(c72992744.filter,0,LOCATION_SZONE,LOCATION_SZONE,nil)*1000
end
