--No.64 古狸三太夫
-- 效果：
-- 兽族2星怪兽×2
-- ①：只要自己场上有其他的兽族怪兽存在，这张卡不会被战斗·效果破坏。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。在自己场上把1只「影武者狸衍生物」（兽族·地·1星·攻?/守0）特殊召唤。这衍生物的攻击力变成和场上的怪兽的最高攻击力相同。
function c39972129.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用任意2只兽族2星怪兽作为超量素材进行XYZ召唤。
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
-- 将这张卡的卡号登记为XYZ怪兽编号64（用于处理与编号相关的效果）。
aux.xyz_number[39972129]=64
-- 发动②效果的cost处理：检查能否从这张卡上取除1个超量素材作为代价，可以则实际取除1个超量素材。
function c39972129.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果的发动条件：自己主要怪兽区有可用空格，且自己可以特殊召唤1只「影武者狸衍生物」（兽族·地·1星·攻?/守0）。
function c39972129.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可以特殊召唤衍生物的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己能否将「影武者狸衍生物」（兽族·地·1星·攻?/守0）以表侧表示特殊召唤到主要怪兽区。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,39972130,0,TYPES_TOKEN_MONSTER,-2,0,1,RACE_BEAST,ATTRIBUTE_EARTH) end
	-- 设置本次操作将生成1只衍生物的操作信息，供后续效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本次操作将进行1次特殊召唤的操作信息，供后续效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②效果的解决处理：若自己主要怪兽区没有空格或无法特殊召唤衍生物则处理失败；否则生成衍生物并特殊召唤，再将其攻击力变成场上表侧表示怪兽的最高攻击力。
function c39972129.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空格，则无法继续特殊召唤衍生物。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 若自己不能特殊召唤「影武者狸衍生物」，则无法继续处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,39972130,0,TYPES_TOKEN_MONSTER,-2,0,1,RACE_BEAST,ATTRIBUTE_EARTH) then return end
	-- 在自己场上生成1只「影武者狸衍生物」（兽族·地·1星·攻?/守0）的衍生物。
	local token=Duel.CreateToken(tp,39972130)
	-- 将衍生物以表侧表示特殊召唤到自己场上（作为连锁处理的第一步）。
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		-- 取得场上所有表侧表示怪兽中攻击力最高的攻击力数值。
		local g,atk=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)
		-- 衍生物的攻击力变成和场上的怪兽的最高攻击力相同。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
	end
	-- 完成这组特殊召唤处理（与SpecialSummonStep配套）。
	Duel.SpecialSummonComplete()
end
-- 过滤条件：表侧表示且为兽族怪兽。
function c39972129.ifilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
-- ①效果的耐性条件：自己场上有其他表侧表示的兽族怪兽存在。
function c39972129.indcon(e)
	-- 检查自己场上是否存在其他表侧表示的兽族怪兽（不包括这张卡自身）。
	return Duel.IsExistingMatchingCard(c39972129.ifilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
