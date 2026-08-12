--ヴィクトリー・ドラゴン
-- 效果：
-- 这张卡不能特殊召唤。只能用自己场上3只龙族怪兽作为祭品进行祭品召唤出场。这张卡直接攻击对方造成对方基本分为0的时候，这张卡的主人得到比赛的胜利。
function c44910027.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 只能用自己场上3只龙族怪兽作为祭品进行祭品召唤出场。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c44910027.ttcon)
	e1:SetOperation(c44910027.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 只能用自己场上3只龙族怪兽作为祭品进行祭品召唤出场。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c44910027.ttcon)
	e2:SetOperation(c44910027.ttop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	-- 只能用自己场上3只龙族怪兽作为祭品进行祭品召唤出场。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRIBUTE_LIMIT)
	e3:SetValue(c44910027.tlimit)
	c:RegisterEffect(e3)
	-- 这张卡直接攻击对方造成对方基本分为0的时候，这张卡的主人得到比赛的胜利。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_MATCH_KILL)
	c:RegisterEffect(e4)
end
-- 判断召唤所需的祭品数量是否满足条件并检查场上是否存在符合条件的祭品。
function c44910027.ttcon(e,c,minc)
	if c==nil then return true end
	-- 判断召唤所需的祭品数量是否满足条件并检查场上是否存在符合条件的祭品。
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 选择3个祭品并将其解放以完成召唤。
function c44910027.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择3个祭品。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选中的祭品以召唤和素材的名义进行解放。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 限制非龙族怪兽作为祭品。
function c44910027.tlimit(e,c)
	return not c:IsRace(RACE_DRAGON)
end
