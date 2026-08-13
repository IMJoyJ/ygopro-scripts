--紅貴士－ヴァンパイア・ブラム
-- 效果：
-- 不死族5星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤成功的回合，那只怪兽以外的自己怪兽不能攻击。
-- ②：场上的这张卡被对方破坏送去墓地的下个回合的准备阶段发动。这张卡从墓地守备表示特殊召唤。
function c38250531.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以2只等级5的不死族怪兽作为超量素材才能XYZ召唤（对应召唤条件“不死族5星怪兽×2”）。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),5,2)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：把这张卡1个超量素材取除，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤成功的回合，那只怪兽以外的自己怪兽不能攻击。
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
	-- 场上的这张卡被对方破坏送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c38250531.spreg)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡被对方破坏送去墓地的下个回合的准备阶段发动。这张卡从墓地守备表示特殊召唤。
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
-- 发动代价：从这张卡上取除1个超量素材。
function c38250531.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选条件：可用于特殊召唤的怪兽（能够被当前效果特殊召唤）。
function c38250531.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择函数：对连锁中已指定的对象进行合法性校验；在发动时检查己方主要怪兽区是否有空位，且对方墓地存在满足条件的对象怪兽。
function c38250531.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c38250531.spfilter(chkc,e,tp) end
	-- 检查己方主要怪兽区域是否有空格，以确保特殊召唤有可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方墓地是否存在至少1只满足特殊召唤条件的怪兽可作为对象。
		and Duel.IsExistingTarget(c38250531.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 弹出选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从对方墓地选择1只满足条件的怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c38250531.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息：本效果将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的对象怪兽特殊召唤到自己场上；若成功，则给己方场上施加“该怪兽以外的己方怪兽不能攻击”的限制效果，持续到回合结束。
function c38250531.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联后，将其表侧攻击表示特殊召唤到自己场上；若特殊召唤成功则继续执行限制攻击的后续处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤成功的回合，那只怪兽以外的自己怪兽不能攻击。②：场上的这张卡被对方破坏送去墓地的下个回合的准备阶段发动。这张卡从墓地守备表示特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c38250531.ftarget)
		e1:SetLabel(tc:GetFieldID())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将攻击限制效果注册到场上，使其对己方怪兽生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 攻击限制的对象筛选：除特殊召唤成功的那只怪兽以外的己方怪兽（通过场地ID判断）受到不能攻击的限制。
function c38250531.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 记录②的发动条件：当这张卡在场上被对方破坏并送去墓地时，登记预定发动回合并打上标记。
function c38250531.spreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==1-tp and c:IsReason(REASON_DESTROY)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- 将预定发动回合设为当前回合+1，即“下个回合”的准备阶段。
		e:SetLabel(Duel.GetTurnCount()+1)
		c:RegisterFlagEffect(38250531,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- ②的发动条件判定：当前处于记录的下个回合（准备阶段），且该卡仍带有“被对方破坏送去墓地”的标记。
function c38250531.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合数等于之前记录的“下个回合”，且卡片上存在有效标记，即满足发动②的时点与条件。
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(38250531)>0
end
-- ②发动时确认合法，并设置特殊召唤自身的操作信息，同时清除标记（发动后该标记不再需要）。
function c38250531.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：声明将把这张卡自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(38250531)
end
-- ②的效果处理：若该卡仍在墓地且与效果关联，则将其表侧守备表示特殊召唤到自己场上。
function c38250531.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
