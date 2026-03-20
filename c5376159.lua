--スカーレッド・レイン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有8星以上的同调怪兽存在的场合才能发动。场上的怪兽之内除等级最高的怪兽以外的怪兽全部除外。场上的全部表侧表示怪兽直到回合结束时不受自身以外的卡的效果影响。
-- ②：这张卡在墓地存在的状态，自己场上有龙族·暗属性同调怪兽同调召唤的场合才能发动。这张卡加入手卡。
function c5376159.initial_effect(c)
	-- ①：自己场上有8星以上的同调怪兽存在的场合才能发动。场上的怪兽之内除等级最高的怪兽以外的怪兽全部除外。场上的全部表侧表示怪兽直到回合结束时不受自身以外的卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5376159,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c5376159.condition)
	e1:SetTarget(c5376159.target)
	e1:SetOperation(c5376159.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上有龙族·暗属性同调怪兽同调召唤的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5376159,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,5376159)
	e2:SetCondition(c5376159.thcon)
	e2:SetTarget(c5376159.thtg)
	e2:SetOperation(c5376159.thop)
	c:RegisterEffect(e2)
end
-- 用于判断场上的同调怪兽是否等级8以上
function c5376159.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsLevelAbove(8)
end
-- 判断自己场上是否存在8星以上的同调怪兽
function c5376159.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的同调怪兽组
	return Duel.IsExistingMatchingCard(c5376159.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 用于过滤场上的表侧表示怪兽
function c5376159.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 设置效果发动时的处理目标和条件
function c5376159.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(c5376159.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()<=0 then return false end
	local tg=g:GetMaxGroup(Card.GetLevel)
	-- 获取除等级最高怪兽外的所有怪兽
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,tg)
	local rg=mg:Filter(Card.IsAbleToRemove,nil)
	-- 判断是否满足发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(c5376159.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and rg:GetCount()>0 end
	-- 设置除外效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,rg:GetCount(),0,0)
end
-- 执行效果的处理操作
function c5376159.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(c5376159.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetLevel)
	-- 获取除等级最高怪兽外的所有怪兽
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,tg)
	local rg=mg:Filter(Card.IsAbleToRemove,nil)
	if rg:GetCount()>0 then
		-- 将目标怪兽除外
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
	-- 获取场上所有表侧表示怪兽
	g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使目标怪兽获得效果免疫
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c5376159.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 设置效果免疫的判断条件
function c5376159.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
-- 用于判断是否为龙族·暗属性同调怪兽
function c5376159.thfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsControler(tp)
end
-- 判断是否满足②效果发动条件
function c5376159.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5376159.thfilter,1,nil,tp)
end
-- 设置效果发动时的处理目标和条件
function c5376159.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置回手牌效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行效果的处理操作
function c5376159.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
