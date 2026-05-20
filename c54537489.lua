--タツノオトシオヤ
-- 效果：
-- 这张卡不用幻龙族怪兽的效果不能特殊召唤。这个卡名的效果1回合可以使用最多3次。
-- ①：自己主要阶段才能发动。这张卡的等级下降1星，在自己场上把1只「龙子衍生物」（幻龙族·水·1星·攻300/守200）特殊召唤。
function c54537489.initial_effect(c)
	-- 这张卡不用幻龙族怪兽的效果不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c54537489.splimit)
	c:RegisterEffect(e1)
	-- 这个卡名的效果1回合可以使用最多3次。①：自己主要阶段才能发动。这张卡的等级下降1星，在自己场上把1只「龙子衍生物」（幻龙族·水·1星·攻300/守200）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54537489,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(3,54537489)
	e2:SetTarget(c54537489.sptg)
	e2:SetOperation(c54537489.spop)
	c:RegisterEffect(e2)
end
-- 限制特殊召唤此卡的怪兽效果必须是幻龙族怪兽的效果
function c54537489.splimit(e,se,sp,st)
	return se:IsActiveType(TYPE_MONSTER) and se:GetHandler():IsRace(RACE_WYRM)
end
-- 效果发动的可行性检查：自身等级在2星以上、自己场上有空余怪兽区域，且可以特殊召唤衍生物
function c54537489.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLevelAbove(2)
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,54537490,0,TYPES_TOKEN_MONSTER,300,200,1,RACE_WYRM,ATTRIBUTE_WATER) end
	-- 设置连锁处理信息，表示该效果包含产生衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁处理信息，表示该效果包含特殊召唤操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：使自身等级下降1星，并在自己场上特殊召唤1只「龙子衍生物」
function c54537489.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or c:IsLevel(1) then return end
	-- 这张卡的等级下降1星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(-1)
	c:RegisterEffect(e1)
	-- 检查自己场上是否有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,54537490,0,TYPES_TOKEN_MONSTER,300,200,1,RACE_WYRM,ATTRIBUTE_WATER) then
		-- 创建「龙子衍生物」的卡片数据
		local token=Duel.CreateToken(tp,54537490)
		-- 将创建的衍生物以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
