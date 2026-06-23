--氷水のエジル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「冰水」魔法·陷阱卡加入手卡。
-- ②：场上的这张卡成为对方的效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。从自己的手卡·墓地把「冰水之霓石精」以外的1只水属性怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。这个回合，这张卡只有1次不会被战斗·效果破坏。
function c39354437.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「冰水」魔法·陷阱卡加入手卡。
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
	-- ②：场上的这张卡成为对方的效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。从自己的手卡·墓地把「冰水之霓石精」以外的1只水属性怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。这个回合，这张卡只有1次不会被战斗·效果破坏。
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
-- 检索满足条件的「冰水」魔法·陷阱卡
function c39354437.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x16c) and c:IsAbleToHand()
end
-- 设置效果处理时要检索的卡组中的「冰水」魔法·陷阱卡
function c39354437.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「冰水」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c39354437.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要检索的卡组中的「冰水」魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索并加入手牌的操作
function c39354437.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「冰水」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c39354437.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否为对方怪兽攻击对象时发动
function c39354437.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方怪兽攻击对象时发动
	return eg:IsContains(e:GetHandler()) and Duel.GetAttacker():IsControler(1-tp)
end
-- 判断是否为对方效果的对象时发动
function c39354437.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler()) and rp==1-tp
end
-- 筛选满足条件的水属性怪兽
function c39354437.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and not c:IsCode(39354437) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时要特殊召唤的水属性怪兽
function c39354437.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在满足条件的水属性怪兽
		and Duel.IsExistingMatchingCard(c39354437.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的水属性怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行特殊召唤并设置结束阶段返回手牌的效果
function c39354437.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 设置此卡在本回合内不会被战斗·效果破坏的效果
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
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39354437.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的水属性怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(39354437,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 设置结束阶段将特殊召唤的怪兽送回手牌的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c39354437.tdcon)
		e1:SetOperation(c39354437.tdop)
		-- 注册结束阶段将特殊召唤的怪兽送回手牌的效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否为特殊召唤的怪兽并设置返回手牌
function c39354437.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(39354437)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 将特殊召唤的怪兽送回手牌
function c39354437.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将特殊召唤的怪兽送回手牌
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- 设置此卡不会被战斗·效果破坏的条件
function c39354437.indct(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
