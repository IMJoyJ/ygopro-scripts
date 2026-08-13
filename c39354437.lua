--氷水のエジル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「冰水」魔法·陷阱卡加入手卡。
-- ②：场上的这张卡成为对方的效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。从自己的手卡·墓地把「冰水之霓石精」以外的1只水属性怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。这个回合，这张卡只有1次不会被战斗·效果破坏。
function c39354437.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「冰水」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,39354437)
	e1:SetTarget(c39354437.thtg)
	e1:SetOperation(c39354437.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：场上的这张卡成为对方的效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。从自己的手卡·墓地把「冰水之霓石精」以外的1只水属性怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。这个回合，这张卡只有1次不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,39354438)
	e3:SetCondition(c39354437.spcon1)
	e3:SetTarget(c39354437.sptg)
	e3:SetOperation(c39354437.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_BECOME_TARGET)
	e4:SetCondition(c39354437.spcon2)
	c:RegisterEffect(e4)
end
-- 过滤条件：从卡组中筛选「冰水」魔法·陷阱卡，且该卡能够加入手卡。
function c39354437.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x16c) and c:IsAbleToHand()
end
-- 设定①效果的发动条件和操作信息：卡组存在符合条件的卡时才能发动，并预告将1张卡加入手卡。
function c39354437.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 仅发动时检查：卡组中是否存在至少1张符合条件的「冰水」魔法·陷阱卡，以此决定效果可否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c39354437.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 为当前连锁设置操作信息，标记本效果将把1张卡从卡组加入手卡，供后续时点或连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行①效果：从卡组选1张「冰水」魔法·陷阱卡加入手卡，并向对方展示。
function c39354437.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求操控者选择1张要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 在发动时已确认存在的前提下，从卡组实际选出1张满足thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c39354437.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入持有者的手卡，原因为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认被加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- e3效果的发动条件：这张卡被对方怪兽选择为攻击对象且攻击怪兽由对方控制时才能发动。
function c39354437.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击对象中包含这张卡，并且攻击者是对方怪兽。
	return eg:IsContains(e:GetHandler()) and Duel.GetAttacker():IsControler(1-tp)
end
-- e4效果的发动条件：这张卡成为对方发动的效果的对象时才能发动（rp==1-tp表示效果来自对方）。
function c39354437.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler()) and rp==1-tp
end
-- 特殊召唤的筛选条件：水属性、不是「冰水之霓石精」本卡、且在当前效果下可以进行特殊召唤。
function c39354437.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and not c:IsCode(39354437) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件：自己主要怪兽区有空位，且手卡·墓地存在符合条件的怪兽时才能发动；同时设置特殊召唤的操作信息。
function c39354437.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区域，若没有空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在至少1只满足spfilter条件的水属性怪兽。
		and Duel.IsExistingMatchingCard(c39354437.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 为当前连锁设置操作信息，标记本效果将把1只怪兽从手卡·墓地特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行②效果：先给这张卡附加1次不会被战斗·效果破坏的抗性；再选1只符合条件的怪兽特殊召唤，并注册结束阶段回手的效果。
function c39354437.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡只有1次不会被战斗·效果破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetValue(c39354437.indct)
		c:RegisterEffect(e2)
	end
	-- 特殊召唤处理前再次确认自己场上仍有可用的主要怪兽区；若无空位则终止特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求操控者选择1只要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只满足spfilter且不受王家长眠之谷影响的怪兽（NecroValleyFilter用于排除墓地效果被无效的情况）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39354437.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 以表侧表示将选中的怪兽特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(39354437,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c39354437.tdcon)
		e1:SetOperation(c39354437.tdop)
		-- 将结束阶段使怪兽回手的效果注册到全场持续效果中，使其在结束阶段自动执行。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 回手效果的触发判定：若被特殊召唤的怪兽仍在自己场上且带有对应标记，则在结束阶段返回手卡；若已离场则取消该效果。
function c39354437.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(39354437)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段回手处理：将特殊召唤的怪兽送回持有者手卡。
function c39354437.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将怪兽返回持有者手卡，原因为效果处理。
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- 抗性判定函数：当这张卡将要被战斗或效果破坏时，返回真以消耗1次不会被破坏的次数，从而无效那次破坏。
function c39354437.indct(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
