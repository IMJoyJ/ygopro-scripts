--暗黒の侵略者
-- 效果：
-- 只要这张卡在自己场上以表侧表示存在，对方不能发动速攻魔法卡。
function c56647086.initial_effect(c)
	-- 只要这张卡在自己场上以表侧表示存在，对方不能发动速攻魔法卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c56647086.aclimit)
	c:RegisterEffect(e1)
end
-- 判断被发动的效果是否为速攻魔法卡的发动
function c56647086.aclimit(e,re,tp)
	return re:GetHandler():GetType()==TYPE_SPELL+TYPE_QUICKPLAY and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
