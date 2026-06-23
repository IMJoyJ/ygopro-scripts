--CNo.101 S・H・Dark Knight
-- 效果：
-- 5星怪兽×3
-- ①：1回合1次，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽在这张卡下面重叠作为超量素材。
-- ②：持有超量素材的这张卡被破坏送去墓地时才能发动。这张卡特殊召唤。那之后，自己基本分回复这张卡的原本攻击力的数值。这个效果特殊召唤的这张卡在这个回合不能攻击。这个效果在自己墓地有「No.101 寂静荣誉方舟骑士」存在的场合才能发动和处理。
function c12744567.initial_effect(c)
	-- 为卡片添加等级为5、需要3只怪兽作为超量素材的超量召唤手续
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
-- 设置该卡的超量编号为101
aux.xyz_number[12744567]=101
-- 过滤函数，判断目标怪兽是否为特殊召唤且可以作为超量素材
function c12744567.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsCanOverlay()
end
-- 效果处理时的取对象阶段，用于选择目标怪兽
function c12744567.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c12744567.filter(chkc) end
	-- 判断是否满足发动条件：当前怪兽为超量怪兽且对方场上存在可作为超量素材的特殊召唤怪兽
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.IsExistingTarget(c12744567.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要作为超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	-- 选择对方场上一只特殊召唤的怪兽作为超量素材
	Duel.SelectTarget(tp,c12744567.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理阶段，执行将目标怪兽叠放至自身的效果
function c12744567.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and not tc:IsImmuneToEffect(e) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将目标怪兽身上的原有超量素材送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将目标怪兽叠放至自身作为超量素材
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- 判断该效果是否可以发动的条件函数
function c12744567.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousOverlayCountOnField()>0
		-- 检查自己墓地是否存在「No.101 寂静荣誉方舟骑士」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,48739166)
end
-- 设置特殊召唤效果的处理目标
function c12744567.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：自己场上存在空位且该卡可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的卡为当前处理的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	local rec=e:GetHandler():GetBaseAttack()
	-- 设置回复LP的玩家为当前处理效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置回复LP的数值为该卡的原本攻击力
	Duel.SetTargetParam(rec)
	-- 设置回复LP的效果分类
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 处理特殊召唤效果的函数
function c12744567.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在「No.101 寂静荣誉方舟骑士」
	if not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,48739166) then return end
	local c=e:GetHandler()
	-- 将该卡特殊召唤至场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 设置特殊召唤后的卡在本回合不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 获取连锁中设定的目标玩家和目标参数
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 使目标玩家回复指定数值的LP
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
