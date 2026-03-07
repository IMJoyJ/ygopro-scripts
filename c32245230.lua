--運命の契約
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：每次自己场上的卡被战斗·效果破坏，给这张卡放置1个皇之键指示物（最多1个）。
-- ②：对方从额外卡组把怪兽特殊召唤的场合，把这张卡1个皇之键指示物取除才能发动。从手卡·卡组以及自己场上的表侧表示的卡之中把1张「命运之扉」送去墓地，从额外卡组把1只光属性「霍普」超量怪兽当作超量召唤作特殊召唤，把这张卡在那只怪兽下面重叠作为超量素材。
function c32245230.initial_effect(c)
	c:EnableCounterPermit(0x5e,LOCATION_SZONE)
	c:SetCounterLimit(0x5e,1)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：每次自己场上的卡被战斗·效果破坏，给这张卡放置1个皇之键指示物（最多1个）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetOperation(c32245230.ctop)
	c:RegisterEffect(e1)
	-- ②：对方从额外卡组把怪兽特殊召唤的场合，把这张卡1个皇之键指示物取除才能发动。从手卡·卡组以及自己场上的表侧表示的卡之中把1张「命运之扉」送去墓地，从额外卡组把1只光属性「霍普」超量怪兽当作超量召唤作特殊召唤，把这张卡在那只怪兽下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32245230,0))  --"特殊召唤「霍普」超量怪兽"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,32245230)
	e2:SetCondition(c32245230.spcon)
	e2:SetCost(c32245230.spcost)
	e2:SetTarget(c32245230.sptg)
	e2:SetOperation(c32245230.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断被破坏的卡是否为己方场上因战斗或效果被破坏的卡
function c32245230.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 当有满足条件的卡被破坏时，给这张卡放置1个皇之键指示物
function c32245230.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c32245230.cfilter,1,nil,tp) then
		e:GetHandler():AddCounter(0x5e,1)
	end
end
-- 过滤函数，用于判断特殊召唤的怪兽是否为对方从额外卡组特殊召唤的
function c32245230.cfilter2(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)
end
-- 判断是否有对方从额外卡组特殊召唤的怪兽
function c32245230.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c32245230.cfilter2,1,nil,tp)
end
-- 支付1个皇之键指示物作为代价
function c32245230.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x5e,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x5e,1,REASON_COST)
end
-- 过滤函数，用于选择手牌、卡组或场上的「命运之扉」卡
function c32245230.tgfilter(c)
	return (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or c:IsFaceup())
		and c:IsCode(27062594) and c:IsAbleToGrave()
end
-- 过滤函数，用于选择光属性的「霍普」超量怪兽
function c32245230.spfilter(c,e,tp)
	return c:IsSetCard(0x7f) and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_LIGHT)
		-- 检查是否有足够的额外卡组召唤空间
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置效果发动的条件，包括是否有「命运之扉」卡可送去墓地、是否有「霍普」超量怪兽可特殊召唤、是否满足超量召唤的素材要求
function c32245230.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有「命运之扉」卡可送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c32245230.tgfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,nil)
		-- 检查是否满足超量召唤的素材要求且此卡可作为超量素材
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) and e:GetHandler():IsCanOverlay()
		-- 检查是否有光属性的「霍普」超量怪兽可特殊召唤
		and Duel.IsExistingMatchingCard(c32245230.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD)
	-- 设置操作信息，表示将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数，执行特殊召唤和叠放操作
function c32245230.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择要送去墓地的「命运之扉」卡
	local g=Duel.SelectMatchingCard(tp,c32245230.tgfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		-- 检查是否满足超量召唤的素材要求
		if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择要特殊召唤的「霍普」超量怪兽
		local sg=Duel.SelectMatchingCard(tp,c32245230.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local sc=sg:GetFirst()
		if sc then
			sc:SetMaterial(nil)
			-- 将选中的怪兽特殊召唤
			if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
				sc:CompleteProcedure()
				if c:IsRelateToEffect(e) and c:IsCanOverlay() then
					-- 将此卡叠放于特殊召唤的怪兽下方作为超量素材
					Duel.Overlay(sc,Group.FromCards(c))
				end
			end
		end
	end
end
