--抹殺の邪悪霊
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽攻击的伤害步骤开始时，把自己的手卡·场上的这张卡送去墓地，以自己墓地1只恶魔族·8星怪兽为对象才能发动。那只怪兽效果无效特殊召唤，攻击对象转移为那只怪兽进行伤害计算。
-- ②：这张卡在墓地存在，恶魔族·8星怪兽被送去自己墓地的场合才能发动。这张卡加入手卡。
function c51993760.initial_effect(c)
	-- ①：对方怪兽攻击的伤害步骤开始时，把自己的手卡·场上的这张卡送去墓地，以自己墓地1只恶魔族·8星怪兽为对象才能发动。那只怪兽效果无效特殊召唤，攻击对象转移为那只怪兽进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51993760,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,51993760)
	e1:SetCondition(c51993760.condition)
	e1:SetCost(c51993760.cost)
	e1:SetTarget(c51993760.target)
	e1:SetOperation(c51993760.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，恶魔族·8星怪兽被送去自己墓地的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51993760,1))  --"这张卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,51993761)
	e2:SetCondition(c51993760.thcon)
	e2:SetTarget(c51993760.thtg)
	e2:SetOperation(c51993760.thop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：仅在对方怪兽进行攻击时，且满足攻击怪兽控制者为对方时才可发动。
function c51993760.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前攻击怪兽的控制者是否为对方玩家（1-tp），若是则条件成立。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 发动代价处理：把效果持有者（这张卡）从手卡或场上送去墓地作为代价，同时确认其可以作为代价送入墓地。
function c51993760.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡以代价理由（REASON_COST）送入墓地，完成发动代价支付。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 特殊召唤对象的过滤条件：等级为8、种族为恶魔族，且能够被当前效果特殊召唤。
function c51993760.spfilter(c,e,tp)
	return c:IsLevel(8) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时选择对象：需要自己主要怪兽区有空格，且墓地存在符合条件的恶魔族8星怪兽；若选择对象则验证对象在墓地且归属自己、符合条件。
function c51993760.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51993760.spfilter(chkc,e,tp) end
	-- 检测自己场上是否有可用的主要怪兽区空格，若没有空格则不能发动特殊召唤效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检测自己墓地是否存在至少1只满足条件的恶魔族·8星怪兽可作为效果对象。
		and Duel.IsExistingTarget(c51993760.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择特殊召唤对象的提示文字（“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的恶魔族·8星怪兽，并将其设为当前效果的对象。
	local g=Duel.SelectTarget(tp,c51993760.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次效果操作信息：将进行特殊召唤，对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将对象怪兽特殊召唤，使其效果无效，并把攻击对象转移为那只怪兽进行伤害计算。
function c51993760.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关，则将其表侧表示特殊召唤（作为特殊召唤处理的一步），成功后才继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽效果无效（无效怪兽自身的效果）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽效果无效（使其效果无效化的状态持续）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 结束特殊召唤处理，完成特殊召唤。
		Duel.SpecialSummonComplete()
		-- 取得当前战斗中的攻击怪兽。
		local a=Duel.GetAttacker()
		if a:IsAttackable() and not a:IsImmuneToEffect(e) then
			-- 令攻击怪兽与特殊召唤的怪兽进行伤害计算，实现攻击对象转移并造成战斗伤害。
			Duel.CalculateDamage(a,tc)
		end
	end
end
-- ②效果涉及的送入墓地怪兽的过滤条件：等级为8、种族为恶魔族，且控制者为己方。
function c51993760.cfilter(c,tp)
	return c:IsLevel(8) and c:IsRace(RACE_FIEND) and c:IsControler(tp)
end
-- ②效果发动条件：被送去墓地的卡中不包含这张卡自身，且其中有恶魔族·8星怪兽被送入自己墓地。
function c51993760.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c51993760.cfilter,1,nil,tp)
end
-- ②效果发动时确认这张卡可以加入手卡，并登记回手卡的操作信息。
function c51993760.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 登记本次效果处理分类为“加入手卡”，对象为墓地中的这张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若此卡仍与效果相关，则将其加入持有者手卡。
function c51993760.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以效果理由送回持有者手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
