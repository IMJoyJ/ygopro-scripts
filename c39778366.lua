--スクランブル・ユニオン
-- 效果：
-- 「同盟紧急出动」在1回合只能发动1张。
-- ①：以除外的自己的机械族·光属性的最多3只通常怪兽或者同盟怪兽为对象才能发动。那些怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以除外的自己的机械族·光属性的1只通常怪兽或者同盟怪兽为对象才能发动。那只怪兽回到手卡。这个效果在这张卡送去墓地的回合不能发动。
function c39778366.initial_effect(c)
	-- 「同盟紧急出动」在1回合只能发动1张。①：以除外的自己的机械族·光属性的最多3只通常怪兽或者同盟怪兽为对象才能发动。那些怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,39778366+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c39778366.target)
	e1:SetOperation(c39778366.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以除外的自己的机械族·光属性的1只通常怪兽或者同盟怪兽为对象才能发动。那只怪兽回到手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置e2的发动条件为：这张卡送去墓地的回合不能发动（即非该回合且非因规则回手等特殊情况，使用aux.exccon判定）。
	e2:SetCondition(aux.exccon)
	-- 设置e2的发动代价为：除外墓地的这张卡（从墓地除外作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c39778366.thtg)
	e2:SetOperation(c39778366.thop)
	c:RegisterEffect(e2)
end
c39778366.has_text_type=TYPE_UNION
-- 筛选可特殊召唤的对象：表侧表示、机械族、光属性、通常怪兽或同盟怪兽，且能够被当前效果特殊召唤。
function c39778366.filter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsType(TYPE_NORMAL+TYPE_UNION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象判定与发动合法性判定：若为取对象阶段，确认对象在除外区且为自己控制并满足filter；若为发动判定，确认自己主要怪兽区有空格且除外区存在至少1个符合条件的对象。
function c39778366.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c39778366.filter(chkc,e,tp) end
	-- 发动判定的第一个条件：自己场上主要怪兽区必须存在空格，才能有特殊召唤的位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动判定的第二个条件：除外区存在至少1只满足filter（机械族·光属性且为通常怪兽/同盟怪兽）且可成为对象的卡。
		and Duel.IsExistingTarget(c39778366.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 取得自己主要怪兽区的可用空格数量，作为本次最多可特殊召唤的怪兽数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>3 then ft=3 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 显示选择提示，提示玩家从满足条件的卡中选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1至ft张满足条件的除外区自己的机械族·光属性通常怪兽或同盟怪兽作为对象，并记录为连锁对象。
	local g=Duel.SelectTarget(tp,c39778366.filter,tp,LOCATION_REMOVED,0,1,ft,nil,e,tp)
	-- 设置操作信息：本连锁将特殊召唤所选择的对象卡，数量为g:GetCount()，供其他卡/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 执行①效果的特殊召唤处理：重新检查对象与可用区域；若对象不存在、或对象多于1只且青眼精灵龙效果适用中，则不处理；若对象数不超可用空格则全部特殊召唤，否则由玩家选择等于可用空格数的对象特殊召唤，剩余对象按规则送去墓地。
function c39778366.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取自己主要怪兽区当前可用空格数，用于判断实际特召数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取发动时选择的对象卡组，并过滤出仍与本效果存在联系的对象（即仍合法存在于除外区且未被重置联系）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()<=ft then
		-- 当对象数量不超过可用空格时，将全部对象以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 当对象数量超过可用空格时，弹出选择提示，让玩家选择实际要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将玩家选择的部分对象以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
		-- 将因场地不足而未被特殊召唤的对象卡按规则送去墓地（不是效果破坏）。
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
-- 筛选可回手卡的对象：表侧表示、机械族、光属性、通常怪兽或同盟怪兽，并且能够加入手卡（不受‘不能加入手卡’效果影响）。
function c39778366.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
	and c:IsType(TYPE_NORMAL+TYPE_UNION) and c:IsAbleToHand()
end
-- ②的取对象/发动判定：取对象时要求对象是除外区自己控制的符合条件的卡；发动判定时确认存在至少1个对象；随后选择1只并设置回手操作信息。
function c39778366.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c39778366.thfilter(chkc) end
	-- 发动合法性检查：确认除外区存在至少1只满足thfilter（机械族·光属性通常/同盟怪兽且可加入手卡）的自己的卡。
	if chk==0 then return Duel.IsExistingTarget(c39778366.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 显示选择提示，提示玩家从满足条件的卡中选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张满足条件的除外区自己的机械族·光属性通常怪兽或同盟怪兽作为对象。
	local g=Duel.SelectTarget(tp,c39778366.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：本连锁将对象卡加入手卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行②效果：将对象怪兽回到持有者手卡，并向对方玩家确认该卡。
function c39778366.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象卡（唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果处理的方式送回持有者的手卡（回到手卡）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示这张回到手卡的卡，以确认效果处理的结果。
		Duel.ConfirmCards(1-tp,tc)
	end
end
