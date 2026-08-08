--竜血公ヴァンパイア
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤成功的场合，以对方墓地最多2只怪兽为对象才能发动。那些怪兽效果无效在自己场上守备表示特殊召唤。
-- ②：怪兽的效果发动时，那些同名怪兽在自己·对方的墓地存在的场合才能发动。那个发动无效。
-- ③：从对方墓地有怪兽特殊召唤的场合，把自己场上2只怪兽解放才能发动。这张卡从墓地特殊召唤。
function c4918855.initial_effect(c)
	-- 创建效果，描述为“特殊召唤”，类别为特殊召唤，类型为单次触发型，属性为延迟和对象指向，触发条件为怪兽通常召唤成功，限制次数为每回合一次，目标函数为c4918855.sptg1，操作函数为c4918855.spop1。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4918855,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,4918855)
	e1:SetTarget(c4918855.sptg1)
	e1:SetOperation(c4918855.spop1)
	c:RegisterEffect(e1)
	-- 创建效果，描述为“发动无效”，类别为无效化，类型为快速型，触发条件为连锁，属性为伤害步骤和伤害计算阶段，生效范围为主怪兽区，限制次数为每回合一次，条件函数为c4918855.negcon，目标函数为c4918855.negtg，操作函数为c4918855.negop。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4918855,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,4918856)
	e2:SetCondition(c4918855.negcon)
	e2:SetTarget(c4918855.negtg)
	e2:SetOperation(c4918855.negop)
	c:RegisterEffect(e2)
	-- 创建效果，描述为“这张卡特殊召唤”，类别为特殊召唤，类型为场地和触发型，属性为延迟，触发条件为怪兽特殊召唤成功，生效范围为墓地，限制次数为每回合一次，条件函数为c4918855.spcon2，代价函数为c4918855.spcost2，目标函数为c4918855.sptg2，操作函数为c4918855.spop2。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4918855,2))  --"这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,4918857)
	e3:SetCondition(c4918855.spcon2)
	e3:SetCost(c4918855.spcost2)
	e3:SetTarget(c4918855.sptg2)
	e3:SetOperation(c4918855.spop2)
	c:RegisterEffect(e3)
end
-- 定义过滤函数c4918855.spfilter，用于判断卡片是否可以特殊召唤（参数包括效果、回合数、玩家、正面表示守备位置）。
function c4918855.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义目标选择函数c4918855.sptg1，获取主怪兽区数量，检查连锁确认时是否为对方墓地且满足spfilter条件，如果未选择则返回主怪兽区大于0且存在满足条件的卡片。
function c4918855.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取玩家tp的主怪兽区数量。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c4918855.spfilter(chkc,e,tp) end
	if chk==0 then return ct>0
		-- 判断是否存在满足特殊召唤过滤器的目标卡片。
		and Duel.IsExistingTarget(c4918855.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	if ct>2 then ct=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 使用spfilter函数，从墓地选择1到ct张卡片作为特殊召唤的目标。
	local g=Duel.SelectTarget(tp,c4918855.spfilter,tp,0,LOCATION_GRAVE,1,ct,nil,e,tp)
	-- 设置当前处理连锁的操作信息为特殊召唤，目标卡片组为g，数量为g:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 定义操作函数c4918855.spop1，获取主怪兽区数量，如果小于1则返回。获取连锁的目标卡片并过滤与效果相关的卡片，如果不存在则返回。检测【青眼精灵龙】(59822133)的效果是否生效中，限制特殊召唤数量。选择一张卡片进行特殊召唤。
function c4918855.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家tp的主怪兽区数量。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct<1 then return end
	-- 获取连锁的目标卡片并过滤与效果相关的卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>ct or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,1,1,nil)
	end
	local tc=g:GetFirst()
	while tc do
		-- 以正面守备表示特殊召唤选定的卡片tc。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 创建单次效果，禁用目标怪兽的效果，并在回合结束时重置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 创建单次效果，禁用目标怪兽的自身效果，并在下个回合重置。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 完成特殊召唤流程。
	Duel.SpecialSummonComplete()
end
-- 定义条件函数c4918855.negcon，判断连锁发动是否为怪兽效果、可被无效化以及对方墓地是否存在与发动卡牌代码相同的卡片。
function c4918855.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁发动的类型是否为怪兽，并且可以被无效化。
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 检查对方墓地是否存在与当前连锁发动卡牌代码相同的卡片。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,re:GetHandler():GetCode())
end
-- 定义目标选择函数c4918855.negtg，如果进行确认则返回true，设置操作信息为无效化效果。
function c4918855.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理连锁的操作信息为无效化，目标卡片组为eg，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 定义操作函数c4918855.negop，使连锁发动无效。
function c4918855.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效。
	Duel.NegateActivation(ev)
end
-- 定义过滤函数c4918855.cfilter，判断卡片是否在墓地、原控制者为对方以及是否为怪兽。
function c4918855.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:IsPreviousControler(1-tp) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 定义条件函数c4918855.spcon2，判断是否存在满足c4918855.cfilter条件的卡片。
function c4918855.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c4918855.cfilter,1,nil,tp)
end
-- 定义代价函数c4918855.spcost2，获取解放组，检查是否可以释放2张怪兽，提示玩家选择要解放的卡片，使用额外解放次数，解放选定的卡片。
function c4918855.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取可解放的卡片组。
	local rg=Duel.GetReleaseGroup(tp)
	-- 检查解放组中是否有足够的怪兽区域来放置要特殊召唤的怪兽，并验证这些怪兽是否可以被正常释放。
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 提示玩家选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从解放组中选择满足aux.mzctcheckrel条件的2张卡片。
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 强制使用类似暗影敌托邦这样的代替解放效果次数。
	aux.UseExtraReleaseCount(g,tp)
	-- 以REASON_COST原因释放选定的卡片。
	Duel.Release(g,REASON_COST)
end
-- 定义目标选择函数c4918855.sptg2，如果进行确认则返回e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)，设置操作信息为特殊召唤。
function c4918855.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前处理连锁的操作信息为特殊召唤，目标卡片组为e:GetHandler()，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义操作函数c4918855.spop2，获取效果发动者，如果与效果相关则以正面表示特殊召唤该卡片。
function c4918855.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 特殊召唤效果发动者。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
