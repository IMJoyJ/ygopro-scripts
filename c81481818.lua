--パッチワーク・ファーニマル
-- 效果：
-- ①：这张卡只要在怪兽区域存在，也当作「魔玩具」怪兽使用。
-- ②：这张卡只要在怪兽区域存在，可以作为「魔玩具」融合怪兽卡有卡名记述的1只融合素材怪兽的代替。那个时候，其他的融合素材怪兽必须是正规品。
function c81481818.initial_effect(c)
	-- ①：这张卡只要在怪兽区域存在，也当作「魔玩具」怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(0xad)
	c:RegisterEffect(e1)
	-- ②：这张卡只要在怪兽区域存在，可以作为「魔玩具」融合怪兽卡有卡名记述的1只融合素材怪兽的代替。那个时候，其他的融合素材怪兽必须是正规品。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c81481818.subval)
	c:RegisterEffect(e2)
end
-- 判定融合怪兽是否属于「魔玩具」系列，限制该卡仅能作为「魔玩具」融合怪兽的代替素材
function c81481818.subval(e,c)
	return c:IsSetCard(0xad)
end
