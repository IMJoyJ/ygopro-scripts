--竜魔人 キングドラグーン
-- 效果：
-- 「龙之支配者」＋「神龙 末日龙」
-- 只要这张卡在场上表侧表示存在，对方不能指定龙族为魔法·陷阱·怪兽的效果的对象。1回合1次，可以从手卡特殊召唤1只龙族怪兽到自己场上。
function c13756293.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为17985575和62113340的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,17985575,62113340,true,true)
	-- 只要这张卡在场上表侧表示存在，对方不能指定龙族为魔法·陷阱·怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果目标为龙族怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DRAGON))
	-- 设置效果值为不会成为对方的卡的效果对象的过滤函数
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 1回合1次，可以从手卡特殊召唤1只龙族怪兽到自己场上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13756293,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c13756293.sptg)
	e2:SetOperation(c13756293.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在满足条件的龙族怪兽
function c13756293.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动时点处理函数
function c13756293.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的龙族怪兽
		and Duel.IsExistingMatchingCard(c13756293.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只龙族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 设置效果的发动处理函数
function c13756293.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位，如果没有则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的1只龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c13756293.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的龙族怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
