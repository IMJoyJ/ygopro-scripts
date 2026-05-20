--地獄の番熊
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，自己场上的「万魔殿-恶魔的巢窟-」不会被对方所控制的卡的效果所破坏。
function c75375465.initial_effect(c)
	-- 在卡片中注册其记载了卡名「万魔殿-恶魔的巢窟-」
	aux.AddCodeList(c,94585852)
	-- 只要这张卡在自己场上表侧表示存在，自己场上的「万魔殿-恶魔的巢窟-」不会被对方所控制的卡的效果所破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(c75375465.indtg)
	e1:SetValue(c75375465.indval)
	c:RegisterEffect(e1)
end
-- 过滤出自己场上表侧表示存在且卡名为「万魔殿-恶魔的巢窟-」的卡片作为效果适用对象
function c75375465.indtg(e,c)
	return c:IsFaceup() and c:IsCode(94585852)
end
-- 设定破坏效果的来源为对方（非自身控制者）所控制的卡
function c75375465.indval(e,re,tp)
	return e:GetHandler():GetControler()~=tp
end
