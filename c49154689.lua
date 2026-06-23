--スタンド・イン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只怪兽解放，以原本的种族·属性是和那只怪兽相同的对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
function c49154689.initial_effect(c)
	-- 创建效果，设置为魔陷发动、自由时点、只能发动一次、取对象、有费用、有目标、有处理效果
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
-- 检查场上是否有可解放的怪兽，且该怪兽的种族和属性在对方墓地存在相同种族和属性的怪兽可以特殊召唤
function c49154689.cfilter(c,e,tp)
	local race=c:GetOriginalRace()
	local attr=c:GetOriginalAttribute()
	return bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
		-- 确保解放的怪兽在自己场上还有可用的怪兽区域
		and Duel.GetMZoneCount(tp,c,tp)>0
		-- 检查对方墓地是否存在与解放怪兽种族和属性相同的怪兽
		and Duel.IsExistingMatchingCard(c49154689.spfilter,tp,0,LOCATION_GRAVE,1,nil,race,attr,e,tp)
end
-- 判断目标怪兽是否满足种族和属性条件、可作为效果对象、且能特殊召唤
function c49154689.spfilter(c,race,attr,e,tp)
	return c:GetOriginalRace()==race and c:GetOriginalAttribute()==attr
		and c:IsCanBeEffectTarget(e)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end
-- 设置发动费用，检查并选择一个可解放的怪兽进行解放
function c49154689.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 检查是否有符合条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c49154689.cfilter,1,nil,e,tp) end
	-- 选择一个符合条件的可解放怪兽
	local sg=Duel.SelectReleaseGroup(tp,c49154689.cfilter,1,1,nil,e,tp)
	e:SetLabelObject(sg:GetFirst())
	-- 将选中的怪兽从场上解放作为发动费用
	Duel.Release(sg,REASON_COST)
end
-- 设置效果目标，选择对方墓地一张种族和属性与解放怪兽相同的怪兽
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
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的对方墓地怪兽作为特殊召唤对象
	local sg=Duel.SelectTarget(tp,c49154689.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,rc:GetOriginalRace(),rc:GetOriginalAttribute(),e,tp)
	-- 设置操作信息，确定特殊召唤的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
end
-- 执行效果处理，将选中的怪兽特殊召唤到自己场上
function c49154689.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将目标怪兽特殊召唤到自己场上
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end
