--神光の龍
-- 效果：
-- 「裁决之龙」＋「惩戒之龙」
-- 从自己的场上以及墓地各把1只上记的卡除外的场合才能特殊召唤。
-- ①：自己·对方回合1次，支付2000基本分才能发动。这张卡以外的双方的场上·墓地的卡全部除外。
-- ②：自己结束阶段发动。从自己卡组上面把4张卡送去墓地。
-- ③：这张卡被对方破坏的场合才能发动。自己的除外状态的「裁决之龙」「惩戒之龙」各1只加入手卡。那之后，可以把那2只无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 初始化神光之龙的效果：启用苏生限制、声明素材卡名，并依次注册特殊召唤限制、特殊召唤手续、①除外效果、②结束阶段堆墓效果、③被破坏时回收并特殊召唤效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为神光之龙登记素材卡名：「裁决之龙」(57774843)和「惩戒之龙」(19959563)，供特殊召唤手续识别素材。
	aux.AddMaterialCodeList(c,19959563,57774843)
	-- 从自己的场上以及墓地各把1只上记的卡除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件设为恒不成立，使这张卡不能被其他效果特殊召唤，只能通过自身的特殊召唤手续（e2）进行特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 「裁决之龙」＋「惩戒之龙」从自己的场上以及墓地各把1只上记的卡除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ①：自己·对方回合1次，支付2000基本分才能发动。这张卡以外的双方的场上·墓地的卡全部除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"场上·墓地的卡全部除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(s.recost)
	e3:SetTarget(s.retg)
	e3:SetOperation(s.reop)
	c:RegisterEffect(e3)
	-- ②：自己结束阶段发动。从自己卡组上面把4张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"从卡组送去墓地"
	e4:SetCategory(CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.tgcon)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
	-- ③：这张卡被对方破坏的场合才能发动。自己的除外状态的「裁决之龙」「惩戒之龙」各1只加入手卡。那之后，可以把那2只无视召唤条件特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"回收"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(s.thcon)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
-- 过滤函数：检查卡片是否为「裁决之龙」(57774843)或「惩戒之龙」(19959563)，且可以作为代价除外。
function s.fusfilter(c)
	return c:IsCode(19959563,57774843) and c:IsAbleToRemoveAsCost()
end
-- 素材组校验函数：要求所选2张素材卡名种类为2（即「裁决之龙」和「惩戒之龙」各1），除外素材后额外怪兽区有空位，且2张素材分别来自场上和墓地。
function s.fselect(g,tp,sc)
	-- 检查素材组卡名种类数为2，并且除外这些素材后额外卡组怪兽仍有可特殊召唤的空位。
	return g:GetClassCount(Card.GetCode)==2 and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
		and g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
end
-- 特殊召唤手续的条件函数：若c为空则允许；否则获取自己场上·墓地可用素材，验证是否存在满足条件的2张素材组合。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上和墓地中所有可作为素材的「裁决之龙」「惩戒之龙」卡组。
	local g=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return g:CheckSubGroup(s.fselect,2,2,tp,c)
end
-- 特殊召唤手续的素材选择：从候选素材中选出2张满足条件（场上1张+墓地1张、且卡名不同）的卡，保存选择结果并允许特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上和墓地中可作为素材的「裁决之龙」「惩戒之龙」卡组。
	local g=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 显示提示信息，让玩家选择要除外的素材卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,true,2,2,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤执行：从效果标签取出选中的素材组，将其设为该卡的特殊召唤素材，并除外这些素材。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	c:SetMaterial(sg)
	-- 将选中的素材卡表侧表示除外，作为特殊召唤的代价（REASON_COST）。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	sg:DeleteGroup()
end
-- ①效果的代价函数：检查并支付2000基本分作为发动代价。
function s.recost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己可以支付2000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 实际支付2000基本分。
	Duel.PayLPCost(tp,2000)
end
-- ①效果的发动目标函数：确认场上或墓地存在本卡以外可除外的卡，并收集这些卡用于操作信息。
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 目标检查：判断是否存在至少1张“这张卡以外”的、双方场上·墓地的可除外卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,c) end
	-- 收集“这张卡以外”的双方场上·墓地的所有可除外卡。
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,c)
	-- 设置操作信息：声明本次除外涉及的卡组和数量，供连锁和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,sg:GetCount(),0,0)
