--影霊の翼 ウェンディ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合才能发动。从卡组把「影灵之翼 文蒂」以外的1只「影依」怪兽表侧守备表示或里侧守备表示特殊召唤。
-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把「影灵之翼 文蒂」以外的1只「影依」怪兽里侧守备表示特殊召唤。
function c51023024.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡反转的场合才能发动。从卡组把「影灵之翼 文蒂」以外的1只「影依」怪兽表侧守备表示或里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51023024,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,51023024)
	e1:SetTarget(c51023024.target)
	e1:SetOperation(c51023024.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把「影灵之翼 文蒂」以外的1只「影依」怪兽里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51023024,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,51023024)
	e2:SetCondition(c51023024.spcon)
	e2:SetTarget(c51023024.sptg)
	e2:SetOperation(c51023024.spop)
	c:RegisterEffect(e2)
	c51023024.shadoll_flip_effect=e1
end
-- 筛选卡组中符合「影依」（0x9d）字段、卡名不是「影灵之翼 文蒂」且可以以守备表示（POS_DEFENSE）特殊召唤的怪兽，作为①效果的可选对象。
function c51023024.filter(c,e,tp)
	return c:IsSetCard(0x9d) and not c:IsCode(51023024) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- ①效果的发动条件判定：检查己方主要怪兽区是否有空位，且卡组存在满足filter条件的「影依」怪兽；双方条件满足时才允许发动。
function c51023024.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ①效果发动时，先确认己方场上主要怪兽区还有可用的空格（数量>0），否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- ①效果发动时，还需从卡组中检索是否存在至少1张满足filter条件（「影依」字段、非「文蒂」、可守备表示特殊召唤）的怪兽；两者皆满足才返回true。
		and Duel.IsExistingMatchingCard(c51023024.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设定本次连锁操作信息为：从卡组特殊召唤1只怪兽（CATEGORY_SPECIAL_SUMMON），供后续效果处理以及星尘龙等卡片的发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：若己方主要怪兽区仍有空格，提示玩家从卡组选择1张满足filter的「影依」怪兽（非「文蒂」），以守备表示特殊召唤；若该卡以里侧表示出场，则向对方公开确认。
function c51023024.operation(e,tp,eg,ep,ev,re,r,rp)
	-- ①效果处理时再次确认己方主要怪兽区是否有空格，若无空格则中断处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家发送选择提示消息，内容为“请选择要特殊召唤的卡”，以引导玩家从卡组进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选出1张满足filter条件的「影依」怪兽（非「文蒂」）作为特殊召唤对象。
	local tc=Duel.SelectMatchingCard(tp,c51023024.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	-- 将选择的怪兽以守备表示（POS_DEFENSE）特殊召唤到己方主要怪兽区；若召唤成功且该卡为里侧表示，则继续执行给对方确认的步骤。
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 and tc:IsFacedown() then
		-- 将里侧表示特殊召唤的怪兽展示给对方玩家确认，使对方能够获知该怪兽的具体信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- ②效果的发动条件：这张卡是由于效果（REASON_EFFECT）被送去墓地时才满足发动条件。
function c51023024.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 筛选卡组中符合「影依」（0x9d）字段、卡名不是「影灵之翼 文蒂」且可以以里侧守备表示（POS_FACEDOWN_DEFENSE）特殊召唤的怪兽，作为②效果的可选对象。
function c51023024.spfilter(c,e,tp)
	return c:IsSetCard(0x9d) and not c:IsCode(51023024) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- ②效果的发动条件判定：检查己方主要怪兽区是否有空位，且卡组存在满足spfilter条件的「影依」怪兽；双方条件满足时才允许发动。
function c51023024.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果发动时，先确认己方场上主要怪兽区还有可用的空格（数量>0），否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- ②效果发动时，还需从卡组中检索是否存在至少1张满足spfilter条件（「影依」字段、非「文蒂」、可里侧守备表示特殊召唤）的怪兽；两者皆满足才返回true。
		and Duel.IsExistingMatchingCard(c51023024.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设定本次连锁操作信息为：从卡组特殊召唤1只怪兽（CATEGORY_SPECIAL_SUMMON），用于后续效果处理及相关卡片的连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若己方主要怪兽区仍有空格，提示玩家从卡组选择1张满足spfilter的「影依」怪兽（非「文蒂」），以里侧守备表示特殊召唤，并当场向对方公开确认该卡。
function c51023024.spop(e,tp,eg,ep,ev,re,r,rp)
	-- ②效果处理时再次确认己方主要怪兽区是否有空格，若无空格则中断处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家发送选择提示消息，提示内容为“请选择要特殊召唤的卡”，用于卡组选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选出1张满足spfilter条件的「影依」怪兽（非「文蒂」）作为里侧守备特殊召唤的对象。
	local tc=Duel.SelectMatchingCard(tp,c51023024.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选择的怪兽以里侧守备表示（POS_FACEDOWN_DEFENSE）特殊召唤到己方主要怪兽区，不检查苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 将里侧守备表示特殊召唤的怪兽展示给对方玩家确认，以便对方记录该怪兽信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
