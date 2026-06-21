--サイバース・リマインダー
-- 效果：
-- 3星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次，这张卡的效果发动的回合，自己不是电子界族怪兽不能从额外卡组特殊召唤。
-- ①：把这张卡1个超量素材取除，以自己墓地1张「电脑网」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
-- ②：超量召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把2只电子界族·4星怪兽效果无效特殊召唤（同名卡最多1张）。
function c56337500.initial_effect(c)
	-- 设置XYZ召唤手续：需要2只3星怪兽
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以自己墓地1张「电脑网」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56337500,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,56337500)
	e1:SetCost(c56337500.thcost)
	e1:SetTarget(c56337500.thtg)
	e1:SetOperation(c56337500.thop)
	c:RegisterEffect(e1)
	-- ②：超量召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把2只电子界族·4星怪兽效果无效特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56337500,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,56337501)
	e2:SetCost(c56337500.cost)
	e2:SetCondition(c56337500.spcon)
	e2:SetTarget(c56337500.sptg)
	e2:SetOperation(c56337500.spop)
	c:RegisterEffect(e2)
	-- 注册一个自定义活动计数器，用于检测玩家在当前回合内是否从额外卡组特殊召唤过非电子界族怪兽
	Duel.AddCustomActivityCounter(56337500,ACTIVITY_SPSUMMON,c56337500.counterfilter)
end
-- 计数器的过滤条件：如果特殊召唤的怪兽不是来自额外卡组，或者是电子界族怪兽，则不计入限制
function c56337500.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_CYBERSE) and c:IsFaceup()
end
-- 效果发动的Cost处理函数，用于检查并适用“这张卡的效果发动的回合，自己不是电子界族怪兽不能从额外卡组特殊召唤”的限制
function c56337500.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查本回合玩家是否已经从额外卡组特殊召唤过非电子界族怪兽
	if chk==0 then return Duel.GetCustomActivityCount(56337500,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡的效果发动的回合，自己不是电子界族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c56337500.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册该限制效果，使其在回合内持续生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数：禁止特殊召唤非电子界族的额外卡组怪兽
function c56337500.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_CYBERSE) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果①的Cost函数：检查并取除1个超量素材，并适用不能从额外卡组特殊召唤非电子界族怪兽的限制
function c56337500.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		and c56337500.cost(e,tp,eg,ep,ev,re,r,rp,0) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	c56337500.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 效果①的过滤函数：筛选自己墓地中可以加入手牌的「电脑网」魔法·陷阱卡
function c56337500.thfilter(c)
	return c:IsSetCard(0x118) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的Target函数：检查并选择墓地中1张「电脑网」魔法·陷阱卡作为效果对象，并设置操作信息
function c56337500.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56337500.thfilter(chkc) end
	-- 检查自己墓地是否存在符合条件的「电脑网」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c56337500.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地中1张符合条件的「电脑网」魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c56337500.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的Operation函数：将作为对象的卡加入手牌
function c56337500.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片通过效果加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果②的条件函数：超量召唤的这张卡被战斗或者对方的效果破坏并送去墓地（或除外）的场合
function c56337500.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果②的过滤函数：筛选卡组中可以特殊召唤的4星电子界族怪兽
function c56337500.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的Target函数：检查怪兽区域空位、是否受精灵龙限制，以及卡组中是否存在2只不同卡名的4星电子界族怪兽，并设置特殊召唤的操作信息
function c56337500.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 获取卡组中所有符合条件的4星电子界族怪兽
		local g=Duel.GetMatchingGroup(c56337500.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置效果处理信息：从卡组特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果②的Operation函数：从卡组选择2只卡名不同的4星电子界族怪兽，效果无效化并特殊召唤
function c56337500.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 再次获取卡组中符合条件的4星电子界族怪兽
	local g=Duel.GetMatchingGroup(c56337500.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从符合条件的怪兽中选择2只卡名不同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		local tc=sg:GetFirst()
		while tc do
			-- 逐步特殊召唤选中的怪兽（表侧表示）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 效果无效
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			tc=sg:GetNext()
		end
		-- 完成所有怪兽的特殊召唤处理
		Duel.SpecialSummonComplete()
	end
end
