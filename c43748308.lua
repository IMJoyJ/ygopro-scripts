--微炎星－リュウシシン
-- 效果：
-- 1回合1次，自己把名字带有「炎舞」的魔法·陷阱卡发动的场合，可以从卡组选1张名字带有「炎舞」的陷阱卡在自己场上盖放。此外，1回合1次，把自己场上表侧表示存在的2张名字带有「炎舞」的魔法·陷阱卡送去墓地才能发动。从自己墓地选择「微炎星-龙史进」以外的1只名字带有「炎星」的怪兽特殊召唤。
function c43748308.initial_effect(c)
	-- 1回合1次，自己把名字带有「炎舞」的魔法·陷阱卡发动的场合，可以从卡组选1张名字带有「炎舞」的陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43748308,0))  --"盖放"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c43748308.setcon)
	e2:SetTarget(c43748308.settg)
	e2:SetOperation(c43748308.setop)
	c:RegisterEffect(e2)
	-- 此外，1回合1次，把自己场上表侧表示存在的2张名字带有「炎舞」的魔法·陷阱卡送去墓地才能发动。从自己墓地选择「微炎星-龙史进」以外的1只名字带有「炎星」的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43748308,1))  --"特殊召唤"
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c43748308.spcost)
	e3:SetTarget(c43748308.sptg)
	e3:SetOperation(c43748308.spop)
	c:RegisterEffect(e3)
end
-- 效果发动时，满足条件：对方玩家为当前玩家、效果为发动类型、效果对象为魔法或陷阱卡、效果对象为炎舞系列
function c43748308.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and re:GetHandler():IsSetCard(0x7c)
end
-- 过滤函数，返回满足条件的卡：为炎舞系列、为陷阱卡、可以盖放
function c43748308.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果处理时，满足条件：当前卡未处于连锁中、玩家场上存在空置魔陷区、卡组存在满足条件的陷阱卡
function c43748308.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 当前卡未处于连锁中
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 玩家场上存在空置魔陷区且卡组存在满足条件的陷阱卡
		and Duel.IsExistingMatchingCard(c43748308.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理时，若玩家场上不存在空置魔陷区则返回，否则提示选择要盖放的卡并选择1张满足条件的陷阱卡，然后将该卡盖放
function c43748308.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 若玩家场上不存在空置魔陷区则返回
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择1张满足条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,c43748308.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将该卡盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 过滤函数，返回满足条件的卡：表侧表示、为炎舞系列、为魔法或陷阱卡、可以送去墓地作为费用
function c43748308.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 效果处理时，满足条件：玩家场上存在至少2张满足条件的卡或玩家受到效果46241344影响
function c43748308.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 玩家场上存在至少2张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c43748308.cfilter,tp,LOCATION_ONFIELD,0,2,nil)
		-- 玩家受到效果46241344影响
		or Duel.IsPlayerAffectedByEffect(tp,46241344) end
	-- 玩家场上存在至少2张满足条件的卡
	if Duel.IsExistingMatchingCard(c43748308.cfilter,tp,LOCATION_ONFIELD,0,2,nil)
		-- 若玩家场上存在至少2张满足条件的卡且未受到效果46241344影响或玩家选择不把卡送去墓地发动
		and (not Duel.IsPlayerAffectedByEffect(tp,46241344) or not Duel.SelectYesNo(tp,aux.Stringid(46241344,0))) then  --"是否不把卡送去墓地发动？"
		-- 提示选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择2张满足条件的卡
		local g=Duel.SelectMatchingCard(tp,c43748308.cfilter,tp,LOCATION_ONFIELD,0,2,2,nil)
		-- 将该卡送去墓地作为费用
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- 过滤函数，返回满足条件的卡：为炎星系列、不是微炎星-龙史进、可以特殊召唤
function c43748308.spfilter(c,e,tp)
	return c:IsSetCard(0x79) and not c:IsCode(43748308) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时，满足条件：玩家场上存在空置怪兽区、墓地存在满足条件的怪兽
function c43748308.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c43748308.spfilter(chkc,e,tp) end
	-- 玩家场上存在空置怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 墓地存在满足条件的怪兽
		and Duel.IsExistingTarget(c43748308.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1张满足条件的怪兽
	local g=Duel.SelectTarget(tp,c43748308.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时，获取目标怪兽并判断其是否与效果相关，若相关则特殊召唤该怪兽
function c43748308.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 特殊召唤该怪兽
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
