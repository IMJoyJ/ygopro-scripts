--スタンド・イン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只怪兽解放，以原本的种族·属性是和那只怪兽相同的对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
function c49154689.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只怪兽解放，以原本的种族·属性是和那只怪兽相同的对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCountLimit(1,49154689+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c49154689.cost)
	e1:SetTarget(c49154689.target)
	e1:SetOperation(c49154689.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为解放代价的怪兽：该怪兽必须是怪兽卡（原本类型含怪兽），将其解放后自己场上仍有可用怪兽区，且对方墓地存在与它原本种族、属性相同的可特殊召唤对象。
function c49154689.cfilter(c,e,tp)
	local race=c:GetOriginalRace()
	local attr=c:GetOriginalAttribute()
	return bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
		-- 确认解放该候选怪兽后，自己场上仍至少存在1个可用的怪兽区域，用于后续特殊召唤。
		and Duel.GetMZoneCount(tp,c,tp)>0
		-- 检查对方墓地是否存在至少1只满足spfilter的怪兽，即原本种族和属性与候选解放怪兽相同、且能成为对象并特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c49154689.spfilter,tp,0,LOCATION_GRAVE,1,nil,race,attr,e,tp)
end
-- 墓地怪兽的筛选条件：原本种族和属性与解放的怪兽一致，且能成为本效果的对象，并能够被效果特殊召唤到自己场上。
function c49154689.spfilter(c,race,attr,e,tp)
	return c:GetOriginalRace()==race and c:GetOriginalAttribute()==attr
		and c:IsCanBeEffectTarget(e)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end
-- 发动代价处理：先标记代价已支付，然后选择自己场上1只满足条件的怪兽作为解放代价，记录该怪兽并将其解放。
function c49154689.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 代价检测阶段：检查自己场上是否存在至少1只满足条件的可解放怪兽，以判断能否发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c49154689.cfilter,1,nil,e,tp) end
	-- 让玩家从自己场上选择1只满足条件的怪兽来解放，作为发动代价。
	local sg=Duel.SelectReleaseGroup(tp,c49154689.cfilter,1,1,nil,e,tp)
	e:SetLabelObject(sg:GetFirst())
	-- 将选择的怪兽作为代价解放送入墓地。
	Duel.Release(sg,REASON_COST)
end
-- 效果对象选择：获取解放的怪兽rc，在连锁选择对象时确认候选卡位于对方墓地、且原本种族/属性与rc一致并满足特殊召唤条件。
function c49154689.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local rc=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp)
		and c49154689.spfilter(chkc,rc:GetOriginalRace(),rc:GetOriginalAttribute(),e,tp) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return true
	end
	e:SetLabel(0)
	-- 显示选择要特殊召唤的卡的提示消息，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从对方墓地选择1只满足条件的怪兽作为效果对象，并设定为当前连锁的对象。
	local sg=Duel.SelectTarget(tp,c49154689.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,rc:GetOriginalRace(),rc:GetOriginalAttribute(),e,tp)
	-- 登记本连锁的操作信息，分类为特殊召唤，使其他卡能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
end
-- 效果处理：取得对象卡，确认其与效果仍有关联后，将其特殊召唤到自己场上。
function c49154689.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象怪兽（即选择的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将目标怪兽以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end
