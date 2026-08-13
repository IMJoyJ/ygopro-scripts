--海晶乙女マンダリン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上有「海晶少女」怪兽2只以上存在的场合，以自己场上1只水属性连接怪兽为对象才能发动。这张卡在作为那只怪兽所连接区的自己场上特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c28174796.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，自己场上有「海晶少女」怪兽2只以上存在的场合，以自己场上1只水属性连接怪兽为对象才能发动。这张卡在作为那只怪兽所连接区的自己场上特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28174796,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,28174796)
	e1:SetCondition(c28174796.spcon)
	e1:SetTarget(c28174796.sptg)
	e1:SetOperation(c28174796.spop)
	c:RegisterEffect(e1)
end
-- 检查怪兽是否为表侧表示且属于「海晶少女」系列，用于筛选场上符合条件的「海晶少女」怪兽。
function c28174796.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b)
end
-- 效果发动条件：自己的怪兽区域存在2只以上表侧表示的「海晶少女」怪兽。
function c28174796.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少2只满足条件的「海晶少女」怪兽（表侧表示且属于该系列）。
	return Duel.IsExistingMatchingCard(c28174796.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 筛选效果对象：必须是自己场上表侧表示的水属性连接怪兽，并且这张卡能够特殊召唤到该怪兽的连接区域。
function c28174796.spfilter(c,e,tp,ec)
	local zone=c:GetLinkedZone(tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_LINK) and ec:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果的发动目标处理：选自己场上1只水属性连接怪兽为对象，并设置将这张卡特殊召唤的操作信息。
function c28174796.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28174796.spfilter(chkc,e,tp,c) end
	-- 发动时检查是否存在至少1只满足条件的水属性连接怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c28174796.spfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,c) end
	-- 向玩家显示选择对象的提示信息（请选择效果的对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只满足条件的水属性连接怪兽作为效果对象，并登记为连锁对象。
	Duel.SelectTarget(tp,c28174796.spfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,c)
	-- 设置本次连锁操作信息：将这张卡特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：这张卡特殊召唤到对象连接怪兽的连接区域；若特殊召唤成功，为这张卡附加“因该效果特殊召唤的这张卡离场时除外”的效果。
function c28174796.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的对象（水属性连接怪兽）。
	local tc=Duel.GetFirstTarget()
	local zone=tc:GetLinkedZone(tp)
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and zone&0x1f~=0
		-- 将这张卡以表侧表示特殊召唤到对象怪兽的连接区域（检查是否召唤成功）。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
