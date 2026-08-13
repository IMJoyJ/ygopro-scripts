--アルティメット・インセクト LV3
-- 效果：
-- 「究极昆虫 LV1」的效果特殊召唤的场合，只要这张卡在场上存在，对方全部怪兽的攻击力下降300。自己回合的准备阶段时，可以把表侧表示的这张卡送去墓地，从卡组·手卡特殊召唤1只「究极昆虫 LV5」。（召唤·特殊召唤·反转的回合不能使用此效果）
function c34088136.initial_effect(c)
	-- 对应效果原文：『「究极昆虫 LV1」的效果特殊召唤的场合，只要这张卡在场上存在，对方全部怪兽的攻击力下降300。』
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c34088136.con)
	e1:SetValue(-300)
	c:RegisterEffect(e1)
	-- 对应效果原文：『自己回合的准备阶段时，可以把表侧表示的这张卡送去墓地，从卡组·手卡特殊召唤1只「究极昆虫 LV5」。（召唤·特殊召唤·反转的回合不能使用此效果）』
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34088136,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c34088136.spcon)
	e2:SetCost(c34088136.spcost)
	e2:SetTarget(c34088136.sptg)
	e2:SetOperation(c34088136.spop)
	c:RegisterEffect(e2)
	-- 对应效果原文：『（召唤·特殊召唤·反转的回合不能使用此效果）』
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(c34088136.regop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
c34088136.lvup={49441499,34830502}
c34088136.lvdn={49441499}
-- e1降攻效果的适用条件：判定此卡是否是以「究极昆虫 LV1」的效果特殊召唤的场合（召唤类型为特殊召唤且带有LV特殊标记），满足时对方场上全部怪兽攻击力下降300。
function c34088136.con(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_LV
end
-- 通常召唤成功时，为这张卡注册标识效果（flag 34088137），标记本回合进行过通常召唤；该标识在回合结束时重置。
function c34088136.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(34088137,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
-- e2升级效果的发动条件：必须是自己回合的准备阶段，且此卡本回合未进行过召唤·特殊召唤·反转（flag 34088137为0）。
function c34088136.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回两个条件同时成立：当前是此卡控制者的回合，且没有“已进行过召唤/特殊召唤/反转”的标记。
	return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(34088137)==0
end
-- 升级效果的代价判定与支付：chk==0时检查此卡能否作为代价送去墓地；支付时实际将自身送去墓地。
function c34088136.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡片以代价（REASON_COST）原因送去墓地，完成代价支付。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选特殊召唤对象：必须为「究极昆虫 LV5」（卡号34830502），且能被此效果特殊召唤（跳过召唤条件和苏生限制）。
function c34088136.spfilter(c,e,tp)
	return c:IsCode(34830502) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 升级效果发动时检查：自己场上是否有可用怪兽区域，且手卡·卡组中存在至少1只符合条件的「究极昆虫 LV5」。
function c34088136.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时确认自己场上是否有怪兽区域空格（> -1为兼容额外怪兽区等情况的宽松判断）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 确认手卡·卡组中存在至少1只满足spfilter的「究极昆虫 LV5」。
		and Duel.IsExistingMatchingCard(c34088136.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本次效果将进行一次从手卡·卡组的特殊召唤（数量1），供其他卡效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 升级效果处理：若有空位则让玩家从手卡·卡组选择1只「究极昆虫 LV5」，以表侧表示特殊召唤到自己场上，并触发其特殊召唤成功后的处理。
function c34088136.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际处理时再次检查自己场上是否有空位，没有空位则终止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己的手卡·卡组中精确选择1张满足条件（即「究极昆虫 LV5」且可特殊召唤）的卡。
	local g=Duel.SelectMatchingCard(tp,c34088136.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的「究极昆虫 LV5」以表侧表示特殊召唤到自己场上，并标记为LV怪兽的特殊召唤；此处跳过召唤条件和苏生限制。
		Duel.SpecialSummon(tc,SUMMON_VALUE_LV,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
