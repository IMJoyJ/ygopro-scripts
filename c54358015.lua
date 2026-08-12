--銀河影竜
-- 效果：
-- 龙族4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从手卡把1只龙族怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己场上的「银河」卡不会成为对方的效果的对象，不会被对方的效果破坏。
function c54358015.initial_effect(c)
	-- 设置超量召唤手续：龙族4星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从手卡把1只龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54358015,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c54358015.spcost)
	e1:SetTarget(c54358015.sptg)
	e1:SetOperation(c54358015.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，这张卡以外的自己场上的「银河」卡不会成为对方的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c54358015.tgtg)
	-- 设置不会成为对方卡的效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(c54358015.tgtg)
	-- 设置不会被对方卡的效果破坏
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
end
-- 效果①的代价：取除这张卡的1个超量素材
function c54358015.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤手卡中可以特殊召唤的龙族怪兽
function c54358015.spfilter(c,e,tp)
	-- 检查卡片是否为龙族，且是否能被特殊召唤（包含超量怪兽特殊召唤判定）
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DragonXyzSpSummonType(c))
end
-- 效果①的发动准备（检查怪兽区域空位及手卡中是否存在可特召的龙族怪兽，并设置特殊召唤的操作信息）
function c54358015.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足特召条件的龙族怪兽
		and Duel.IsExistingMatchingCard(c54358015.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理：从手卡选择1只龙族怪兽特殊召唤
function c54358015.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c54358015.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		-- 将选中的怪兽以表侧表示特殊召唤，若该怪兽是特定超量怪兽且特召成功，则执行后续正规出场程序
		if Duel.SpecialSummon(g,0,tp,tp,false,aux.DragonXyzSpSummonType(sc),POS_FACEUP)~=0 and aux.DragonXyzSpSummonType(sc) then
			sc:CompleteProcedure()
		end
	end
end
-- 过滤除这张卡以外的自己场上的「银河」卡
function c54358015.tgtg(e,c)
	return c:IsSetCard(0x7b) and c~=e:GetHandler()
end
