--海晶乙女マンダリン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上有「海晶少女」怪兽2只以上存在的场合，以自己场上1只水属性连接怪兽为对象才能发动。这张卡在作为那只怪兽所连接区的自己场上特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c28174796.initial_effect(c)
	-- 创建效果1，用于处理海晶少女 官服鱼的起动效果，该效果为特殊召唤类效果，需要选择对象，生效位置为手牌或墓地，且每回合只能发动一次
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
-- 过滤函数，用于判断场上是否存在至少2只「海晶少女」属性的表侧表示怪兽
function c28174796.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b)
end
-- 效果发动条件函数，检查自己场上是否存在至少2只「海晶少女」属性的表侧表示怪兽
function c28174796.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少2只「海晶少女」属性的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c28174796.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 特殊召唤目标过滤函数，用于筛选自己场上满足条件的水属性连接怪兽，且当前卡可以特殊召唤到该怪兽的连接区
function c28174796.spfilter(c,e,tp,ec)
	local zone=c:GetLinkedZone(tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_LINK) and ec:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果处理的引导函数，用于选择目标怪兽并设置效果处理信息
function c28174796.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28174796.spfilter(chkc,e,tp,c) end
	-- 检查是否满足发动条件，即自己场上是否存在至少1只满足条件的水属性连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c28174796.spfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,c) end
	-- 向玩家提示“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的水属性连接怪兽作为效果对象
	Duel.SelectTarget(tp,c28174796.spfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,c)
	-- 设置效果处理信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数，执行特殊召唤操作并将此卡从场上离开时除外的效果
function c28174796.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	local zone=tc:GetLinkedZone(tp)
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and zone&0x1f~=0
		-- 执行特殊召唤操作，将此卡特殊召唤到目标怪兽的连接区
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)>0 then
		-- 为特殊召唤的此卡设置效果，使其在从场上离开时被除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
