--No.64 古狸三太夫
-- 效果：
-- 兽族2星怪兽×2
-- ①：只要自己场上有其他的兽族怪兽存在，这张卡不会被战斗·效果破坏。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。在自己场上把1只「影武者狸衍生物」（兽族·地·1星·攻?/守0）特殊召唤。这衍生物的攻击力变成和场上的怪兽的最高攻击力相同。
function c39972129.initial_effect(c)
	-- 为怪兽添加XYZ召唤手续，使用满足种族为兽族条件的2只2星怪兽进行叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),2,2)
	c:EnableReviveLimit()
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。在自己场上把1只「影武者狸衍生物」（兽族·地·1星·攻?/守0）特殊召唤。这衍生物的攻击力变成和场上的怪兽的最高攻击力相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39972129,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c39972129.spcost)
	e1:SetTarget(c39972129.sptg)
	e1:SetOperation(c39972129.spop)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有其他的兽族怪兽存在，这张卡不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c39972129.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
end
-- 设置该卡的XYZ编号为64
aux.xyz_number[39972129]=64
-- 支付效果的代价，移除自身1个超量素材
function c39972129.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 判断是否可以发动效果，检查场上是否有空位以及是否可以特殊召唤衍生物
function c39972129.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否可以特殊召唤指定编号的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,39972130,0,TYPES_TOKEN_MONSTER,-2,0,1,RACE_BEAST,ATTRIBUTE_EARTH) end
	-- 设置连锁操作信息，表示将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息，表示将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 处理效果的发动，检查场上是否有空位以及是否可以特殊召唤衍生物
function c39972129.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查是否可以特殊召唤指定编号的衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,39972130,0,TYPES_TOKEN_MONSTER,-2,0,1,RACE_BEAST,ATTRIBUTE_EARTH) then return end
	-- 创建编号为39972130的衍生物
	local token=Duel.CreateToken(tp,39972130)
	-- 将创建的衍生物特殊召唤到场上
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		-- 获取场上所有正面表示的怪兽中攻击力最高的怪兽
		local g,atk=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)
		-- 设置衍生物的攻击力为场上怪兽的最高攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 定义过滤函数，用于筛选正面表示且种族为兽族的怪兽
function c39972129.ifilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
-- 判断是否满足效果发动条件，检查自己场上是否存在其他兽族怪兽
function c39972129.indcon(e)
	-- 检查自己场上是否存在其他兽族怪兽
	return Duel.IsExistingMatchingCard(c39972129.ifilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
