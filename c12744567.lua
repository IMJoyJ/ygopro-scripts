--CNo.101 S・H・Dark Knight
-- 效果：
-- 5星怪兽×3
-- ①：1回合1次，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽在这张卡下面重叠作为超量素材。
-- ②：持有超量素材的这张卡被破坏送去墓地时才能发动。这张卡特殊召唤。那之后，自己基本分回复这张卡的原本攻击力的数值。这个效果特殊召唤的这张卡在这个回合不能攻击。这个效果在自己墓地有「No.101 寂静荣誉方舟骑士」存在的场合才能发动和处理。
function c12744567.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用等级5的任意怪兽3只叠放进行超量召唤。
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽在这张卡下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12744567,0))  --"吸收素材"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c12744567.target)
	e1:SetOperation(c12744567.operation)
	c:RegisterEffect(e1)
	-- ②：持有超量素材的这张卡被破坏送去墓地时才能发动。这张卡特殊召唤。那之后，自己基本分回复这张卡的原本攻击力的数值。这个效果特殊召唤的这张卡在这个回合不能攻击。这个效果在自己墓地有「No.101 寂静荣誉方舟骑士」存在的场合才能发动和处理。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12744567,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c12744567.spcon)
	e2:SetTarget(c12744567.sptg)
	e2:SetOperation(c12744567.spop)
	c:RegisterEffect(e2)
end
-- 将这张卡的No.号码设定为101，用于「No.」相关效果和规则判定。
aux.xyz_number[12744567]=101
-- 定义对象筛选条件：对方场上的特殊召唤怪兽，且可以作为超量素材叠放在超量怪兽下方。
function c12744567.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsCanOverlay()
end
-- 效果发动的取对象处理：选择对方场上1只满足条件的特殊召唤怪兽作为对象；若没有可选对象则不能发动。
function c12744567.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c12744567.filter(chkc) end
	-- 发动合法性检查：这张卡是超量怪兽，且对方场上存在1只符合条件的特殊召唤怪兽。
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.IsExistingTarget(c12744567.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，告知玩家需要选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让玩家从对方场上选择1只符合条件的特殊召唤怪兽，将其登记为效果对象。
	Duel.SelectTarget(tp,c12744567.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：获得选择的对象，若双方仍与效果相关且对象可被叠放，则将对象重叠在这张卡下方作为超量素材；若对象自身有超量素材，则先将那些素材按规则送去墓地。
function c12744567.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and not tc:IsImmuneToEffect(e) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 把对象怪兽自身持有的超量素材按规则送去墓地。
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将选择的对象怪兽作为超量素材，叠放在这张卡下方。
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- ②效果的发动条件：这张卡被破坏并送去墓地，且离场前在场上持有超量素材；同时自己墓地存在「No.101 寂静荣誉方舟骑士」。
function c12744567.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousOverlayCountOnField()>0
		-- 检查自己墓地是否存在卡号为48739166的「No.101 寂静荣誉方舟骑士」。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,48739166)
end
-- ②效果的发动目标判定：自己场上有可用的主要怪兽区空格，且这张卡可以被特殊召唤；随后设置特殊召唤与回复LP的操作信息。
function c12744567.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格，用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁将把这张卡特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	local rec=e:GetHandler():GetBaseAttack()
	-- 记录回复LP的目标玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 记录回复LP的数值为这张卡的原本攻击力。
	Duel.SetTargetParam(rec)
	-- 设置操作信息：本次连锁将让自己回复LP，回复量为原本攻击力数值。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- ②效果处理：处理时再次确认墓地存在「No.101」；若存在则特殊召唤这张卡，成功后赋予其当回合不能攻击的效果，并回复LP。
function c12744567.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己墓地是否存在「No.101 寂静荣誉方舟骑士」，若不存在则效果不处理（符合“才能发动和处理”）。
	if not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,48739166) then return end
	local c=e:GetHandler()
	-- 若这张卡仍与效果关联，且以表侧表示特殊召唤成功，则继续后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡在这个回合不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 中断当前效果处理，使后续的LP回复视为另一组效果处理，以正确触发时点。
		Duel.BreakEffect()
		-- 获取之前记录的目标玩家和回复参数（回复对象与回复数值）。
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 让目标玩家回复对应数值的基本分。
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
