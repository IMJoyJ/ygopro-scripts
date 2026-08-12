--パンサー・シャーク
-- 效果：
-- 对方场上的怪兽是2只以上的场合，这张卡可以不用解放作召唤。此外，自己场上有「鹰鲨」存在的场合，这张卡可以从手卡特殊召唤。「豹鲨」在自己场上只能有1只表侧表示存在。
function c70101178.initial_effect(c)
	c:SetUniqueOnField(1,0,70101178)
	-- 对方场上的怪兽是2只以上的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70101178,0))  --"不解放进行召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c70101178.ntcon)
	c:RegisterEffect(e1)
	-- 此外，自己场上有「鹰鲨」存在的场合，这张卡可以从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetCondition(c70101178.spcon)
	c:RegisterEffect(e2)
end
-- 不用解放作召唤的条件函数
function c70101178.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查最小解放怪兽数量为0、自身等级在5星以上且自己场上有可用的怪兽区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上的怪兽数量是否在2只以上
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>1
end
-- 过滤自己场上表侧表示的「鹰鲨」
function c70101178.filter(c)
	return c:IsFaceup() and c:IsCode(7500772)
end
-- 手卡特殊召唤的条件函数
function c70101178.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的「鹰鲨」
		and Duel.IsExistingMatchingCard(c70101178.filter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
