--クリムゾン・ブレード・ドラゴン
-- 效果：
-- 「共鸣者」调整＋调整以外的怪兽1只以上
-- 这个卡名在规则上当作「深红剑士」使用。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己的卡组·墓地选1只8星以上的不能通常召唤的怪兽加入手卡或效果无效特殊召唤。
-- ②：这张卡和5星以上的怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册同调召唤手续与苏生限制，并注册①的检索/特殊召唤效果和②的战斗破坏效果。
function s.initial_effect(c)
	-- 设置同调召唤素材为「共鸣者」调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x57),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡同调召唤的场合才能发动。从自己的卡组·墓地选1只8星以上的不能通常召唤的怪兽加入手卡或效果无效特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡和5星以上的怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：确认这张卡为同调召唤成功（召唤类型为SUMMON_TYPE_SYNCHRO）。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 定义符合条件的怪兽：须为8星以上且不能通常召唤的怪兽，并且能够加入手牌，或在有怪兽区空格时能够特殊召唤。
function s.thfilter(c,e,tp)
	if c:IsSummonableCard() or not c:IsType(TYPE_MONSTER) or not c:IsLevelAbove(8) then return false end
	-- 获取我方主要怪兽区的可用空格数，用于判断是否能特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ①效果的目标判定：检查卡组·墓地是否存在至少1张满足s.thfilter的怪兽，作为效果发动的必要条件。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）检查我方卡组·墓地是否存在至少1张满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
end
-- 执行①效果：选择1张符合条件的怪兽，由玩家选择加入手卡或效果无效特殊召唤；若选特召，则以表侧表示将其特殊召唤并附加效果无效化。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择卡片的提示消息（操作卡选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组·墓地选择1张满足条件的怪兽，并排除受王家长眠之谷影响无法从墓地移动的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 获取我方主要怪兽区可用空格数，用于判断当前是否能特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		local spf=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0
		-- 判断该卡是否适合加入手卡：当它可加入手卡，且（不能特召或玩家在选项中选择加入手卡）时，进入加入手卡分支。
		if tc:IsAbleToHand() and (not spf or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的卡以效果原因加入持有者手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家确认被加入手卡的卡片。
			Duel.ConfirmCards(1-tp,tc)
		-- 否则若该卡可特殊召唤且有空格，则通过SpecialSummonStep开始以表侧表示进行特殊召唤（保留召唤条件与苏生限制检查）。
		elseif spf and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 对应①中“效果无效特殊召唤”的“效果无效”：使该怪兽效果无效（EFFECT_DISABLE）。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 对应①中“效果无效特殊召唤”的“效果无效”：使其效果无效化（EFFECT_DISABLE_EFFECT）。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 完成特殊召唤流程，将先前由SpecialSummonStep准备的怪兽正式特殊召唤上场。
			Duel.SpecialSummonComplete()
		end
	end
end
-- ②效果的目标判定：这只怪兽与对方5星以上表侧表示怪兽进行战斗的伤害步骤开始时，以那只战斗对象为对象并设置破坏信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsFaceup() and tc:IsLevelAbove(5) and tc:IsControler(1-tp) end
	-- 设置操作信息：预定将战斗对象怪兽以效果破坏1张。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 执行②效果：若战斗对象怪兽仍与本次战斗相关，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc and tc:IsRelateToBattle() then
		-- 以效果原因破坏战斗对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
