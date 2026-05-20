--幻影王 ハイド・ライド
-- 效果：
-- ①：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
function c6901008.initial_effect(c)
	-- ①：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetValue(c6901008.tnval)
	c:RegisterEffect(e1)
end
-- 判断这张卡的控制者与进行同调召唤的玩家是否相同，以实现“把自己场上的这张卡作为同调素材”的条件限制
function c6901008.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
