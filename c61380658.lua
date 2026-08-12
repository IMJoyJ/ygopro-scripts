--エレキリギリス
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方不能选择表侧表示存在的其他的名字带有「电气」的怪兽作为攻击对象，也不能作为卡的效果的对象。
function c61380658.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方不能选择表侧表示存在的其他的名字带有「电气」的怪兽作为攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c61380658.atlimit)
	c:RegisterEffect(e1)
	-- 也不能作为卡的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c61380658.tglimit)
	-- 设置不能成为效果对象的效果仅在受到对方卡的效果影响时生效
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- 过滤出场上表侧表示的、除自身以外的名字带有「电气」的怪兽，作为不能被选择为攻击对象的目标
function c61380658.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0xe) and c~=e:GetHandler()
end
-- 过滤出除自身以外的名字带有「电气」的怪兽，作为不能成为效果对象的目标
function c61380658.tglimit(e,c)
	return c:IsSetCard(0xe) and c~=e:GetHandler()
end
