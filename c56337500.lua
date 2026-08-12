--サイバース・リマインダー
-- 效果：
-- 3星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次，这张卡的效果发动的回合，自己不是电子界族怪兽不能从额外卡组特殊召唤。
-- ①：把这张卡1个超量素材取除，以自己墓地1张「电脑网」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
-- ②：超量召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把2只电子界族·4星怪兽效果无效特殊召唤（同名卡最多1张）。
function c56337500.initial_effect(c)
	-- 添加超量召唤手续：3星怪兽×2
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
	-- 添加自定义活动计数器，用于监控从额外卡组特殊召唤非电子界族怪兽的行为
	Duel.AddCustomActivityCounter(56337500,ACTIVITY_SPSUMMON,c56337500.counterfilter)
end
-- 计数器过滤条件：不是从额外卡组特殊召唤，或者是表侧表示的电子界族怪兽
function c56337500.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_CYBERSE) and c:IsFaceup()
end
-- 发动限制（誓约效果）：检查本回合是否从额外卡组特召过非电子界族怪兽，并注册本回合不能从额外卡组特召非电子界族怪兽的效果
function c56337500.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，确认本回合未曾从额外卡组特殊召唤过非电子界族怪兽
	if chk==0 then return Duel.GetCustomActivityCount(56337500,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡的效果发动的回合，自己不是电子界族怪兽不能从额外卡组特殊召唤。①：把这张卡1个超量素材取除，以自己墓地1张「电脑网」魔法·陷阱卡为对象才能发动。那张卡加入手卡。②：超量召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把2只电子界族·4星怪兽效果无效特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c56337500.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 对玩家注册该限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制条件：不能从额外卡组特殊召唤非电子界族怪兽
function c56337500.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_CYBERSE) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果①的发动代价判断：检查是否可以把这张卡1个超量素材取除，以及本回合是否满足不能从额外卡组特召非电子界族怪兽的限制
function c56337500.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		and c56337500.cost(e,tp,eg,ep,ev,re,r,rp,0) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	c56337500.cost(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 效果①的过滤条件：自己墓地的「电脑网」魔法·陷阱卡且能加入手牌
function c56337500.thfilter(c)
	return c:IsSetCard(0x118) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的发动准备：以自己墓地1张「电脑网」魔法·陷阱卡为对象才能发动，设置回收该卡的操作信息
function c56337500.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56337500.thfilter(chkc) end
	-- 检查自己墓地是否存在满足条件的「电脑网」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c56337500.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张「电脑网」魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c56337500.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的对象卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的效果处理：将作为对象的卡片加入手牌
function c56337500.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果②的发动条件：超量召唤的这张卡被战斗或者对方的效果破坏并送去墓地时才能发动
function c56337500.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果②的过滤条件：卡组中的电子界族·4星怪兽且能够特殊召唤
function c56337500.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：确认空位与特召限制，检查卡组中是否存在2只卡名不同的4星电子界族怪兽，设置特殊召唤2只怪兽的操作信息
function c56337500.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 获取卡组中所有符合条件的电子界族·4星怪兽
		local g=Duel.GetMatchingGroup(c56337500.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置操作信息：从卡组特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组把2只不同名的电子界族·4星怪兽效果无效特殊召唤
function c56337500.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取卡组中所有符合条件的电子界族·4星怪兽
	local g=Duel.GetMatchingGroup(c56337500.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从符合条件的怪兽中选择2张卡名不同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		local tc=sg:GetFirst()
		while tc do
			-- 将所选怪兽以表侧表示放入特召特殊召唤的处理步骤中
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
