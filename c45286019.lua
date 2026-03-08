--ギアギアーノ Mk－Ⅲ
-- 效果：
-- 这张卡用名字带有「齿轮齿轮」的卡的效果特殊召唤成功时，可以从自己的手卡·墓地选「齿轮齿轮人 Mk-3」以外的1只名字带有「齿轮齿轮」的怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「齿轮齿轮人 Mk-3」的效果1回合只能使用1次，这个效果发动的回合，自己不能把名字带有「齿轮齿轮」的怪兽以外的怪兽特殊召唤。
function c45286019.initial_effect(c)
	-- 这张卡用名字带有「齿轮齿轮」的卡的效果特殊召唤成功时，可以从自己的手卡·墓地选「齿轮齿轮人 Mk-3」以外的1只名字带有「齿轮齿轮」的怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45286019,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,45286019)
	e1:SetCondition(c45286019.spcon)
	e1:SetCost(c45286019.spcost)
	e1:SetTarget(c45286019.sptg)
	e1:SetOperation(c45286019.spop)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在回合中特殊召唤的「齿轮齿轮」怪兽数量
	Duel.AddCustomActivityCounter(45286019,ACTIVITY_SPSUMMON,c45286019.counterfilter)
end
-- 计数器的过滤函数，判断卡片是否为「齿轮齿轮」系列
function c45286019.counterfilter(c)
	return c:IsSetCard(0x72)
end
-- 效果发动条件：这张卡是通过名字带有「齿轮齿轮」的卡的效果特殊召唤成功的
function c45286019.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0x72)
end
-- 效果的费用：支付1次特殊召唤的限制，防止在本回合再次特殊召唤非「齿轮齿轮」怪兽
function c45286019.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已经使用过该效果（即是否已进行过一次特殊召唤）
	if chk==0 then return Duel.GetCustomActivityCount(45286019,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建一个场上的效果，使对方不能特殊召唤非「齿轮齿轮」怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c45286019.splimit)
	-- 将该效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标函数，禁止特殊召唤非「齿轮齿轮」系列的怪兽
function c45286019.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x72)
end
-- 筛选函数，用于选择可以特殊召唤的「齿轮齿轮」怪兽
function c45286019.filter(c,e,tp)
	return c:IsSetCard(0x72) and not c:IsCode(45286019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果的发动条件判断：检查场上是否有足够的空间，并且自己墓地或手牌中是否存在符合条件的怪兽
function c45286019.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地或手牌中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c45286019.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果的处理函数：选择并特殊召唤符合条件的怪兽，并将其效果无效化
function c45286019.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地或手牌中选择符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45286019.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧守备形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 使该特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使该特殊召唤的怪兽效果在回合结束时解除无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