end
-- ①效果处理：将“这张卡以外”的双方场上·墓地的所有卡表侧除外。
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得“这张卡以外”的双方场上·墓地的可除外卡（aux.ExceptThisCard用于排除本卡）。
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,aux.ExceptThisCard(e))
	-- 将取到的所有卡表侧除外，作为效果处理（REASON_EFFECT）。
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
-- ②效果的发动条件：仅当自己回合的结束阶段时满足。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，确保只在己方结束阶段才发动。
	return tp==Duel.GetTurnPlayer()
end
-- ②效果的发动确认：无条件允许发动，并设置从卡组上方将4张卡送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从己方卡组上方将4张卡送去墓地（CATEGORY_DECKDES）。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,4)
end
-- ②效果处理：从己方卡组上方将4张卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行从己方卡组上方丢弃4张卡到墓地。
	Duel.DiscardDeck(tp,4,REASON_EFFECT)
end
-- ③效果的发动条件：这张卡被对方破坏，且破坏前控制者为自己。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤「惩戒之龙」（19959563）：要求除外区的该卡表侧表示且可加入手卡，同时还需存在可加入手卡的「裁决之龙」以凑成一对。
function s.thfilter1(c,tp)
	return c:IsFaceup() and c:IsCode(19959563) and c:IsAbleToHand()
		-- 确认除外区还另外存在1只符合条件的「裁决之龙」（57774843），以保证能回收两只不同名的卡。
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_REMOVED,0,1,c)
end
-- 过滤「裁决之龙」（57774843）：要求除外区的该卡表侧表示且可加入手卡。
function s.thfilter2(c)
	return c:IsFaceup() and c:IsCode(57774843) and c:IsAbleToHand()
end
-- ③效果的发动目标：确认除外区存在「惩戒之龙」和「裁决之龙」各1只可加入手卡，并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查：检查除外区是否存在一组符合条件的「惩戒之龙」和「裁决之龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：将除外区的2张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,0,LOCATION_REMOVED)
end
-- 特殊召唤判定函数：检查手牌中的卡是否可被无视召唤条件特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_HAND) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ③效果处理：从除外区选择「惩戒之龙」「裁决之龙」各1只加入手卡；若两张都成功加入手卡且玩家选择特殊召唤，则检查额外怪兽区空位及「青眼精灵龙」限制后，将那2只怪兽无视召唤条件特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示提示信息，让玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从除外区选择1张「惩戒之龙」（s.thfilter1）加入手卡。
	local g1=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_REMOVED,0,1,1,nil,tp)
	if #g1==0 then return end
	-- 显示提示信息，让玩家选择要加入手卡的卡（第二张）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从除外区选择1张「裁决之龙」（s.thfilter2）加入手卡，并排除已选的第一张。
	local g2=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_REMOVED,0,1,1,g1,tp)
	g1:Merge(g2)
	-- 将选择的两张卡加入手卡；若实际成功加入手卡的数量为2（两张都加入），则继续执行后续特殊召唤。
	if Duel.SendtoHand(g1,nil,REASON_EFFECT)==2 then
		-- 取得刚才因效果实际加入手卡的卡组（即「惩戒之龙」和「裁决之龙」各1只）。
		local tg=Duel.GetOperatedGroup()
		if tg:FilterCount(s.spfilter,nil,e,tp)==2
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 询问玩家是否要无视召唤条件将那2只怪兽特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否无视条件特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤作为独立处理，避免与加入手卡共享时点。
			Duel.BreakEffect()
			-- 遍历被特殊召唤的两只怪兽卡。
			for tc in aux.Next(tg) do
				-- 逐只将怪兽以表侧表示、无视召唤条件（nocheck=true）进行特殊召唤（特殊召唤步骤）。
				Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
			end
			-- 完成所有特殊召唤步骤，实际将两只怪兽特殊召唤到场上。
			Duel.SpecialSummonComplete()
		end
	end
end
