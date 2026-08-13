--闇の侯爵ベリアル
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方不能选择「暗之侯爵 彼列」以外的自己场上表侧表示存在的怪兽作为攻击对象，也不能作为魔法·陷阱卡的效果的对象。
function c33655493.initial_effect(c)
	-- 对方不能选择「暗之侯爵 彼列」以外的自己场上表侧表示存在的怪兽作为攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(c33655493.tg)
	c:RegisterEffect(e1)
	-- 对方也不能选择「暗之侯爵 彼列」以外的自己场上表侧表示存在的怪兽作为魔法·陷阱卡的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c33655493.tg)
	e2:SetValue(c33655493.tgval)
	c:RegisterEffect(e2)
end
-- 判定被选择的怪兽是否为表侧表示且不是「暗之侯爵 彼列」自身，即满足“以外的表侧表示怪兽”这一条件
function c33655493.tg(e,c)
	return c:IsFaceup() and not c:IsCode(33655493)
end
-- 判定试图以该卡为对象的效果是否来自对方发动的魔法·陷阱卡，若是则该卡不能被选为效果对象
function c33655493.tgval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and rp==1-e:GetHandlerPlayer()
end
