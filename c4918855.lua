--竜血公ヴァンパイア
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤成功的场合，以对方墓地最多2只怪兽为对象才能发动。那些怪兽效果无效在自己场上守备表示特殊召唤。
-- ②：怪兽的效果发动时，那些同名怪兽在自己·对方的墓地存在的场合才能发动。那个发动无效。
-- ③：从对方墓地有怪兽特殊召唤的场合，把自己场上2只怪兽解放才能发动。这张卡从墓地特殊召唤。
function c4918855.initial_effect(c)
	-- ①：这张卡召唤成功的场合，以对方墓地最多2只怪兽为对象才能发动。那些怪兽效果无效在自己场上守备表示特殊召唤。
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
	-- ②：怪兽的效果发动时，那些同名怪兽在自己·对方的墓地存在的场合才能发动。那个发动无效。
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
	-- ③：从对方墓地有怪兽特殊召唤的场合，把自己场上2只怪兽解放才能发动。这张卡从墓地特殊召唤。
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
-- 定义了可以被特殊召唤的卡片过滤条件，即满足特定条件的卡片可以被特殊召唤到场上守备表示。
function c4918855.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果目标选择函数，用于确定在对方墓地中可选择的怪兽数量和条件。
function c4918855.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取玩家当前场上可用的怪兽区域数量。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c4918855.spfilter(chkc,e,tp) end
	if chk==0 then return ct>0
		-- 检查是否存在满足条件的目标怪兽（来自对方墓地）。
		and Duel.IsExistingTarget(c4918855.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	if ct>2 then ct=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 向玩家发送提示信息，提示其选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 根据设定条件从对方墓地中选择目标怪兽。
	local g=Duel.SelectTarget(tp,c4918855.spfilter,tp,0,LOCATION_GRAVE,1,ct,nil,e,tp)
	-- 设置连锁操作信息，表明本次效果将特殊召唤指定数量的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 处理效果发动后的操作，包括判断是否满足召唤条件、进行特殊召唤并附加效果。
function c4918855.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家当前场上可用的怪兽区域数量。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct<1 then return end
	-- 从连锁信息中提取已选定的目标卡片，并筛选出与当前效果相关的卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>ct or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then
		-- 向玩家发送提示信息，提示其选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,1,1,nil)
	end
	local tc=g:GetFirst()
	while tc do
		-- 将目标怪兽以守备表示形式特殊召唤到场上。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 那些怪兽效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那些怪兽效果无效
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 完成所有特殊召唤步骤，确保所有召唤操作生效。
	Duel.SpecialSummonComplete()
end
-- 判断是否满足发动无效效果的条件，包括对方怪兽效果发动、连锁可被无效以及己方墓地存在同名怪兽。
function c4918855.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁是否为怪兽类型的效果发动且该发动可以被无效。
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 检查己方墓地中是否存在与对方发动效果的卡片同名的怪兽。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,re:GetHandler():GetCode())
end
-- 设置无效效果的目标信息，表明本次效果将使对方发动无效。
function c4918855.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表明本次效果将使对方发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 执行无效效果的操作，使当前连锁发动无效。
function c4918855.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁发动无效。
	Duel.NegateActivation(ev)
end
-- 定义了用于筛选从墓地特殊召唤的怪兽的过滤条件。
function c4918855.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:IsPreviousControler(1-tp) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 判断是否满足发动第三效果的条件，即对方有怪兽从墓地特殊召唤成功。
function c4918855.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c4918855.cfilter,1,nil,tp)
end
-- 设置发动第三效果所需的费用，需要解放自己场上的2只怪兽。
function c4918855.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家当前可解放的卡片组。
	local rg=Duel.GetReleaseGroup(tp)
	-- 检查是否存在满足条件的卡片组合可以用于支付费用。
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 向玩家发送提示信息，提示其选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从可解放卡片中选择满足条件的2张卡片。
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 强制使用代替解放效果次数。
	aux.UseExtraReleaseCount(g,tp)
	-- 将选定的卡片以代价形式进行解放。
	Duel.Release(g,REASON_COST)
end
-- 设置发动第三效果的目标信息，表明本次效果将特殊召唤自身。
function c4918855.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表明本次效果将特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理第三效果的发动操作，如果满足条件则将自身从墓地特殊召唤到场上。
function c4918855.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以指定方式特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
