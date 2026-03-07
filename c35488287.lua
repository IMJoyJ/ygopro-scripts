--寿炎星－リシュンマオ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己把「炎舞」魔法·陷阱卡发动的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从自己墓地选「寿炎星-李熊猫」以外的1只「炎星」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「炎星」怪兽不能特殊召唤。
-- ②：自己场上的「炎星」怪兽被对方的效果破坏的场合，可以作为代替把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地。
function c35488287.initial_effect(c)
	-- 效果原文内容：①：自己把「炎舞」魔法·陷阱卡发动的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从自己墓地选「寿炎星-李熊猫」以外的1只「炎星」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「炎星」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35488287,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,35488287)
	e1:SetCondition(c35488287.spcon)
	e1:SetTarget(c35488287.sptg)
	e1:SetOperation(c35488287.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：自己场上的「炎星」怪兽被对方的效果破坏的场合，可以作为代替把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,35488289)
	e2:SetTarget(c35488287.desreptg)
	e2:SetValue(c35488287.desrepval)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断是否为己方发动魔法或陷阱卡的场合
function c35488287.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(0x7c)
end
-- 规则层面作用：设置特殊召唤的卡为自身，用于后续处理
function c35488287.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面作用：设置连锁操作信息，表明将要特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面作用：定义墓地特殊召唤的过滤条件，排除自身并限定为炎星族
function c35488287.spfilter(c,e,tp)
	return c:IsSetCard(0x79) and not c:IsCode(35488287) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：执行特殊召唤流程，包括从手牌特殊召唤自身并可能从墓地特殊召唤炎星怪兽
function c35488287.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面作用：检查自身是否能被特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 规则层面作用：获取满足条件的墓地炎星怪兽组
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c35488287.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 规则层面作用：判断是否选择从墓地特殊召唤炎星怪兽
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(35488287,1)) then  --"是否从墓地把「炎星」怪兽特殊召唤？"
			-- 规则层面作用：中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 规则层面作用：提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 规则层面作用：将选择的炎星怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 效果原文内容：这个效果的发动后，直到回合结束时自己不是「炎星」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c35488287.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面作用：注册一个持续到回合结束的永续效果，禁止非炎星怪兽特殊召唤
	Duel.RegisterEffect(e1,tp)
end
-- 规则层面作用：定义禁止特殊召唤的条件，即非炎星族怪兽不能特殊召唤
function c35488287.splimit(e,c)
	return not c:IsSetCard(0x79)
end
-- 规则层面作用：定义代替破坏的过滤条件，即己方场上表侧表示的炎星族怪兽
function c35488287.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x79) and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 规则层面作用：定义可被送去墓地的「炎舞」魔法·陷阱卡的过滤条件
function c35488287.tgfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) and not c:IsImmuneToEffect(e)
end
-- 规则层面作用：判断是否满足代替破坏的条件，即己方炎星怪兽被对方效果破坏且场上有炎舞卡
function c35488287.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return rp==1-tp and eg:IsExists(c35488287.repfilter,1,nil,tp)
		-- 规则层面作用：检查场上是否存在可被代替破坏的炎舞卡
		and Duel.IsExistingMatchingCard(c35488287.tgfilter,tp,LOCATION_ONFIELD,0,1,nil,e) end
	-- 规则层面作用：询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 规则层面作用：提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 规则层面作用：选择一张符合条件的炎舞卡
		local g=Duel.SelectMatchingCard(tp,c35488287.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e)
		-- 规则层面作用：将选择的炎舞卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
-- 规则层面作用：返回代替破坏效果的判断结果，确认是否为炎星族怪兽
function c35488287.desrepval(e,c)
	return c35488287.repfilter(c,e:GetHandlerPlayer())
end
