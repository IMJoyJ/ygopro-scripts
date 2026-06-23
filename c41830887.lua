--複写機塊コピーボックル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「机块」怪兽为对象才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡直到结束阶段当作和作为对象的怪兽同名卡使用。
-- ②：把墓地的这张卡除外，以自己场上1只「机块」怪兽为对象才能发动。从自己的手卡·墓地选1只那只怪兽的同名怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c41830887.initial_effect(c)
	-- ①：以自己场上1只「机块」怪兽为对象才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡直到结束阶段当作和作为对象的怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41830887,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,41830887)
	e1:SetTarget(c41830887.sptg1)
	e1:SetOperation(c41830887.spop1)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「机块」怪兽为对象才能发动。从自己的手卡·墓地选1只那只怪兽的同名怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41830887,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,41830888)
	-- 效果发动时，若此卡已送去墓地则不能发动
	e2:SetCondition(aux.exccon)
	-- 将此卡从墓地除外作为发动条件
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c41830887.sptg2)
	e2:SetOperation(c41830887.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否有表侧表示的「机块」怪兽
function c41830887.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x14b)
end
-- 效果发动时，判断是否满足发动条件：此卡可特殊召唤、场上存在「机块」怪兽
function c41830887.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c41830887.filter(chkc) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断场上是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上是否存在满足条件的「机块」怪兽
		and Duel.IsExistingTarget(c41830887.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上满足条件的「机块」怪兽作为对象
	Duel.SelectTarget(tp,c41830887.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数，将此卡特殊召唤并使其变为与对象怪兽同名
function c41830887.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	local code=tc:GetOriginalCode()
	if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)) then return end
	-- 将此卡特殊召唤
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 创建一个使此卡变为对象怪兽同名卡的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 过滤函数，用于判断场上是否有表侧表示的「机块」怪兽，并且其同名怪兽存在于手牌或墓地
function c41830887.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x14b)
		-- 判断手牌或墓地是否存在对象怪兽的同名怪兽
		and Duel.IsExistingMatchingCard(c41830887.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp,c:GetCode())
end
-- 过滤函数，用于判断手牌或墓地的卡是否为指定编号且可特殊召唤
function c41830887.spfilter2(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时，判断是否满足发动条件：此卡可特殊召唤、场上存在「机块」怪兽
function c41830887.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c41830887.spfilter1(chkc,e,tp) end
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上是否存在满足条件的「机块」怪兽
		and Duel.IsExistingTarget(c41830887.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上满足条件的「机块」怪兽作为对象
	Duel.SelectTarget(tp,c41830887.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将从手牌或墓地特殊召唤同名怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数，将手牌或墓地的同名怪兽特殊召唤
function c41830887.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的同名怪兽
		local g=Duel.SelectMatchingCard(tp,c41830887.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetCode())
		if g:GetCount()>0 then
			-- 将选中的同名怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
