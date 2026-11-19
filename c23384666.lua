--機巧蛙－磐盾多邇具久
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组选攻击力和守备力的数值相同的1只机械族怪兽在卡组最上面放置。
-- ②：把墓地的这张卡除外，以攻击力和守备力的数值相同的自己墓地1只机械族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c23384666.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从卡组选攻击力和守备力的数值相同的1只机械族怪兽在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23384666,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,23384666)
	e1:SetTarget(c23384666.tdtg)
	e1:SetOperation(c23384666.tdop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：把墓地的这张卡除外，以攻击力和守备力的数值相同的自己墓地1只机械族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23384666,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,23384667)
	-- 设置效果的发动代价为将墓地中的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c23384666.sptg)
	e3:SetOperation(c23384666.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，筛选卡组中攻击力与守备力数值相同且为机械族的怪兽
function c23384666.tdfilter(c)
	-- 检查卡片的攻击力与守备力数值是否相同，且种族为机械族
	return aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE)
end
-- ①效果的Target函数，检查自己卡组是否存在满足条件的怪兽且卡组数量大于1张
function c23384666.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测时，检查自己卡组是否存在至少1张满足tdfilter条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c23384666.tdfilter,tp,LOCATION_DECK,0,1,nil)
		-- 同时检查自己卡组的卡片数量是否大于1张（否则无需调整卡组顺序）
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
end
-- ①效果的Operation函数，从自己卡组选1只攻击力和守备力数值相同的机械族怪兽，洗切卡组后将其放置到卡组最上面并确认
function c23384666.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己发送选择提示信息：“请选择要放置到卡组最上面的卡”
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23384666,2))  --"请选择要放置到卡组最上面的卡"
	-- 让自己在自己卡组中选择1只满足tdfilter条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c23384666.tdfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		-- 将选中的怪兽移动到自己卡组最上面
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认自己卡组最上面的1张卡
		Duel.ConfirmDecktop(tp,1)
	end
end
-- 过滤函数，筛选机械族、攻击力与守备力数值相同且能以表侧守备表示特殊召唤的怪兽
function c23384666.spfilter(c,e,tp)
	-- 检查卡片是否为机械族且攻击力与守备力的数值相同
	return c:IsRace(RACE_MACHINE) and aux.AtkEqualsDef(c)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的Target函数，检测并选择自己墓地1只满足spfilter条件的怪兽作为效果对象并设置特殊召唤操作信息
function c23384666.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23384666.spfilter(chkc,e,tp) end
	-- 发动条件检测时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在除这张卡以外至少1只满足spfilter条件且可作为对象的怪兽
		and Duel.IsExistingTarget(c23384666.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 向自己发送选择提示信息：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己在自己墓地选择除这张卡以外的1只满足spfilter条件的怪兽作为连锁对象
	local g=Duel.SelectTarget(tp,c23384666.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置当前连锁的操作信息，声明将对对象卡g中的1只怪兽进行特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的Operation函数，检查怪兽区空格和对象关联性后，将对象怪兽以表侧守备表示特殊召唤
function c23384666.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己怪兽区没有可用空格则终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁指定的第1张对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
