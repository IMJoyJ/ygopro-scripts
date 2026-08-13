--サイバーダーク・インフェルノ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：有装备卡装备的自己场上的「电子暗黑」效果怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：以自己场上1只「电子暗黑」怪兽为对象才能发动。那只怪兽回到持有者手卡，那之后可以把1只「电子暗黑」怪兽召唤。
-- ③：场上的这张卡被对方的效果破坏的场合才能发动。从卡组把1张「融合」魔法卡加入手卡。
function c44352516.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：有装备卡装备的自己场上的「电子暗黑」效果怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c44352516.indestg)
	-- 设置不被对方效果破坏的判定函数：当效果发起者为对方时，受保护怪兽不会被效果破坏。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置不会成为效果对象的判定函数：当效果发起者为对方时，受保护怪兽不能成为对方的效果的对象。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己场上1只「电子暗黑」怪兽为对象才能发动。那只怪兽回到持有者手卡，那之后可以把1只「电子暗黑」怪兽召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,44352516)
	e4:SetTarget(c44352516.target)
	e4:SetOperation(c44352516.operation)
	c:RegisterEffect(e4)
	-- ③：场上的这张卡被对方的效果破坏的场合才能发动。从卡组把1张「融合」魔法卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(c44352516.thcon)
	e5:SetTarget(c44352516.thtg)
	e5:SetOperation(c44352516.thop)
	c:RegisterEffect(e5)
end
-- 筛选条件：是「电子暗黑」效果怪兽且装备有装备卡，作为①效果的保护对象。
function c44352516.indestg(e,c)
	return c:IsSetCard(0x4093) and c:IsType(TYPE_EFFECT) and c:GetEquipCount()>0
end
-- 筛选满足②效果回手条件的卡：表侧表示的「电子暗黑」怪兽且能被加入手卡。
function c44352516.filter(c)
	return c:IsSetCard(0x4093) and c:IsFaceup() and c:IsAbleToHand()
end
-- 筛选可作为②效果后通常召唤的「电子暗黑」怪兽：满足当前通常召唤条件。
function c44352516.filter2(c)
	return c:IsSetCard(0x4093) and c:IsSummonable(true,nil)
end
-- ②效果的发动条件与对象选择：从自己场上选择1只符合条件的「电子暗黑」怪兽作为对象，并设置回手牌的处理信息。
function c44352516.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c44352516.filter(chkc) end
	-- 检查能否发动：自己场上是否存在至少1只可作为对象的「电子暗黑」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c44352516.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己场上选择1只符合条件的「电子暗黑」怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c44352516.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次效果包含把对象卡返回手牌，目标为已选择的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：对象怪兽返回手牌；若返回成功，可选把1只「电子暗黑」怪兽通常召唤（不占通召次数）。
function c44352516.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联且成功返回手牌，才可进行后续召唤处理。
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取手牌或场上所有可通常召唤的「电子暗黑」怪兽候选。
		local g=Duel.GetMatchingGroup(c44352516.filter2,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		-- 若存在可召唤的「电子暗黑」怪兽且玩家确认要召唤，则继续。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(44352516,0)) then  --"是否把「电子暗黑」怪兽召唤？"
			-- 中断当前效果，使后续召唤作为独立处理发生，避免造成时点问题。
			Duel.BreakEffect()
			-- 提示玩家选择要召唤的「电子暗黑」怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			local sg=g:Select(tp,1,1,nil):GetFirst()
			-- 将选择的怪兽作通常召唤，且不占用每回合通常召唤次数。
			Duel.Summon(tp,sg,true,nil)
		end
	end
end
-- ③效果发动条件：场上的这张卡被对方的效果破坏（破坏原因含效果破坏）且破坏前由自己控制。
function c44352516.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and bit.band(r,0x41)==0x41
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选条件：卡组中「融合」魔法卡且可以被加入手卡。
function c44352516.thfilter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ③效果的目标判定：检查卡组是否有「融合」魔法卡，并设置加入手卡的操作信息。
function c44352516.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张「融合」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c44352516.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组检索1张「融合」魔法卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选1张「融合」魔法卡加入手卡，并向对方展示。
function c44352516.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的「融合」魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「融合」魔法卡。
	local g=Duel.SelectMatchingCard(tp,c44352516.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「融合」魔法卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
