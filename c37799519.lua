--スターダスト・シンクロン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把自己场上1只怪兽解放才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「星尘龙」的卡名记述的1张魔法·陷阱卡加入手卡。
function c37799519.initial_effect(c)
	-- 记录该卡具有「星尘龙」的卡名记述
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
-- 设置解放怪兽的费用，检查是否有满足条件的怪兽组可被解放
function c37799519.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家可解放的怪兽组
	local g=Duel.GetReleaseGroup(tp)
	-- 检查是否满足解放条件
	if chk==0 then return g:CheckSubGroup(aux.mzctcheckrel,1,1,tp) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的怪兽组进行解放
	local rg=g:SelectSubGroup(tp,aux.mzctcheckrel,false,1,1,tp)
	-- 使用代替解放次数的效果
	aux.UseExtraReleaseCount(rg,tp)
	-- 实际执行解放操作
	Duel.Release(rg,REASON_COST)
end
-- 设置特殊召唤的目标和信息
function c37799519.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，包括设置效果和限制后续同调召唤
function c37799519.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 判断是否成功特殊召唤该卡
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 特殊召唤后，若该卡离开场上的场合则移除
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
	-- 设置效果，使玩家在本回合不能特殊召唤非同调怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(c37799519.splimit)
	-- 注册限制特殊召唤的效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制特殊召唤效果的判断函数，禁止非同调怪兽从额外卡组特殊召唤
function c37799519.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 检索过滤函数，用于筛选含有「星尘龙」卡名记述的魔法或陷阱卡
function c37799519.thfilter(c)
	-- 判断卡片是否含有「星尘龙」的卡名记述且为魔法或陷阱类型
	return aux.IsCodeListed(c,44508094) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置检索目标和信息
function c37799519.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c37799519.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作，将符合条件的卡加入手牌
function c37799519.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c37799519.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
