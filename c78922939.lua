--ジャンク・サーバント
-- 效果：
-- 自己场上有名字带有「废品」的怪兽表侧表示存在的场合，这张卡可以从手卡特殊召唤。
function c78922939.initial_effect(c)
	-- 自己场上有名字带有「废品」的怪兽表侧表示存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c78922939.spcon)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示且卡名含有「废品」的怪兽
function c78922939.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x43)
end
-- 检查自身特殊召唤的条件是否满足（怪兽区域有空位且自己场上有表侧表示的「废品」怪兽）
function c78922939.spcon(e,c)
	if c==nil then return true end
	-- 检查当前控制者的怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己场上是否存在至少1只表侧表示的「废品」怪兽
		Duel.IsExistingMatchingCard(c78922939.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
