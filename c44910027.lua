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
	-- 只能用自己场上3只龙族怪兽作为祭品进行祭品召唤出场。（此效果同样适用于里侧守备表示放置的祭品召唤）
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c44910027.ttcon)
	e2:SetOperation(c44910027.ttop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	-- 只能用自己场上3只龙族怪兽作为祭品
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
-- 此函数用作召唤规则限制的条件判定：若c为nil（系统询问能否召唤）则直接允许；否则检查此次召唤的祭品要求不超过3张且场上存在至少3只可作祭品的怪兽，以确保必须用3只祭品进行上级召唤。
function c44910027.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查系统所需祭品数是否不超过3，并且场上存在至少3只满足解放条件的祭品怪兽，从而强制此次召唤必须解放3只怪兽。
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 此函数为召唤规则限制的执行操作：先让玩家选择3只祭品，将所选祭品设为这张卡的召唤素材，然后将它们解放，完成以3只怪兽作为祭品的祭品召唤。
function c44910027.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让当前玩家从自己场上选择3只怪兽作为这张卡的祭品（因祭品限制效果，实际只能选择龙族怪兽）。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将所选的3只祭品怪兽以“上级召唤素材”的理由解放，使其成为召唤这张卡而支付的祭品。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 此函数返回true表示该怪兽不能作为这张卡的祭品；即非龙族怪兽被排除在祭品之外，确保只能用龙族怪兽作为祭品。
function c44910027.tlimit(e,c)
	return not c:IsRace(RACE_DRAGON)
end
