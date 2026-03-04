--オルターガイスト・フィフィネラグ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，对方不能选择「幻变骚灵·延迟菲芬尼拉」以外的自己场上的「幻变骚灵」怪兽作为攻击对象，也不能作为效果的对象。
function c12977245.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，对方不能选择「幻变骚灵·延迟菲芬尼拉」以外的自己场上的「幻变骚灵」怪兽作为攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c12977245.atlimit)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方不能选择「幻变骚灵·延迟菲芬尼拉」以外的自己场上的「幻变骚灵」怪兽作为效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c12977245.tglimit)
	-- 设置效果值为过滤函数aux.tgoval，用于判断是否能成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- 攻击对象限制条件函数，用于判断目标怪兽是否满足不能被选择为攻击对象的条件
function c12977245.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x103) and not c:IsCode(12977245)
end
-- 效果对象限制条件函数，用于判断目标怪兽是否满足不能成为效果对象的条件
function c12977245.tglimit(e,c)
	return c:IsSetCard(0x103) and not c:IsCode(12977245)
end
