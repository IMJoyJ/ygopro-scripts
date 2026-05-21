--Gゴーレム・スタバン・メンヒル
-- 效果：
-- 地属性怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡从墓地的特殊召唤成功的场合，以自己墓地1只可以通常召唤的地属性怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。这个效果特殊召唤的怪兽的效果无效化，从场上离开的场合除外。
function c97053215.initial_effect(c)
	-- 设置连接召唤的手续，需要2只地属性怪兽作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_EARTH),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡从墓地的特殊召唤成功的场合，以自己墓地1只可以通常召唤的地属性怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。这个效果特殊召唤的怪兽的效果无效化，从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97053215,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,97053215)
	e1:SetCondition(c97053215.spcon)
	e1:SetTarget(c97053215.sptg)
	e1:SetOperation(c97053215.spop)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否是从墓地特殊召唤成功。
function c97053215.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 过滤自己墓地满足“地属性”、“可以通常召唤”且“能加入手卡或能特殊召唤”条件的怪兽。
function c97053215.spfilter(c,e,tp,ft)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsSummonableCard()
		and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果发动时的对象选择与合法性检查。
function c97053215.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c97053215.spfilter(chkc,e,tp,ft) end
	-- 检查自己墓地是否存在符合条件的可选择对象。
	if chk==0 then return Duel.IsExistingTarget(c97053215.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ft) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只符合条件的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c97053215.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ft)
end
-- 效果处理的执行逻辑。
function c97053215.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 检查是否受到「王家长眠之谷」的影响而使涉及墓地的效果无效。
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 检查是否有空余怪兽区域且对象怪兽是否可以特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 若对象怪兽无法加入手卡，或者玩家在“加入手卡”与“特殊召唤”中选择“特殊召唤”。
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将对象怪兽以表侧表示特殊召唤（分步处理）。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 这个效果特殊召唤的怪兽的效果无效化
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 这个效果特殊召唤的怪兽的效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			-- 从场上离开的场合除外
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e3:SetValue(LOCATION_REMOVED)
			tc:RegisterEffect(e3)
			-- 完成特殊召唤的后续处理。
			Duel.SpecialSummonComplete()
		else
			-- 将对象怪兽加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
