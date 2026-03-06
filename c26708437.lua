--エクシーズ・リボーン
-- 效果：
-- ①：以自己墓地1只超量怪兽为对象才能发动。那只怪兽特殊召唤，把这张卡在下面重叠作为超量素材。
function c26708437.initial_effect(c)
	-- 效果原文内容：①：以自己墓地1只超量怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c26708437.target)
	e1:SetOperation(c26708437.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查目标怪兽是否为超量怪兽且可以特殊召唤
function c26708437.filter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置效果目标为己方墓地的超量怪兽
function c26708437.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c26708437.filter(chkc,e,tp) end
	-- 效果作用：判断是否满足发动条件，包括己方场上存在空位
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanOverlay()
		-- 效果作用：判断己方墓地是否存在满足条件的超量怪兽
		and Duel.IsExistingTarget(c26708437.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的墓地超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c26708437.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 效果作用：设置连锁操作信息，表明将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果原文内容：那只怪兽特殊召唤，把这张卡在下面重叠作为超量素材。
function c26708437.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 效果作用：确认目标怪兽和自身卡都存在于场上或墓地，并执行特殊召唤和叠放操作
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and c:IsRelateToEffect(e) and c:IsCanOverlay() then
		c:CancelToGrave()
		-- 效果作用：将自身叠放至特殊召唤的怪兽下方作为超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
