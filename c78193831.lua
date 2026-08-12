--バスター・ブレイダー
-- 效果：
-- ①：这张卡的攻击力上升对方的场上·墓地的龙族怪兽数量×500。
function c78193831.initial_effect(c)
	-- ①：这张卡的攻击力上升对方的场上·墓地的龙族怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c78193831.val)
	c:RegisterEffect(e1)
end
-- 计算攻击力上升数值的函数，返回对方场上和墓地的龙族怪兽数量乘以500的值
function c78193831.val(e,c)
	-- 获取对方场上及墓地中符合过滤条件的卡片数量，并乘以500作为攻击力上升值
	return Duel.GetMatchingGroupCount(c78193831.filter,c:GetControler(),0,LOCATION_GRAVE+LOCATION_MZONE,nil)*500
end
-- 过滤条件：属于龙族且在墓地中或是场上表侧表示的怪兽
function c78193831.filter(c)
	return c:IsRace(RACE_DRAGON) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
