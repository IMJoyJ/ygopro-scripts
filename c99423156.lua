--不知火の宮司
-- 效果：
-- 「不知火的宫司」的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。从自己的手卡·墓地选「不知火的宫司」以外的1只「不知火」怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
-- ②：这张卡被除外的场合，以对方场上1张表侧表示的卡为对象才能发动。那张卡破坏。
function c99423156.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从自己的手卡·墓地选「不知火的宫司」以外的1只「不知火」怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99423156,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c99423156.sumtg)
	e1:SetOperation(c99423156.sumop)
	c:RegisterEffect(e1)
	-- 「不知火的宫司」的②的效果1回合只能使用1次。②：这张卡被除外的场合，以对方场上1张表侧表示的卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99423156,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,99423156)
	e2:SetTarget(c99423156.target)
	e2:SetOperation(c99423156.operation)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤的筛选条件：选择手卡·墓地中卡名不是「不知火的宫司」的「不知火」怪兽，且该怪兽可以被特殊召唤。
function c99423156.spfilter(c,e,tp)
	return c:IsSetCard(0xd9) and not c:IsCode(99423156) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件检查：自己主要怪兽区有空位，且手卡·墓地中存在满足spfilter条件的「不知火」怪兽。
function c99423156.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性判定时，首先检查自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手卡·墓地中是否存在满足spfilter条件的「不知火」怪兽（至少1张）。
		and Duel.IsExistingMatchingCard(c99423156.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置本效果处理时将进行的特殊召唤操作信息：从手卡·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤的处理：确认主怪兽区有空位后，由玩家从手卡·墓地选择1只符合条件的「不知火」怪兽进行特殊召唤，并为被特殊召唤的怪兽附加离场时除外效果，最后完成特殊召唤。
function c99423156.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理阶段再次确认主怪兽区有空位，若没有空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地中选择1张满足spfilter且不受王家长眠之谷影响的「不知火」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c99423156.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选择到了怪兽，则将其以表侧表示进行特殊召唤（特殊召唤步骤），成功后为其附加离场除外效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽从场上离开的场合除外；②：这张卡被除外的场合，以对方场上1张表侧表示的卡为对象才能发动。那张卡破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的分解流程，使所有特殊召唤步骤正式生效。
	Duel.SpecialSummonComplete()
end
-- 定义②效果的对象筛选条件：对方场上的表侧表示卡。
function c99423156.filter(c)
	return c:IsFaceup()
end
-- ②效果的发动条件与目标选择：先检查对方场上是否存在表侧表示卡；若存在，由玩家选择1张作为破坏对象。
function c99423156.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c99423156.filter(chkc) end
	-- 在②效果发动合法性判定时，检查对方场上是否存在表侧表示的可选目标（至少1张）。
	if chk==0 then return Duel.IsExistingTarget(c99423156.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示选择提示信息，提示选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张表侧表示卡作为效果对象，并设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c99423156.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本效果处理时将进行的破坏操作信息，记录将要破坏的目标及数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得发动时选择的对象，若该对象仍与效果关联，则将其破坏。
function c99423156.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的（唯一）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
