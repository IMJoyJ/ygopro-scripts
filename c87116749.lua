--游覧艇サブマリード
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有通常怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：1回合只有1次，自己的通常怪兽不会被和效果怪兽的战斗破坏。
function c87116749.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有通常怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,87116749)
	e1:SetCondition(c87116749.spcon)
	e1:SetTarget(c87116749.sptg)
	e1:SetOperation(c87116749.spop)
	c:RegisterEffect(e1)
	-- ②：1回合只有1次，自己的通常怪兽不会被和效果怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c87116749.indtg)
	e2:SetCountLimit(1)
	e2:SetValue(c87116749.indct)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的通常怪兽
function c87116749.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
-- ①效果的发动条件：自己场上有通常怪兽存在
function c87116749.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的通常怪兽
	return Duel.IsExistingMatchingCard(c87116749.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动准备：检查怪兽区域空位以及自身是否可以特殊召唤
function c87116749.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的效果处理：将自身特殊召唤
function c87116749.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的影响对象过滤：自己场上表侧表示的通常怪兽
function c87116749.indtg(e,c)
	return c:IsType(TYPE_NORMAL) and c:IsFaceup()
end
-- ②效果的破坏替代条件：因与效果怪兽战斗而被破坏
function c87116749.indct(e,re,r,rp)
	local tp=e:GetHandlerPlayer()
	-- 获取当前战斗中双方的怪兽
	local a,d=Duel.GetBattleMonster(tp)
	return bit.band(r,REASON_BATTLE)~=0 and d and d:IsType(TYPE_EFFECT)
end
