--ノーブル・ド・ノワール
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方怪兽的攻击对象由这张卡的控制者选择。
function c19153634.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方怪兽的攻击对象由这张卡的控制者选择。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	c:RegisterEffect(e1)
end
