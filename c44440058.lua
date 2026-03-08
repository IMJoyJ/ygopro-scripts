--ネメシス・キーストーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「星义关键兽」以外的除外的1只自己怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
-- ②：这张卡被除外的回合的结束阶段才能发动。这张卡加入手卡。
function c44440058.initial_effect(c)
	-- ①：以「星义关键兽」以外的除外的1只自己怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44440058,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,44440058)
	e1:SetTarget(c44440058.sptg)
	e1:SetOperation(c44440058.spop)
	c:RegisterEffect(e1)
	-- 这张卡被除外的回合的结束阶段才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(c44440058.regop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44440058,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,44440059)
	e3:SetCondition(c44440058.thcon)
	e3:SetTarget(c44440058.thtg)
	e3:SetOperation(c44440058.thop)
	c:RegisterEffect(e3)
end
-- 用于筛选满足条件的除外怪兽，即正面表示的怪兽且不是星义关键兽且能送入卡组。
function c44440058.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsCode(44440058) and c:IsAbleToDeck()
end
-- 设置效果的发动条件，判断是否满足特殊召唤和选择目标怪兽的条件。
function c44440058.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c44440058.tdfilter(chkc) end
	-- 判断玩家场上是否有足够的怪兽区域进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断玩家场上是否有满足条件的除外怪兽作为目标。
		and Duel.IsExistingTarget(c44440058.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要送入卡组的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的除外怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c44440058.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理时将自身特殊召唤的OperationInfo。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置效果处理时将目标怪兽送入卡组的OperationInfo。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 执行效果处理，将自身特殊召唤并把目标怪兽送入卡组。
function c44440058.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断自身和目标怪兽是否还在场上，满足特殊召唤和送入卡组的条件。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入卡组。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 注册效果flag，用于记录该卡被除外的回合。
function c44440058.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(44440058,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断该卡是否在除外时被记录了flag，用于触发效果。
function c44440058.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(44440058)>0
end
-- 设置效果的发动条件，判断是否满足将自身送入手卡的条件。
function c44440058.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理时将自身送入手卡的OperationInfo。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行效果处理，将自身送入手卡。
function c44440058.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身送入手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
