--怨念の邪悪霊
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把魔法·陷阱·怪兽的效果发动时，把手卡·场上的这张卡送去墓地，以自己墓地1只恶魔族·8星怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：这张卡在墓地存在，恶魔族·8星怪兽被送去自己墓地的场合才能发动。这张卡加入手卡。
function c87988305.initial_effect(c)
	-- ①：对方把魔法·陷阱·怪兽的效果发动时，把手卡·场上的这张卡送去墓地，以自己墓地1只恶魔族·8星怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87988305,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,87988305)
	e1:SetCondition(c87988305.condition)
	e1:SetCost(c87988305.cost)
	e1:SetTarget(c87988305.target)
	e1:SetOperation(c87988305.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，恶魔族·8星怪兽被送去自己墓地的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87988305,1))  --"这张卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,87988306)
	e2:SetCondition(c87988305.thcon)
	e2:SetTarget(c87988305.thtg)
	e2:SetOperation(c87988305.thop)
	c:RegisterEffect(e2)
end
-- 判定发动条件：对方发动魔法、陷阱、怪兽的效果，且此卡未被战斗破坏。
function c87988305.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 判定并执行发动代价：将手卡或场上的这张卡送去墓地。
function c87988305.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为代价送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤自己墓地中可以特殊召唤的8星恶魔族怪兽。
function c87988305.spfilter(c,e,tp)
	return c:IsLevel(8) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判定并选择自己墓地1只8星恶魔族怪兽作为特殊召唤的对象。
function c87988305.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c87988305.spfilter(chkc,e,tp) end
	-- 判定自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在符合条件的特殊召唤对象。
		and Duel.IsExistingTarget(c87988305.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只8星恶魔族怪兽作为特殊召唤的对象并设为效果对象。
	local g=Duel.SelectTarget(tp,c87988305.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果处理：将选择的墓地怪兽特殊召唤，并将其效果无效化。
function c87988305.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍符合效果，并将其以表侧表示特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的后续处理。
	Duel.SpecialSummonComplete()
end
-- 过滤送去自己墓地的8星恶魔族怪兽。
function c87988305.cfilter(c,tp)
	return c:IsLevel(8) and c:IsRace(RACE_FIEND) and c:IsControler(tp)
end
-- 判定发动条件：这张卡在墓地存在，且有其他8星恶魔族怪兽送去自己墓地。
function c87988305.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c87988305.cfilter,1,nil,tp)
end
-- 判定并设置将此卡加入手卡的效果目标。
function c87988305.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行效果处理：将墓地的这张卡加入手卡。
function c87988305.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
