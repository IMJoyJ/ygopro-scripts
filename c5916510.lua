--天翔ける騎士
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从手卡把1只光属性怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己场上1只天使族·光属性·4星怪兽为对象才能发动。这张卡特殊召唤，把作为对象的怪兽在这张卡下面重叠作为超量素材。这个效果在这张卡送去墓地的回合不能发动。
function c5916510.initial_effect(c)
	-- 设置XYZ召唤手续：4星怪兽2只
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。从手卡把1只光属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5916510,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,5916510)
	e1:SetCost(c5916510.spcost)
	e1:SetTarget(c5916510.sptg)
	e1:SetOperation(c5916510.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只天使族·光属性·4星怪兽为对象才能发动。这张卡特殊召唤，把作为对象的怪兽在这张卡下面重叠作为超量素材。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5916510,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,5916511)
	-- 设置发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	e2:SetTarget(c5916510.ovtg)
	e2:SetOperation(c5916510.ovop)
	c:RegisterEffect(e2)
end
-- 效果①的代价过滤与处理：取除这张卡的1个超量素材
function c5916510.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的特殊召唤对象过滤：手卡的光属性怪兽
function c5916510.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查怪兽区域是否有空位，以及手卡是否存在可特殊召唤的光属性怪兽）
function c5916510.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在至少1只满足条件的光属性怪兽
		and Duel.IsExistingMatchingCard(c5916510.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的处理：从手卡选择1只光属性怪兽特殊召唤
function c5916510.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足条件的光属性怪兽
	local g=Duel.SelectMatchingCard(tp,c5916510.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的对象过滤：自己场上表侧表示的天使族·光属性·4星怪兽
function c5916510.ovfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and c:IsLevel(4) and c:IsCanOverlay() and c:IsFaceup()
end
-- 效果②的发动准备（检查怪兽区域空位、场上是否存在符合条件的对象，以及自身是否能特殊召唤，并选择对象）
function c5916510.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c5916510.ovfilter(chkc) end
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在可作为效果对象的天使族·光属性·4星怪兽
		and Duel.IsExistingTarget(c5916510.ovfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择1只符合条件的天使族·光属性·4星怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c5916510.ovfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁处理中的操作信息：将墓地的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的处理：将这张卡特殊召唤，并将作为对象的怪兽重叠作为其超量素材
function c5916510.ovop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查这张卡是否仍与效果相关，并尝试将其表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 将作为对象的怪兽重叠在这张卡下面作为超量素材
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
