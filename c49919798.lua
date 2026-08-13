--音響戦士サイザス
-- 效果：
-- ①：这张卡反转的场合才能发动。从卡组把「音响战士 合成器」以外的1只「音响战士」怪兽加入手卡。
-- ②：1回合1次，以「音响战士 合成器」以外的自己的场上·墓地1只「音响战士」怪兽为对象才能发动。这张卡直到结束阶段当作和那只怪兽同名卡使用，得到相同效果。
-- ③：把墓地的这张卡除外，以「音响战士 合成器」以外的除外的1只自己的「音响战士」怪兽为对象才能发动。那只怪兽特殊召唤。
function c49919798.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从卡组把「音响战士 合成器」以外的1只「音响战士」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49919798,0))  --"复制效果结束"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c49919798.thtg)
	e1:SetOperation(c49919798.thop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以「音响战士 合成器」以外的自己的场上·墓地1只「音响战士」怪兽为对象才能发动。这张卡直到结束阶段当作和那只怪兽同名卡使用，得到相同效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49919798,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c49919798.cpcost)
	e2:SetTarget(c49919798.cptg)
	e2:SetOperation(c49919798.cpop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外，以「音响战士 合成器」以外的除外的1只自己的「音响战士」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49919798,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果③的发动代价：把墓地的这张卡除外（由aux.bfgcost实现）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c49919798.sptg)
	e3:SetOperation(c49919798.spop)
	c:RegisterEffect(e3)
end
-- 检索过滤器：筛选卡组中「音响战士 合成器」以外的1只「音响战士」怪兽，且该怪兽可以被加入手卡。
function c49919798.thfilter(c)
	return c:IsSetCard(0x1066) and not c:IsCode(49919798) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动条件与操作信息设定：确认卡组存在符合条件的怪兽，并设定检索加入手卡的操作信息。
function c49919798.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）确认卡组中存在至少1只满足thfilter条件的「音响战士」怪兽，存在才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c49919798.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定效果处理时将1张卡从卡组加入手卡的操作信息，对象暂不确定，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理时：从卡组选择1只符合条件的「音响战士」怪兽加入手卡，并让对方确认。
function c49919798.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示文字，提示当前玩家从卡组选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1只满足thfilter条件的「音响战士」怪兽。
	local g=Duel.SelectMatchingCard(tp,c49919798.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入其持有者的手卡（nil表示由持有者收回手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片，以确认检索内容。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动代价：确认本卡本回合未使用过②效果（通过FlagEffect计数），并在发动时设置使用标记；该标记在结束阶段重置，配合SetCountLimit实现1回合1次限制。
function c49919798.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(49919798)==0 end
	e:GetHandler():RegisterFlagEffect(49919798,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 对象过滤器：筛选自己场上表侧表示或墓地的「音响战士」系列怪兽，且不是这张卡「音响战士 合成器」。
function c49919798.cpfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1066) and not c:IsCode(49919798)
end
-- 效果②的发动条件与取对象：检查存在可选择的「音响战士」怪兽，并让玩家选择1只符合条件的对象。
function c49919798.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c49919798.cpfilter(chkc) end
	-- 发动时确认场上或墓地存在至少1只满足cpfilter条件的「音响战士」怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c49919798.cpfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 显示选择对象的提示：请选择表侧表示的卡（这里用于场上表侧表示或墓地的对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只符合条件的「音响战士」怪兽，并将其设为效果对象（同时写入当前连锁的对象信息）。
	Duel.SelectTarget(tp,c49919798.cpfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
end
-- 效果②处理时：若本卡仍在场上表侧表示且对象仍有效，则使本卡直到结束阶段卡名变为对象怪兽的卡名，并复制对象怪兽的效果。
function c49919798.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果②选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and (not tc:IsLocation(LOCATION_MZONE) or tc:IsFaceup()) then
		local code=tc:GetCode()
		-- 这张卡直到结束阶段当作和那只怪兽同名卡使用，得到相同效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		c:RegisterEffect(e1)
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	end
end
-- 特殊召唤过滤器：筛选除外区自己的「音响战士」系列怪兽（不是本卡），且该怪兽可以被特殊召唤。
function c49919798.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1066) and not c:IsCode(49919798) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动条件与取对象：确认自己主要怪兽区有空位且除外区存在符合条件的「音响战士」怪兽，然后让玩家选择对象。
function c49919798.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c49919798.spfilter(chkc,e,tp) end
	-- 发动时确认自己主要怪兽区有空闲格子可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认除外区存在至少1只满足spfilter条件的「音响战士」怪兽可作为对象。
		and Duel.IsExistingTarget(c49919798.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从除外区选择1只符合条件的「音响战士」怪兽作为效果对象，并设为当前连锁对象。
	local g=Duel.SelectTarget(tp,c49919798.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设定操作信息：本次效果将把对象怪兽特殊召唤，对象为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③处理时：若对象仍与效果相关，则将对象怪兽特殊召唤到自己的场上。
function c49919798.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果③选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上（正常检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
