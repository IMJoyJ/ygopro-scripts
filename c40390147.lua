--輝光帝ギャラクシオン
-- 效果：
-- 名字带有「光子」的4星怪兽×2
-- 1回合1次，把这张卡最多2个超量素材取除才能发动。为这个效果发动而取除的超量素材数量的以下效果适用。
-- ●1个：从手卡把1只「银河眼光子龙」特殊召唤。
-- ●2个：从卡组把1只「银河眼光子龙」特殊召唤。
function c40390147.initial_effect(c)
	-- 添加XYZ召唤手续，使用名字带有「光子」的4星怪兽作为素材进行叠放，最少需要2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x55),4,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡最多2个超量素材取除才能发动。为这个效果发动而取除的超量素材数量的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40390147,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c40390147.sptg)
	e1:SetOperation(c40390147.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断目标卡是否为「银河眼光子龙」且可以被特殊召唤
function c40390147.spfilter(c,e,tp)
	return c:IsCode(93717133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否满足发动条件，即手卡或卡组存在「银河眼光子龙」且自身可以移除对应数量的超量素材
function c40390147.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在「银河眼光子龙」且自身可以移除1个超量素材
	local b1=Duel.IsExistingMatchingCard(c40390147.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
	-- 检查卡组是否存在「银河眼光子龙」且自身可以移除2个超量素材
	local b2=Duel.IsExistingMatchingCard(c40390147.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST)
	-- 判断是否满足基本发动条件，即场上存在空位且满足上述任一条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (b1 or b2) end
	local opt=0
	if b1 and b2 then
		-- 选择效果发动时的选项，从手卡或卡组特殊召唤「银河眼光子龙」
		opt=Duel.SelectOption(tp,aux.Stringid(40390147,1),aux.Stringid(40390147,2))  --"从手卡把1只「银河眼光子龙」特殊召唤/从卡组把1只「银河眼光子龙」特殊召唤"
	elseif b1 then
		-- 选择从手卡特殊召唤「银河眼光子龙」
		opt=Duel.SelectOption(tp,aux.Stringid(40390147,1))  --"从手卡把1只「银河眼光子龙」特殊召唤"
	else
		-- 选择从卡组特殊召唤「银河眼光子龙」
		opt=Duel.SelectOption(tp,aux.Stringid(40390147,2))+1  --"从卡组把1只「银河眼光子龙」特殊召唤"
	end
	e:SetLabel(opt)
	e:GetHandler():RemoveOverlayCard(tp,opt+1,opt+1,REASON_COST)
	if opt==0 then
		-- 设置连锁操作信息，表示将从手卡特殊召唤1只「银河眼光子龙」
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	else
		-- 设置连锁操作信息，表示将从卡组特殊召唤1只「银河眼光子龙」
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
-- 处理效果发动后的操作，根据选择的选项从手卡或卡组特殊召唤「银河眼光子龙」
function c40390147.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位，若无则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=nil
	if e:GetLabel()==0 then
		-- 从手卡检索第一张满足条件的「银河眼光子龙」
		tc=Duel.GetFirstMatchingCard(c40390147.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	else
		-- 从卡组检索第一张满足条件的「银河眼光子龙」
		tc=Duel.GetFirstMatchingCard(c40390147.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	end
	if tc then
		-- 将目标卡以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
