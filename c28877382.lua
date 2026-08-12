--終刻竜機Ⅴ－アマルテ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合或者被效果破坏的场合才能发动。从卡组把「终刻龙机5-阿玛尔忒」以外的1只「终刻」怪兽加入手卡。
-- ②：自己·对方回合，这张卡有装备卡装备的场合才能发动。把持有和这张卡的等级相同数值的阶级的1只机械族·风属性超量怪兽当作超量召唤从额外卡组特殊召唤，把这张卡以及这张卡的装备卡全部作为那超量素材。
local s,id,o=GetID()
-- 创建并注册该卡的3个效果，分别对应①②效果的三种触发条件（通常召唤、特殊召唤、被破坏）和②效果（超量召唤）
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
-- 判断被破坏的原因是否为效果破坏
function s.thcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 筛选满足条件的「终刻」怪兽（非本卡、可加入手牌）
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1d2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索并加入手牌的效果处理信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件（卡组存在符合条件的怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 提示对方玩家该效果已被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 处理效果发动后的操作：选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否满足超量召唤条件（装备卡存在且均可叠放）
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	-- 装备卡存在且均可叠放
	return g:GetCount()>0 and not g:IsExists(aux.NOT(Card.IsCanOverlay),1,nil)
end
-- 筛选满足条件的机械族·风属性超量怪兽（等级匹配、可特殊召唤）
function s.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRank(lv) and c:IsAllTypes(TYPE_XYZ+TYPE_MONSTER)
		-- 检查是否满足特殊召唤条件（可特殊召唤、有召唤空位）
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置超量召唤效果的处理信息
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanOverlay()
		-- 检查是否满足必须成为超量素材的条件
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查是否满足特殊召唤条件（额外卡组存在符合条件的怪兽）
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel()) end
	-- 设置操作信息：将1只怪兽从额外卡组特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 提示对方玩家该效果已被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 处理超量召唤效果：选择并特殊召唤，然后叠放装备卡
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or c:IsFacedown() then return end
	-- 检查是否满足必须成为超量素材的条件
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽特殊召唤
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c:GetLevel())
	local sc=sg:GetFirst()
	-- 执行特殊召唤操作
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		sc:CompleteProcedure()
		local g=c:GetEquipGroup()
		g:AddCard(c)
		-- 将装备卡叠放至特殊召唤的怪兽上
		Duel.Overlay(sc,g)
	end
end
