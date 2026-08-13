--スターダスト・シンクロン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把自己场上1只怪兽解放才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「星尘龙」的卡名记述的1张魔法·陷阱卡加入手卡。
function c37799519.initial_effect(c)
	-- 登记这张卡的效果文本中记载了「星尘龙」(44508094)这一卡名事实，以便后续用aux.IsCodeListed判断卡名记述。
	aux.AddCodeList(c,44508094)
	-- ①：这张卡在手卡·墓地存在的场合，把自己场上1只怪兽解放才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37799519,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,37799519)
	e1:SetCost(c37799519.spcost)
	e1:SetTarget(c37799519.sptg)
	e1:SetOperation(c37799519.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「星尘龙」的卡名记述的1张魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37799519,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,37799520)
	e2:SetTarget(c37799519.thtg)
	e2:SetOperation(c37799519.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 解放代价的选定与执行：获取可解放怪兽组，检查并选择1只能解放且解放后主怪兽区仍有空位的怪兽，之后将其作为代价解放。
function c37799519.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家场上可解放（非上级召唤用）的怪兽组，供选择解放代价使用。
	local g=Duel.GetReleaseGroup(tp)
	-- 发动合法性检查：从可解放怪兽组中确认是否存在1只怪兽，解放后主怪兽区仍留有空位且该怪兽可被解放。
	if chk==0 then return g:CheckSubGroup(aux.mzctcheckrel,1,1,tp) end
	-- 弹出选择提示，让玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家从可选怪兽中选出1只满足解放后仍有空位且可解放的怪兽，作为本次解放代价。
	local rg=g:SelectSubGroup(tp,aux.mzctcheckrel,false,1,1,tp)
	-- 若使用了类似暗影敌托邦的追加解放次数效果，则消耗其额外的解放次数。
	aux.UseExtraReleaseCount(rg,tp)
	-- 将选择的怪兽作为代价（REASON_COST）解放。
	Duel.Release(rg,REASON_COST)
end
-- 特殊召唤目标判定：确认这张卡可被特殊召唤，并设置特殊召唤的操作信息。
function c37799519.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理会将这张卡特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡特殊召唤；若成功则给它附加“从场上离开的场合除外”的效果；随后设置自肃，直到回合结束时自己不能从额外卡组特殊召唤非同步怪兽。
function c37799519.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 使用SpecialSummonStep尝试将这张卡以表侧攻击表示特殊召唤，并判断是否召唤成功。
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1)
		end
		-- 结束特殊召唤步骤，完成整个特殊召唤流程。
		Duel.SpecialSummonComplete()
	end
	-- 这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(c37799519.splimit)
	-- 将上述自肃效果作为场地型效果注册到当前玩家，使其影响全场。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃的判定函数：若从额外卡组特殊召唤的怪兽不是同步怪兽，则不允许特殊召唤。
function c37799519.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的检索过滤器：筛选出效果文本上记载了「星尘龙」的魔法·陷阱卡，且能够加入手卡。
function c37799519.thfilter(c)
	-- 判定卡片满足：卡名记述了「星尘龙」、是魔法·陷阱卡、并且可以加入手卡。
	return aux.IsCodeListed(c,44508094) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的发动条件判定：卡组中存在符合条件的卡时允许发动，并设置检索加入手卡的操作信息。
function c37799519.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张符合条件的魔法·陷阱卡，用于判定②效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c37799519.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时从卡组将1张卡加入手卡，数量1，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张符合条件的魔法·陷阱卡加入手卡，并向对手展示。
function c37799519.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张符合条件的魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c37799519.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡（nil表示加入持有者手卡），原因是效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
