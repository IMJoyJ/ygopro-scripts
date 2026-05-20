--ジェネクス・ヒート
-- 效果：
-- ①：自己场上有「次世代控制员」存在的场合，这张卡可以不用解放作召唤。
function c53944920.initial_effect(c)
	-- ①：自己场上有「次世代控制员」存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53944920,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c53944920.ntcon)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「次世代控制员」
function c53944920.ntfilter(c)
	return c:IsFaceup() and c:IsCode(68505803)
end
-- 判断是否满足不用解放进行召唤的条件
function c53944920.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断最少解放怪兽数量为0、自身等级在5星以上且当前控制者的怪兽区域有空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断自己场上是否存在至少1张满足过滤条件的卡（即表侧表示的「次世代控制员」）
		and Duel.IsExistingMatchingCard(c53944920.ntfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
