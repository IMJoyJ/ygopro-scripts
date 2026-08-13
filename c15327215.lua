--六武衆の真影
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己对「影六武众」怪兽的召唤·特殊召唤成功时才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，从自己墓地把1只4星以下的「六武众」怪兽除外才能发动。直到回合结束时，这张卡的属性·等级·攻击力·守备力变成和除外的那只怪兽相同。
function c15327215.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己对「影六武众」怪兽的召唤·特殊召唤成功时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15327215,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,15327215)
	e1:SetCondition(c15327215.spcon)
	e1:SetTarget(c15327215.sptg)
	e1:SetOperation(c15327215.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，从自己墓地把1只4星以下的「六武众」怪兽除外才能发动。直到回合结束时，这张卡的属性·等级·攻击力·守备力变成和除外的那只怪兽相同。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15327215,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c15327215.cost)
	e3:SetOperation(c15327215.operation)
	c:RegisterEffect(e3)
end
-- 判断召唤·特殊召唤成功的怪兽是否满足①效果的触发条件：表侧表示、由自己召唤·特殊召唤成功、且属于「影六武众」（0x903d）系列。
function c15327215.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsSetCard(0x903d)
end
-- ①效果的发动条件：本次召唤·特殊召唤成功的怪兽组中，存在至少1只由自己召唤·特殊召唤成功的表侧表示「影六武众」怪兽。
function c15327215.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15327215.cfilter,1,nil,tp)
end
-- ①效果的发动时点检查：己方主要怪兽区有空位，且这张卡自身可以被特殊召唤（满足苏生限制/召唤条件）。
function c15327215.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上主要怪兽区是否有空格，确保可以从手卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将进行特殊召唤，目标为这张卡本身，数量1；用于连锁时让其他卡（如星尘龙）能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：取得效果持有者，若该卡仍与此效果关联，则将其从手卡特殊召唤。
function c15327215.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到己方场上（通常召唤/特殊召唤限制检查，要求可特殊召唤）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选墓地中可作为②效果cost的「六武众」怪兽：4星以下、属于「六武众」（0x103d）、可作为cost除外；且不能与这张卡当前的等级·属性·攻击力·守备力完全相同（否则发动没有意义）。
function c15327215.filter(c,mc)
	return c:IsLevelBelow(4) and c:IsSetCard(0x103d) and c:IsAbleToRemoveAsCost()
		and not (c:IsLevel(mc:GetLevel()) and c:IsAttribute(mc:GetAttribute()) and c:IsAttack(mc:GetAttack()) and c:IsDefense(mc:GetDefense()))
end
-- ②效果的cost处理：检查墓地是否存在符合条件的「六武众」怪兽；若有则提示玩家选择要除外的卡，从自己墓地选择1张符合条件的怪兽，表侧表示除外作为cost，并把该怪兽存入效果的LabelObject，供效果处理时使用。
function c15327215.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果cost的检查阶段：确认自己墓地是否存在至少1张满足c15327215.filter的卡（4星以下「六武众」、可作为cost除外、与这张卡当前数值不完全相同）可作为发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c15327215.filter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	-- 向发动玩家弹出选择提示，提示内容为“请选择要除外的卡”（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足c15327215.filter的怪兽卡，作为②效果cost除外的对象（取1张）。
	local g=Duel.SelectMatchingCard(tp,c15327215.filter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	-- 将选中的墓地怪兽以表侧表示除外，作为②效果的发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- ②效果处理：取得cost除外的怪兽tc；若这张卡仍与效果关联且表侧表示，则分别将等级、属性、攻击力、守备力变为tc的对应数值，并设置这些变更在结束阶段或离场等时机重置。
function c15327215.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local lv=tc:GetLevel()
		local att=tc:GetAttribute()
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- ②：直到回合结束时，这张卡的属性·等级·攻击力·守备力变成和除外的那只怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(att)
		c:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(atk)
		c:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e4:SetValue(def)
		c:RegisterEffect(e4)
	end
end
