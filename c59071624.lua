--アロメルスの蟲惑魔
-- 效果：
-- 4星怪兽×2只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：持有超量素材的这张卡不受陷阱卡的效果影响。
-- ②：把这张卡2个超量素材取除才能发动。从自己墓地选1只昆虫族·植物族的4星怪兽特殊召唤。
-- ③：自己的卡的效果让对方怪兽从场上离开，被送去墓地的场合或者被除外的场合，把这张卡1个超量素材取除，以那之内的1只为对象才能发动。那只怪兽在自己场上特殊召唤。
function c59071624.initial_effect(c)
	-- 设置超量召唤手续：4星怪兽2只以上。
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：持有超量素材的这张卡不受陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(c59071624.imcon)
	e1:SetValue(c59071624.efilter)
	c:RegisterEffect(e1)
	-- ②：把这张卡2个超量素材取除才能发动。从自己墓地选1只昆虫族·植物族的4星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59071624,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,59071624)
	e2:SetCost(c59071624.spcost1)
	e2:SetTarget(c59071624.sptg1)
	e2:SetOperation(c59071624.spop1)
	c:RegisterEffect(e2)
	-- 注册一个合并的延迟事件监听器，用于监听卡片被送去墓地或被除外的事件。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,59071624,{EVENT_TO_GRAVE,EVENT_REMOVE})
	-- ③：自己的卡的效果让对方怪兽从场上离开，被送去墓地的场合或者被除外的场合，把这张卡1个超量素材取除，以那之内的1只为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(59071624,1))  --"特殊召唤对方怪兽"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(custom_code)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,59071625)
	e3:SetCondition(c59071624.spcon2)
	e3:SetCost(c59071624.spcost2)
	e3:SetTarget(c59071624.sptg2)
	e3:SetOperation(c59071624.spop2)
	c:RegisterEffect(e3)
end
-- 免疫效果的判定条件：自身持有超量素材。
function c59071624.imcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 免疫效果的过滤函数：不受陷阱卡的效果影响。
function c59071624.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
-- 效果②的发动代价：取除这张卡的2个超量素材。
function c59071624.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果②的特殊召唤目标过滤：墓地中等级4的昆虫族或植物族怪兽。
function c59071624.spfilter1(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_INSECT+RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检测。
function c59071624.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的昆虫族或植物族怪兽。
		and Duel.IsExistingMatchingCard(c59071624.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理：从自己墓地选择1只满足条件的怪兽特殊召唤。
function c59071624.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无空余的怪兽区域则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只满足条件且不受王家之谷影响的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c59071624.spfilter1),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的触发卡片过滤：原本由对方控制的怪兽，因自己的卡的效果从场上离开并被送去墓地或除外。
function c59071624.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE)
		and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==tp and c:IsPreviousControler(1-tp)
end
-- 效果③的发动条件判定：存在满足上述离场条件的对方怪兽，且不包含自身。
function c59071624.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c59071624.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果③的发动代价：取除这张卡的1个超量素材。
function c59071624.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果③的对象过滤：在触发事件的卡片中，选择满足离场条件且可以被特殊召唤的怪兽。
function c59071624.spfilter2(c,e,tp,g)
	return g:IsContains(c) and c59071624.cfilter(c,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备：进行对象选择与合法性检测。
function c59071624.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c59071624.spfilter2(chkc,e,tp,eg) end
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地或除外区是否存在至少1只满足条件的、可作为效果对象的怪兽。
		and Duel.IsExistingTarget(c59071624.spfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil,e,tp,eg) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择1只满足条件的墓地或除外区的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c59071624.spfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil,e,tp,eg)
	-- 设置连锁处理的操作信息：特殊召唤选中的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的效果处理：将选中的对象怪兽在自己场上特殊召唤。
function c59071624.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的第一个对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
