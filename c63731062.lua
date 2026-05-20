--白闘気一角
-- 效果：
-- 水属性调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤成功时，以自己墓地1只鱼族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
-- ②：这张卡被对方破坏送去墓地的场合，把这张卡以外的自己墓地1只水属性怪兽除外才能发动。这张卡当作调整使用特殊召唤。
function c63731062.initial_effect(c)
	-- 设置同调召唤手续：水属性调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功时，以自己墓地1只鱼族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63731062,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,63731062)
	e1:SetCondition(c63731062.spcon1)
	e1:SetTarget(c63731062.sptg1)
	e1:SetOperation(c63731062.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏送去墓地的场合，把这张卡以外的自己墓地1只水属性怪兽除外才能发动。这张卡当作调整使用特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63731062,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c63731062.spcon2)
	e2:SetCost(c63731062.spcost2)
	e2:SetTarget(c63731062.sptg2)
	e2:SetOperation(c63731062.spop2)
	c:RegisterEffect(e2)
end
c63731062.treat_itself_tuner=true
-- 效果①的发动条件判定：这张卡同调召唤成功
function c63731062.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤自己墓地中可以特殊召唤的鱼族怪兽
function c63731062.spfilter(c,e,tp)
	return c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查怪兽区域空位及墓地是否存在合法的鱼族怪兽
function c63731062.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c63731062.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的鱼族怪兽
		and Duel.IsExistingTarget(c63731062.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只鱼族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c63731062.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤分类的操作信息，包含选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将作为对象的怪兽特殊召唤，并使其在本回合不能攻击
function c63731062.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选中的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关，则将其在自己场上表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果②的发动条件判定：这张卡被对方破坏并送去墓地
function c63731062.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤自己墓地中除这张卡以外、可以作为Cost除外的水属性怪兽
function c63731062.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价处理：将自己墓地1只水属性怪兽除外
function c63731062.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在除这张卡以外的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c63731062.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只除这张卡以外的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c63731062.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的水属性怪兽表侧表示除外作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备：检查怪兽区域空位及自身是否能特殊召唤
function c63731062.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤分类的操作信息，包含自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将自身特殊召唤，并使其当作调整使用
function c63731062.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自身仍与效果相关，则尝试将其表侧表示特殊召唤（分步处理）
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这张卡当作调整使用特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	-- 完成分步特殊召唤的处理
	Duel.SpecialSummonComplete()
end
