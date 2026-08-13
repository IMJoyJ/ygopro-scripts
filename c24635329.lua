--聖なる影 ケイウス
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合才能发动。从手卡把1只「影依」怪兽表侧守备表示或者里侧守备表示特殊召唤。
-- ②：这张卡被效果送去墓地的场合才能发动。从手卡把1只「影依」怪兽送去墓地。这个回合中，以下效果适用。
-- ●自己场上的怪兽的攻击力·守备力上升这个效果送去墓地的怪兽的原本等级×100。
function c24635329.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡反转的场合才能发动。从手卡把1只「影依」怪兽表侧守备表示或者里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24635329,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,24635329)
	e1:SetTarget(c24635329.target)
	e1:SetOperation(c24635329.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡被效果送去墓地的场合才能发动。从手卡把1只「影依」怪兽送去墓地。这个回合中，以下效果适用。●自己场上的怪兽的攻击力·守备力上升这个效果送去墓地的怪兽的原本等级×100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24635329,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,24635329)
	e2:SetCondition(c24635329.tgcon)
	e2:SetTarget(c24635329.tgtg)
	e2:SetOperation(c24635329.tgop)
	c:RegisterEffect(e2)
	c24635329.shadoll_flip_effect=e1
end
-- 过滤函数：判断手卡中的卡是否为「影依」怪兽且能够以守备表示特殊召唤，作为①效果特殊召唤的候选对象。
function c24635329.filter(c,e,tp)
	return c:IsSetCard(0x9d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- ①效果的发动条件检查：确认自己主要怪兽区有空位，且手牌存在1只满足filter条件的「影依」怪兽，满足才可发动。
function c24635329.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检测中，检查自己主要怪兽区是否有可用空格（若有空位才继续）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 配合上一行条件，继续检查手牌是否存在至少1张满足filter条件的「影依」怪兽（有才能发动①）。
		and Duel.IsExistingMatchingCard(c24635329.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：声明本次效果将把手卡的1只怪兽特殊召唤（CATEGORY_SPECIAL_SUMMON），并指定来源为手牌。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：从手牌选择1只符合条件的「影依」怪兽，以守备表示特殊召唤（表侧或里侧均可）；若特殊召唤成功且该卡为里侧表示，则向对方玩家确认那张卡。
function c24635329.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区仍有可用空格，若无空位则本次特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示信息，用于选择卡片时的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1张满足filter的「影依」怪兽（特殊召唤对象），并取出选择的卡。
	local tc=Duel.SelectMatchingCard(tp,c24635329.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	-- 将所选怪兽以守备表示特殊召唤；若特殊召唤成功且该怪兽是里侧守备表示，则进入对方确认环节。
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 and tc:IsFacedown() then
		-- 向对方玩家确认这只里侧守备表示特殊召唤的怪兽，使对方可以查看其卡面信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- ②的发动条件：判断这张卡被送去墓地时，其送去墓地的原因是否为“效果”（REASON_EFFECT），是才能发动。
function c24635329.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数：判断手卡中的卡是否为「影依」字段的怪兽卡，并且能够被效果送去墓地，作为②效果送去墓地的对象。
function c24635329.tgfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ②效果的发动条件与操作信息设置：先确认手牌有1只符合条件的「影依」怪兽，再设置本次操作将从手卡送去墓地1张卡。
function c24635329.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查手牌是否存在1张满足tgfilter条件的「影依」怪兽（有才能发动②）。
	if chk==0 then return Duel.IsExistingMatchingCard(c24635329.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：声明本次效果将从手卡把1张卡送去墓地（CATEGORY_TOGRAVE），供相关卡牌时点检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理：从手牌选择1只符合条件的「影依」怪兽送去墓地；若成功送去墓地，则在该回合内给自己场上全部怪兽附加攻击力·守备力上升（该怪兽原本等级×100）的持续效果。
function c24635329.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示“请选择要送去墓地的卡”的提示信息，用于选择卡片时的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌选择1张满足tgfilter的「影依」怪兽，作为②效果要送去墓地的卡。
	local tc=Duel.SelectMatchingCard(tp,c24635329.tgfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	-- 确认所选卡确实被效果成功送去墓地且现在位于墓地，才继续处理后续的攻击力·守备力上升效果。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		local lv=tc:GetOriginalLevel()
		-- ●自己场上的怪兽的攻击力·守备力上升这个效果送去墓地的怪兽的原本等级×100。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetValue(lv*100)
		e1:SetTargetRange(LOCATION_MZONE,0)
		-- 注册一个影响全场的攻击力增减效果：在本回合内，自己场上所有怪兽的攻击力上升（lv×100），结束阶段重置。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		-- 将同一数值的守备力增减效果注册到全场：在本回合内，自己场上所有怪兽的守备力也上升该数值，结束阶段重置。
		Duel.RegisterEffect(e2,tp)
	end
end
