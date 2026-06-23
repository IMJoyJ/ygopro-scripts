--ドラゴンに乗るワイバーン
-- 效果：
-- 「宝贝龙」＋「翼龙战士」
-- ①：对方场上的表侧表示怪兽只有地·水·炎属性怪兽的场合，这张卡可以直接攻击。
function c3366982.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用卡号88819587和64428736的怪兽作为融合素材
	aux.AddFusionProcCode2(c,88819587,64428736,true,true)
	-- ①：对方场上的表侧表示怪兽只有地·水·炎属性怪兽的场合，这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c3366982.dircon)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断对方场上是否存在表侧表示的非地·水·炎属性怪兽
function c3366982.filter(c)
	return c:IsFaceup() and c:IsAttribute(0xf8)
end
-- 条件函数，判断是否满足直接攻击的条件
function c3366982.dircon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查对方场上是否存在至少1张表侧表示的怪兽
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		-- 检查对方场上是否不存在满足filter条件的怪兽，即只有地·水·炎属性怪兽
		and not Duel.IsExistingMatchingCard(c3366982.filter,tp,0,LOCATION_MZONE,1,nil)
end
