--イーグル・シャーク
-- 效果：
-- 对方场上的怪兽是2只以上的场合，这张卡可以不用解放作召唤。此外，自己场上有「豹鲨」存在的场合，这张卡可以从手卡特殊召唤。「鹰鲨」在自己场上只能有1只表侧表示存在。
function c7500772.initial_effect(c)
	c:SetUniqueOnField(1,0,7500772)
	-- 对方场上的怪兽是2只以上的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7500772,0))  --"不解放进行召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c7500772.ntcon)
	c:RegisterEffect(e1)
	-- 此外，自己场上有「豹鲨」存在的场合，这张卡可以从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetCondition(c7500772.spcon)
	c:RegisterEffect(e2)
end
-- 判定是否满足不用解放作召唤的条件
function c7500772.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定不需要解放、自身等级在5星以上且自己场上有可用的怪兽区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判定对方场上的怪兽数量在2只以上
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>1
end
-- 过滤自己场上表侧表示的「豹鲨」
function c7500772.filter(c)
	return c:IsFaceup() and c:IsCode(70101178)
end
-- 判定是否满足从手卡特殊召唤的条件
function c7500772.spcon(e,c)
	if c==nil then return true end
	-- 判定自己场上有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判定自己场上是否存在表侧表示的「豹鲨」
		and Duel.IsExistingMatchingCard(c7500772.filter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
