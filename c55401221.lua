--電池メン－単一型
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，对方不能选择自己场上存在的「电池人-单一型」以外的雷族怪兽作为攻击对象。
function c55401221.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，对方不能选择自己场上存在的「电池人-单一型」以外的雷族怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c55401221.atlimit)
	c:RegisterEffect(e1)
end
-- 判断目标怪兽是否为表侧表示、雷族且卡名不为「电池人-单一型」，作为不能被选择为攻击对象的限制条件
function c55401221.atlimit(e,c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER) and not c:IsCode(55401221)
end
