--紅貴士－ヴァンパイア・ブラム
-- 效果：
-- 不死族5星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤成功的回合，那只怪兽以外的自己怪兽不能攻击。
-- ②：场上的这张卡被对方破坏送去墓地的下个回合的准备阶段发动。这张卡从墓地守备表示特殊召唤。
function c38250531.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足不死族条件的怪兽作为素材进行召唤
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),5,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤成功的回合，那只怪兽以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38250531,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,38250531)
	e1:SetCost(c38250531.spcost)
	e1:SetTarget(c38250531.sptg)
	e1:SetOperation(c38250531.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被对方破坏送去墓地的下个回合的准备阶段发动。这张卡从墓地守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c38250531.spreg)
	c:RegisterEffect(e2)
	-- 场上的这张卡被对方破坏送去墓地的下个回合的准备阶段发动。这张卡从墓地守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38250531,1))  --"苏生"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c38250531.spcon2)
	e3:SetTarget(c38250531.sptg2)
	e3:SetOperation(c38250531.spop2)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 支付效果的代价，移除自身1个超量素材
function c38250531.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 判断目标怪兽是否可以特殊召唤
function c38250531.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标，选择对方墓地一只可以特殊召唤的怪兽
function c38250531.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c38250531.spfilter(chkc,e,tp) end
	-- 判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断对方墓地是否存在可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c38250531.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c38250531.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果的处理信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果，将目标怪兽特殊召唤，并设置不能攻击的效果
function c38250531.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效并进行特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 创建并注册不能攻击的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c38250531.ftarget)
		e1:SetLabel(tc:GetFieldID())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将不能攻击的效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 设置不能攻击效果的目标条件，排除特殊召唤的怪兽
function c38250531.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 注册效果，当此卡被破坏送入墓地时记录下回合数
function c38250531.spreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==1-tp and c:IsReason(REASON_DESTROY)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- 记录下回合数用于后续触发效果
		e:SetLabel(Duel.GetTurnCount()+1)
		c:RegisterFlagEffect(38250531,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 判断是否为指定回合触发效果
function c38250531.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为指定回合且拥有标记效果
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(38250531)>0
end
-- 设置效果的处理信息，准备特殊召唤自己
function c38250531.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的处理信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(38250531)
end
-- 处理效果，将自己从墓地特殊召唤
function c38250531.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自己从墓地以守备表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
