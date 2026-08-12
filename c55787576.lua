--星遺物－『星盾』
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡只要在怪兽区域存在，不受从额外卡组特殊召唤的怪兽发动的效果影响。
-- ②：和这张卡相同纵列的自己的「星遗物」卡不会成为对方的效果的对象，不会被对方的效果破坏。
-- ③：这张卡在墓地存在的场合，自己·对方的准备阶段支付1000基本分才能发动。这张卡从墓地特殊召唤。那之后，对方可以从自身的手卡·墓地选1只怪兽特殊召唤。
function c55787576.initial_effect(c)
	-- ①：这张卡只要在怪兽区域存在，不受从额外卡组特殊召唤的怪兽发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c55787576.immval)
	c:RegisterEffect(e1)
	-- ②：和这张卡相同纵列的自己的「星遗物」卡不会成为对方的效果的对象，不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c55787576.tgtg)
	-- 设置不受对方效果破坏的过滤函数
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置不能成为对方效果对象的过滤函数
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡在墓地存在的场合，自己·对方的准备阶段支付1000基本分才能发动。这张卡从墓地特殊召唤。那之后，对方可以从自身的手卡·墓地选1只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(55787576,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,55787576)
	e4:SetCost(c55787576.spcost)
	e4:SetTarget(c55787576.sptg)
	e4:SetOperation(c55787576.spop)
	c:RegisterEffect(e4)
end
-- 免疫效果过滤函数：判断效果是否为从额外卡组特殊召唤的怪兽在怪兽区域发动的效果
function c55787576.immval(e,te)
	local tc=te:GetOwner()
	return tc~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
		and te:GetActivateLocation()==LOCATION_MZONE and tc:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果适用对象过滤：自身，或者与自身在相同纵列的自己的「星遗物」卡
function c55787576.tgtg(e,c)
	return e:GetHandler()==c or (c:IsSetCard(0xfe) and e:GetHandler():GetColumnGroup():IsContains(c))
end
-- 效果发动代价：检查并支付1000基本分
function c55787576.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果发动目标：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c55787576.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动阶段检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 对方特殊召唤怪兽的过滤函数：检查怪兽是否能特殊召唤
function c55787576.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：将自身特殊召唤，之后对方可以选择是否从手卡或墓地选1只怪兽特殊召唤
function c55787576.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其特殊召唤，并判断是否特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取对方手卡和墓地中不受王家长眠之谷影响且可以特殊召唤的怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c55787576.spfilter),1-tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,1-tp)
		-- 检查对方场上是否有空余的怪兽区域
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			-- 检查对方是否有可特殊召唤的怪兽，并询问对方是否进行特殊召唤
			and g:GetCount()>0 and Duel.SelectYesNo(1-tp,aux.Stringid(55787576,1)) then  --"是否从手卡·墓地选1只怪兽特殊召唤？"
			-- 中断当前效果，使之后的效果处理与之前不视为同时处理
			Duel.BreakEffect()
			-- 给对方玩家发送选择特殊召唤卡片的提示信息
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(1-tp,1,1,nil)
			-- 将对方选择的怪兽特殊召唤到对方场上
			Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
