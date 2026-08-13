--スプラッシュ・メイジ
-- 效果：
-- 电子界族怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己墓地1只电子界族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
function c59859086.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：用2只电子界族怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2)
	-- 这个卡名的效果1回合只能使用1次。①：以自己墓地1只电子界族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59859086,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,59859086)
	e1:SetTarget(c59859086.sptg)
	e1:SetOperation(c59859086.spop)
	c:RegisterEffect(e1)
end
-- 筛选墓地中满足条件的电子界族怪兽：必须是电子界族且可以被当前效果以表侧守备表示特殊召唤。
function c59859086.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 取对象时校验：对象必须在自己墓地且满足特殊召唤条件；发动时校验：自己主怪兽区有空位且墓地存在至少1只满足条件的电子界族怪兽。
function c59859086.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c59859086.spfilter(chkc,e,tp) end
	-- 确认自己主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认墓地是否存在1只满足特殊召唤条件的电子界族怪兽。
		and Duel.IsExistingTarget(c59859086.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作者显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的电子界族怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c59859086.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：本效果包含特殊召唤，对象为所选的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象怪兽从墓地特殊召唤，对其附加效果无效化，并在回合结束前附加电子界族自肃。
function c59859086.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本连锁的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关且可以表侧守备表示特殊召唤，则执行特殊召唤步骤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 结束特殊召唤步骤，完成特殊召唤处理。
		Duel.SpecialSummonComplete()
	end
	-- 这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c59859086.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给发动玩家。
	Duel.RegisterEffect(e3,tp)
end
-- 自肃条件的判定：只要怪兽不是电子界族，就不能进行特殊召唤。
function c59859086.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
