--ドラグニティナイト－ロムルス
-- 效果：
-- 衍生物以外的龙族·鸟兽族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「龙骑兵团」魔法·陷阱卡或「龙之溪谷」加入手卡。
-- ②：龙族怪兽从额外卡组往这张卡所连接区特殊召唤的场合才能发动。从手卡把1只龙族·鸟兽族怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能作为连接素材。
function c11969228.initial_effect(c)
	-- 为该卡注册与「龙之溪谷」相关的卡片代码，用于后续效果判断
	aux.AddCodeList(c,62265044)
	-- 设置该卡的连接召唤条件，需要使用2只满足过滤条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,c11969228.mfilter,2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「龙骑兵团」魔法·陷阱卡或「龙之溪谷」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11969228,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,11969228)
	e1:SetCondition(c11969228.thcon)
	e1:SetTarget(c11969228.thtg)
	e1:SetOperation(c11969228.thop)
	c:RegisterEffect(e1)
	-- ②：龙族怪兽从额外卡组往这张卡所连接区特殊召唤的场合才能发动。从手卡把1只龙族·鸟兽族怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能作为连接素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11969228,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,11969229)
	e2:SetCondition(c11969228.spcon)
	e2:SetTarget(c11969228.sptg)
	e2:SetOperation(c11969228.spop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤函数，筛选非衍生物且种族为龙族或鸟兽族的怪兽
function c11969228.mfilter(c)
	return not c:IsLinkType(TYPE_TOKEN) and c:IsLinkRace(RACE_DRAGON+RACE_WINDBEAST)
end
-- 效果①的发动条件判断函数，判断该卡是否为连接召唤
function c11969228.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索卡牌过滤函数，筛选「龙骑兵团」魔法·陷阱卡或「龙之溪谷」
function c11969228.thfilter(c)
	return ((c:IsSetCard(0x29) and c:IsType(TYPE_SPELL+TYPE_TRAP)) or c:IsCode(62265044)) and c:IsAbleToHand()
end
-- 效果①的目标选择函数，检查是否有满足条件的卡牌可检索
function c11969228.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，检查卡组中是否存在符合条件的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(c11969228.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果①的连锁操作信息，指定将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数，执行检索并确认卡片
function c11969228.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的卡牌
	local g=Duel.SelectMatchingCard(tp,c11969228.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 特殊召唤条件过滤函数，判断怪兽是否为龙族且来自额外卡组且在连接区
function c11969228.cfilter(c,lg)
	return c:IsRace(RACE_DRAGON) and c:IsSummonLocation(LOCATION_EXTRA) and lg:IsContains(c)
end
-- 效果②的发动条件判断函数，判断是否有龙族怪兽从额外卡组特殊召唤至连接区
function c11969228.spcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c11969228.cfilter,1,nil,lg)
end
-- 特殊召唤过滤函数，筛选龙族·鸟兽族怪兽且可特殊召唤
function c11969228.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON+RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的目标选择函数，检查手牌中是否存在可特殊召唤的怪兽
function c11969228.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤条件，检查手牌中是否存在可特殊召唤的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足特殊召唤条件，检查手牌中是否存在可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c11969228.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果②的连锁操作信息，指定将1只怪兽从手牌特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的处理函数，执行特殊召唤并设置效果限制
function c11969228.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从手牌中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c11969228.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤步骤，将怪兽以守备表示特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 设置特殊召唤怪兽的效果无效化
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 设置特殊召唤怪兽的效果在本回合无效
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 设置特殊召唤怪兽不能作为连接素材
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤流程，结束本次特殊召唤处理
	Duel.SpecialSummonComplete()
end
