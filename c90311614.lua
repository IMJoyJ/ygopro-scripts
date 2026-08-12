--氷結界の水影
-- 效果：
-- ①：自己场上的表侧表示怪兽只有2星以下的怪兽的场合，这张卡可以直接攻击。
function c90311614.initial_effect(c)
	-- ①：自己场上的表侧表示怪兽只有2星以下的怪兽的场合，这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c90311614.dircon)
	c:RegisterEffect(e1)
end
-- 过滤自己场上不满足“2星以下”条件的表侧表示怪兽（即表侧表示且等级大于2或没有等级的怪兽）
function c90311614.filter(c)
	local lv=c:GetLevel()
	return c:IsFaceup() and (lv==0 or c:GetLevel()>2)
end
-- 检查自己场上是否存在不满足“2星以下”条件的表侧表示怪兽，若不存在则满足直接攻击的条件
function c90311614.dircon(e)
	local tp=e:GetHandler():GetControler()
	-- 检查自己场上是否不存在不满足“2星以下”条件的表侧表示怪兽
	return not Duel.IsExistingMatchingCard(c90311614.filter,tp,LOCATION_MZONE,0,1,nil)
end
