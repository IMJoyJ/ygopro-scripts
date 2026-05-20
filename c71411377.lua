--女王親衛隊
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，自己场上存在的名字带有「魅惑的女王」的怪兽不能被选择作为攻击对象。
function c71411377.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，自己场上存在的名字带有「魅惑的女王」的怪兽不能被选择作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetTarget(c71411377.atlimit)
	-- 设置不能被选择作为攻击对象效果的Value，使用系统内置的过滤函数以排除不受效果影响的怪兽
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
end
-- 定义目标过滤函数，判断怪兽是否属于「魅惑的女王」系列（字段为0x3）
function c71411377.atlimit(e,c)
	return c:IsSetCard(0x3)
end
