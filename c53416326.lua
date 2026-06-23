--円喚師フェアリ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己或者对方的墓地有昆虫族·植物族怪兽的其中任意种存在的场合，这张卡可以从手卡特殊召唤。
-- ②：把自己场上的这张卡作为昆虫族·植物族同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
function c53416326.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己或者对方的墓地有昆虫族·植物族怪兽的其中任意种存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,53416326+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c53416326.spcon)
	c:RegisterEffect(e1)
	-- ②：把自己场上的这张卡作为昆虫族·植物族同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_NONTUNER)
	e2:SetValue(c53416326.tnval)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查怪兽是否为昆虫族或植物族
function c53416326.filter(c)
	return c:IsRace(RACE_PLANT+RACE_INSECT)
end
-- 特殊召唤条件，检查墓地是否有昆虫族或植物族怪兽存在且场上有可用区域
function c53416326.spcon(e,c)
	if c==nil then return true end
	-- 检查当前控制者的主要怪兽区是否有可用区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查双方墓地是否存在至少一张昆虫族或植物族怪兽
		and Duel.IsExistingMatchingCard(c53416326.filter,0,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
end
-- 检查作为同调素材的怪兽是否由自己控制且为昆虫族或植物族
function c53416326.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler()) and c:IsRace(RACE_PLANT+RACE_INSECT)
end
