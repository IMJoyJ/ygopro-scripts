--紋章獣エアレー
-- 效果：
-- 自己场上有名字带有「纹章兽」的怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
function c82315772.initial_effect(c)
	-- 自己场上有名字带有「纹章兽」的怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c82315772.spcon)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「纹章兽」怪兽
function c82315772.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x76)
end
-- 判断自身特殊召唤的条件是否满足：怪兽区域有空位且自己场上有2只以上的「纹章兽」怪兽
function c82315772.spcon(e,c)
	if c==nil then return true end
	-- 检查当前控制者的怪兽区域是否有可用的空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己场上是否存在至少2只表侧表示的「纹章兽」怪兽
		Duel.IsExistingMatchingCard(c82315772.filter,c:GetControler(),LOCATION_MZONE,0,2,nil)
end
