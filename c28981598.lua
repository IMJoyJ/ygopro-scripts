--九魂猫
-- 效果：
-- 9星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，从墓地特殊召唤的自己场上的其他怪兽不会成为对方的效果的对象。
-- ②：把这张卡1个超量素材取除，以自己墓地1只9星怪兽或者对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
function c28981598.initial_effect(c)
	-- 为九魂猫添加超量召唤手续：需要2只9星怪兽叠放（对应效果原文‘9星怪兽×2’）。
	aux.AddXyzProcedure(c,nil,9,2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，从墓地特殊召唤的自己场上的其他怪兽不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c28981598.tgtg)
	-- 设置效果值为aux.tgoval，使该‘不能成为对方的效果的对象’的判定生效（对方效果不能选择这些怪兽为对象）。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把这张卡1个超量素材取除，以自己墓地1只9星怪兽或者对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28981598,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,28981598)
	e2:SetCost(c28981598.spcost)
	e2:SetTarget(c28981598.sptg)
	e2:SetOperation(c28981598.spop)
	c:RegisterEffect(e2)
end
-- 判定对象怪兽必须是从墓地特殊召唤的怪兽，且不能是九魂猫自身（即‘从墓地特殊召唤的自己场上的其他怪兽’）。
function c28981598.tgtg(e,c)
	return c:IsSummonLocation(LOCATION_GRAVE) and c~=e:GetHandler()
end
-- ②的代价处理：检查这张卡是否有1个超量素材可移除；在发动时通过检查后，实际移除1个超量素材作为代价。
function c28981598.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 选择对象的过滤条件：被选中怪兽必须是自己墓地1只9星怪兽，或者是对方墓地1只任意怪兽，且该怪兽能够被特殊召唤。
function c28981598.spfilter(c,e,tp)
	return (c:IsLevel(9) or c:IsControler(1-tp)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动条件判定：如果连锁处理中检查对象，则验证对象是否在墓地且满足spfilter；否则检查自己主要怪兽区是否有空位，以及双方墓地是否存在满足条件的对象。
function c28981598.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c28981598.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的主要怪兽区，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地是否存在至少1只满足spfilter条件的对象（自己墓地9星怪兽或对方墓地怪兽）。
		and Duel.IsExistingTarget(c28981598.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家显示‘请选择要特殊召唤的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从双方墓地选择1只满足spfilter条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c28981598.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息：本连锁将进行特殊召唤，对象为选中的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得连锁对象，若对象仍与该效果关联，则将其特殊召唤。
function c28981598.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这个效果发动时选择的对方或自己墓地的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到发动玩家的场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
