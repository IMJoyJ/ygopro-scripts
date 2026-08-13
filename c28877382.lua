--終刻竜機Ⅴ－アマルテ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合或者被效果破坏的场合才能发动。从卡组把「终刻龙机5-阿玛尔忒」以外的1只「终刻」怪兽加入手卡。
-- ②：自己·对方回合，这张卡有装备卡装备的场合才能发动。把持有和这张卡的等级相同数值的阶级的1只机械族·风属性超量怪兽当作超量召唤从额外卡组特殊召唤，把这张卡以及这张卡的装备卡全部作为那超量素材。
local s,id,o=GetID()
-- 定义并注册卡片的①、②两个效果：①为召唤·特殊召唤成功或被效果破坏时从卡组检索「终刻」怪兽；②为有装备卡时在双方回合从额外卡组当作超量召唤特殊召唤机械族·风属性超量怪兽，并将这张卡和装备卡全部作为超量素材。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合或者被效果破坏的场合才能发动。从卡组把「终刻龙机5-阿玛尔忒」以外的1只「终刻」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.thcon)
	c:RegisterEffect(e3)
	-- ②：自己·对方回合，这张卡有装备卡装备的场合才能发动。把持有和这张卡的等级相同数值的阶级的1只机械族·风属性超量怪兽当作超量召唤从额外卡组特殊召唤，把这张卡以及这张卡的装备卡全部作为那超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"超量召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.xyzcon)
	e4:SetTarget(s.xyztg)
	e4:SetOperation(s.xyzop)
	c:RegisterEffect(e4)
end
-- 效果①的破坏条件：判断这张卡被破坏的原因是否为效果（REASON_EFFECT），即仅限‘被效果破坏’的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 检索过滤条件：选择卡名不是「终刻龙机5-阿玛尔忒」、属于「终刻」字段、是怪兽卡且能加入手卡的卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1d2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动目标判定：在合法性检查（chk==0）时确认卡组中存在符合条件的检索对象；之后设置从卡组将1张卡加入手卡的操作信息，并向对方提示发动了效果①。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：确认己方卡组中存在至少1张符合条件的「终刻」怪兽可供检索。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将卡组中的1张卡加入手卡（CATEGORY_TOHAND），来源为卡组（LOCATION_DECK）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 向对方玩家（1-tp）提示本方发动了效果①，展示效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①的操作处理：从卡组选择1张符合条件的「终刻」怪兽加入手卡，并向对方展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示己方玩家选择要加入手牌的卡（显示‘请选择要加入手牌的卡’）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 己方从卡组中选择1张满足s.thfilter条件的「终刻」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡以效果原因（REASON_EFFECT）加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家（1-tp）确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：这张卡装备有装备卡，且这些装备卡都能作为超量素材叠放（不存在不能叠放的装备卡）。
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	-- 返回是否有装备卡（装备组数量>0），且不存在不能作为超量素材叠放的装备卡。
	return g:GetCount()>0 and not g:IsExists(aux.NOT(Card.IsCanOverlay),1,nil)
end
-- 额外卡组超量召唤候选的过滤：机械族、风属性、阶级等于这张卡的等级、是超量怪兽（且是怪兽卡），并且可以当作超量召唤特殊召唤，还有足够可用怪兽区域。
function s.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRank(lv) and c:IsAllTypes(TYPE_XYZ+TYPE_MONSTER)
		-- 确认候选怪兽可以以超量召唤方式（SUMMON_TYPE_XYZ）被特殊召唤，且从额外卡组特殊召唤后有可用的怪兽区域。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果②的发动目标判定：确认这张卡本身能作为超量素材、没有必须作为超量素材的限制影响、额外卡组存在符合条件的超量怪兽；满足后设置特殊召唤操作信息并提示对方。
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanOverlay()
		-- 确认满足‘必须作为超量素材’（EFFECT_MUST_BE_XMATERIAL）的合法性检查，没有影响本次素材选择的限制。
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 确认额外卡组中存在至少1只满足s.spfilter条件的超量怪兽（机械族·风属性·阶级等于本卡等级）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel()) end
	-- 设置操作信息：本次效果从额外卡组特殊召唤1只超量怪兽（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 向对方玩家（1-tp）提示本方发动了效果②，展示效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果②的操作处理：选择额外卡组1只符合条件的超量怪兽进行超量召唤；成功后把这张卡及其全部装备卡叠放到该怪兽下方作为超量素材。
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or c:IsFacedown() then return end
	-- 效果处理时再次进行‘必须作为超量素材’的合法性检查，若检查不通过则终止处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 提示己方玩家选择要特殊召唤的卡（显示‘请选择要特殊召唤的卡’）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 己方从额外卡组选择1只满足s.spfilter条件的超量怪兽。
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c:GetLevel())
	local sc=sg:GetFirst()
	-- 若选中的卡存在且以超量召唤形式（SUMMON_TYPE_XYZ）特殊召唤成功（返回值≠0），则继续执行叠放处理。
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		sc:CompleteProcedure()
		local g=c:GetEquipGroup()
		g:AddCard(c)
		-- 将这张卡及其全部装备卡（g）叠放在超量召唤成功的怪兽sc下方，作为超量素材。
		Duel.Overlay(sc,g)
	end
end
