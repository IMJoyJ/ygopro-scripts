--アームド・ドラゴン LV3
-- 效果：
-- ①：自己准备阶段，把场上的这张卡送去墓地才能发动。从手卡·卡组把1只「武装龙 LV5」特殊召唤。
function c980973.initial_effect(c)
	-- ①：自己准备阶段，把场上的这张卡送去墓地才能发动。从手卡·卡组把1只「武装龙 LV5」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(980973,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCondition(c980973.spcon)
	e1:SetCost(c980973.spcost)
	e1:SetTarget(c980973.sptg)
	e1:SetOperation(c980973.spop)
	c:RegisterEffect(e1)
end
c980973.lvup={46384672}
-- 定义效果发动条件函数
function c980973.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 定义效果发动代价函数
function c980973.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤手卡或卡组中可以无视召唤条件特殊召唤的「武装龙 LV5」
function c980973.spfilter(c,e,tp)
	return c:IsCode(46384672) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 定义效果发动目标函数
function c980973.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有可用的怪兽区域（因自身作为代价送墓，故可用区域数需大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组是否存在至少1只满足特殊召唤条件的「武装龙 LV5」
		and Duel.IsExistingMatchingCard(c980973.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理的操作信息为从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义效果处理函数
function c980973.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，若自己场上没有可用的怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的「武装龙 LV5」
	local g=Duel.SelectMatchingCard(tp,c980973.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示无视召唤条件特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
