--重装騎士バベルデッカー
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从手卡把1只机械族·地属性怪兽特殊召唤。
-- ③：对方把卡的效果发动的回合的自己主要阶段才能发动。把1只机械族·地属性·10阶的超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：①不用解放作召唤、②召唤/特殊召唤时特殊召唤1只机械族地属性怪兽、③对方发动卡的效果时在主要阶段特殊召唤1只机械族地属性10阶超量怪兽
function s.initial_effect(c)
	-- ①这张卡可以不用解放作召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	c:RegisterEffect(e1)
	-- ②这张卡召唤·特殊召唤的场合才能发动。从手卡把1只机械族·地属性怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③对方把卡的效果发动的回合的自己主要阶段才能发动。把1只机械族·地属性·10阶的超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"超量召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.spcon2)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
	-- 设置一个计数器，用于记录对方发动连锁的次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 计数器过滤函数，始终返回false，表示不进行任何过滤
function s.chainfilter(re,tp,cid)
	return false
end
-- 过滤函数，用于筛选手牌中满足条件的机械族地属性怪兽
function s.spfilter1(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数，判断是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断目标玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断目标玩家手牌中是否存在满足条件的机械族地属性怪兽
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤处理函数，执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断目标玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的机械族地属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 超量召唤条件函数，判断对方是否发动过卡的效果
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方是否发动过卡的效果
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
-- 过滤函数，用于筛选额外卡组中满足条件的机械族地属性10阶超量怪兽
function s.spfilter2(c,e,tp,mc)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsRank(10)
		and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 判断超量怪兽是否可以被特殊召唤且目标玩家场上是否有足够的区域
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 超量召唤处理函数，判断是否满足特殊召唤条件
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足必须成为素材的条件
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 判断额外卡组中是否存在满足条件的超量怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将要特殊召唤1只超量怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 超量召唤处理函数，执行超量召唤操作
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足必须成为素材的条件
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsRelateToChain() and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的机械族地属性10阶超量怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将原卡的叠放卡叠放到目标超量怪兽上
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将原卡叠放到目标超量怪兽上
			Duel.Overlay(sc,Group.FromCards(c))
			-- 执行超量特殊召唤操作
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
