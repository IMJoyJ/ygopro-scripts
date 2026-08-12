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
	-- ①：每次自己场上的卡被战斗·效果破坏，给这张卡放置1个皇之键指示物（最多1个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetOperation(c32245230.ctop)
	c:RegisterEffect(e1)
	-- ②：对方从额外卡组把怪兽特殊召唤的场合，把这张卡1个皇之键指示物取除才能发动。从手卡·卡组以及自己场上的表侧表示的卡之中把1张「命运之扉」送去墓地，从额外卡组把1只光属性「霍普」超量怪兽当作超量召唤作特殊召唤，把这张卡在那只怪兽下面重叠作为超量素材。这个卡名的②的效果1回合只能使用1次。
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
c32245230.mentioned_counter={
	[0x5e]=true,
}
-- 过滤函数：判断被破坏的卡被破坏前是自己场上、且是被战斗·效果破坏的卡
function c32245230.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 只要本次被破坏的卡中存在原本在自己场上且被战斗·效果破坏的卡，就给这张卡放置1个皇之键指示物
function c32245230.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c32245230.cfilter,1,nil,tp) then
		e:GetHandler():AddCounter(0x5e,1)
	end
end
-- 过滤函数：判断怪兽是否由对方玩家从额外卡组特殊召唤
function c32245230.cfilter2(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)
end
-- 效果发动条件：本次特殊召唤的怪兽中存在由对方从额外卡组特殊召唤的怪兽
function c32245230.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c32245230.cfilter2,1,nil,tp)
end
-- 效果发动代价：检查并取除这张卡上的1个皇之键指示物作为代价
function c32245230.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x5e,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x5e,1,REASON_COST)
end
-- 过滤函数：检索位于手卡·卡组、或在场上表侧表示存在、且可以送去墓地的「命运之扉」
function c32245230.tgfilter(c)
	return (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or c:IsFaceup())
		and c:IsCode(27062594) and c:IsAbleToGrave()
end
-- 过滤函数：检索额外卡组中可以被当作超量召唤特殊召唤的光属性「霍普」超量怪兽，且场上有能让额外怪兽出场的空格
function c32245230.spfilter(c,e,tp)
	return c:IsSetCard(0x7f) and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_LIGHT)
		-- 且该怪兽可以被当作超量召唤特殊召唤，同时场上有能让额外卡组怪兽出场的空格数
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果对象检查：确认能送去墓地的「命运之扉」、这张卡可以成为超量素材、且额外卡组有可特殊召唤的光属性「霍普」超量怪兽
function c32245230.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡·卡组以及场上是否存在1张满足条件的「命运之扉」
	if chk==0 then return Duel.IsExistingMatchingCard(c32245230.tgfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,nil)
		-- 且这张卡可以成为超量素材叠放（不受必须成为素材效果限制）
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) and e:GetHandler():IsCanOverlay()
		-- 且额外卡组中存在1只满足条件、可特殊召唤的光属性「霍普」超量怪兽
		and Duel.IsExistingMatchingCard(c32245230.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：效果处理时将从手卡·卡组·场上把1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD)
	-- 设置操作信息：效果处理时将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：选1张「命运之扉」送去墓地后，从额外卡组把1只光属性「霍普」超量怪兽当作超量召唤特殊召唤，再把这张卡叠放在其下面作为超量素材
function c32245230.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家提示请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的手卡·卡组以及场上选1张满足条件的「命运之扉」
	local g=Duel.SelectMatchingCard(tp,c32245230.tgfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,1,nil)
	-- 若成功选出卡并将其以效果原因送去墓地则继续后续处理
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		-- 若这张卡受到必须成为超量素材的效果限制则中断处理
		if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
		-- 向玩家提示请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选1只满足条件的光属性「霍普」超量怪兽
		local sg=Duel.SelectMatchingCard(tp,c32245230.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local sc=sg:GetFirst()
		if sc then
			sc:SetMaterial(nil)
			-- 以超量召唤的方式把选中的怪兽在自己场上表侧表示特殊召唤，成功则继续处理
			if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
				sc:CompleteProcedure()
				if c:IsRelateToEffect(e) and c:IsCanOverlay() then
					-- 把这张卡叠放在特殊召唤的怪兽下面作为超量素材
					Duel.Overlay(sc,Group.FromCards(c))
				end
			end
		end
	end
end
