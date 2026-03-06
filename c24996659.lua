--エレキーウィ
-- 效果：
-- 只要这张卡在场上表侧表示存在，自己场上存在的名字带有「电气」的怪兽攻击的场合，攻击怪兽不会被战斗破坏。
function c24996659.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，自己场上存在的名字带有「电气」的怪兽攻击的场合，攻击怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c24996659.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
-- 判断目标怪兽是否为名字带有「电气」的怪兽且是否为此次战斗的攻击怪兽
function c24996659.indtg(e,c)
	-- 返回判断结果：目标怪兽是否同时满足是「电气」卡且是攻击怪兽
	return c:IsSetCard(0xe) and c==Duel.GetAttacker()
end
