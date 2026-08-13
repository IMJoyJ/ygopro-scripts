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
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的状态，自己场上有龙族·暗属性同调怪兽同调召唤的场合才能发动。这张卡加入手卡。
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
-- 定义筛选条件：怪兽须表侧表示、是同调怪兽且等级在8星以上。
function c5376159.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsLevelAbove(8)
end
-- ①效果的发动条件检测：自己场上是否存在至少1只满足cfilter（表侧表示、8星以上同调怪兽）的怪兽。
function c5376159.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体检查：以tp方视角，从自己场上（LOCATION_MZONE，对方位置0）检索是否存在至少1张满足cfilter的卡。
	return Duel.IsExistingMatchingCard(c5376159.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义筛选条件：怪兽为表侧表示且等级在1星以上，用于选取有等级概念的怪兽。
function c5376159.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- ①效果发动时的目标处理：获取双方场上所有表侧且等级1以上的怪兽，若无则不能发动；再取其中等级最高的一组，排除该组后剩余怪兽作为可能除外的对象，并在确认发动时设置除外操作信息。
function c5376159.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上所有表侧表示且等级1以上的怪兽集合。
	local g=Duel.GetMatchingGroup(c5376159.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()<=0 then return false end
	local tg=g:GetMaxGroup(Card.GetLevel)
	-- 获取除最高等级怪兽组（tg）以外、双方场上的全部怪兽（不做除外能力过滤）。
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,tg)
	local rg=mg:Filter(Card.IsAbleToRemove,nil)
	-- 在无检查（chk==0）时，确认场上至少存在1只可被选择的表侧等级1以上怪兽，且后续也有可除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c5376159.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and rg:GetCount()>0 end
	-- 设置连锁操作信息：本次将除外rg中的卡，数量为rg的数量，供后续检测和发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,rg:GetCount(),0,0)
end
-- ①效果处理：重新选取场上表侧等级1以上的怪兽，找出最高等级并将其他怪兽全部除外；随后给双方场上所有表侧表示怪兽赋予直到回合结束时不受自身以外的卡的效果影响的免疫效果。
function c5376159.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取双方场上所有表侧表示且等级1以上的怪兽集合。
	local g=Duel.GetMatchingGroup(c5376159.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetLevel)
	-- 效果处理时获取除当前最高等级怪兽组以外的所有场上怪兽。
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,tg)
	local rg=mg:Filter(Card.IsAbleToRemove,nil)
	if rg:GetCount()>0 then
		-- 将选定的怪兽组rg以表侧表示形式除外，除外原因为效果。
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
	-- 获取双方场上所有表侧表示怪兽，用于后续赋予免疫效果。
	g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 场上的全部表侧表示怪兽直到回合结束时不受自身以外的卡的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c5376159.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 免疫效果的判定条件：当效果来源卡（re:GetOwner()）不是被保护怪兽自身（e:GetHandler()）时，该效果无效，即只免疫自身以外的卡的效果。
function c5376159.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
-- ②效果的触发怪兽条件：怪兽须为表侧表示、龙族、暗属性、同调怪兽，且是通过同调召唤出场，控制者为效果发动者tp。
function c5376159.thfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsControler(tp)
end
-- ②效果发动条件：在特殊召唤成功的事件组eg中，存在至少1只满足thfilter的怪兽，即自己场上有龙族暗属性同调怪兽被同调召唤。
function c5376159.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5376159.thfilter,1,nil,tp)
end
-- ②效果的发动目标处理：仅在墓地中的这张卡能够加入手卡时允许发动，并设置回手牌的操作信息。
function c5376159.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁操作信息：本次将把墓地中的这张卡加入手卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：获取这张卡，若它仍与当前效果相关联（未被无效或移动），则将其加入手卡。
function c5376159.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡返回其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
