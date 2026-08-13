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
-- 过滤函数：检查怪兽的种族是否为昆虫族或植物族（RACE_INSECT+RACE_PLANT），用于筛选墓地的相关种族怪兽。
function c53416326.filter(c)
	return c:IsRace(RACE_PLANT+RACE_INSECT)
end
-- 特殊召唤规则条件：当c为nil时视为满足发动时机；否则要求这张卡的控制者场上存在可用的主要怪兽区空格，且双方墓地合计存在至少1只昆虫族或植物族怪兽，满足时才能把手卡的这张卡特殊召唤。
function c53416326.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡即将被特殊召唤到的主要怪兽区是否有空位（若没有空位则无法进行这个特殊召唤）。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查双方墓地中是否存在至少1只满足c53416326.filter的昆虫族或植物族怪兽（不取对象，直接检索墓地）。
		and Duel.IsExistingMatchingCard(c53416326.filter,0,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
end
-- EFFECT_NONTUNER的判定函数：当圆唤师的控制者与将要同调召唤的昆虫族/植物族怪兽的控制者相同、且该同调怪兽的种族为昆虫族或植物族时，返回真，使圆唤师可以作为调整以外怪兽进行同调素材。
function c53416326.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler()) and c:IsRace(RACE_PLANT+RACE_INSECT)
end
