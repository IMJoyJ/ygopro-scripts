--ドラゴンに乗るワイバーン
-- 效果：
-- 「宝贝龙」＋「翼龙战士」
-- ①：对方场上的表侧表示怪兽只有地·水·炎属性怪兽的场合，这张卡可以直接攻击。
function c3366982.initial_effect(c)
	c:EnableReviveLimit()
	-- 为『乘龙的翼龙战士』添加融合召唤手续：以卡号88819587的『宝贝龙』和卡号64428736的『翼龙战士』作为融合素材（sub和insf均设为true，即允许融合素材代用品等对应设定）。
	aux.AddFusionProcCode2(c,88819587,64428736,true,true)
	-- ①：对方场上的表侧表示怪兽只有地·水·炎属性怪兽的场合，这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c3366982.dircon)
	c:RegisterEffect(e2)
end
-- 该过滤函数判断怪兽是否为“表侧表示且属性不是地·水·炎”（属性掩码0xf8为地水火炎以外的属性，如风、光、暗等），用于检查对方场上是否存在不符合‘只有地·水·炎属性’条件的表侧怪兽。
function c3366982.filter(c)
	return c:IsFaceup() and c:IsAttribute(0xf8)
end
-- 直接攻击效果的发动条件：对方场上有表侧表示怪兽，且对方场上不存在任何非地·水·炎属性的表侧表示怪兽，即所有表侧表示怪兽都仅属于地·水·炎属性。
function c3366982.dircon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查对方场上是否存在至少1张表侧表示怪兽（以效果控制者的视角检查对方怪兽区）。
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		-- 且不存在满足c3366982.filter的怪兽，也就是不存在表侧表示且属性为地·水·炎以外的怪兽，从而确保对方场上的表侧表示怪兽全部为地·水·炎属性。
		and not Duel.IsExistingMatchingCard(c3366982.filter,tp,0,LOCATION_MZONE,1,nil)
end
