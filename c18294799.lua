--無限竜シュヴァルツシルト
-- 效果：
-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不是龙族超量怪兽不能从额外卡组特殊召唤。
-- ①：自己场上没有怪兽存在的场合或者对方场上有攻击力2000以上的怪兽存在的场合才能发动。这张卡从手卡特殊召唤，从卡组把「无限龙 施瓦西龙」以外的1只光·暗属性的龙族·8星怪兽守备表示特殊召唤。这个效果从卡组特殊召唤的怪兽的效果无效化。
local s,id,o=GetID()
-- 创建效果1，用于发动特殊召唤自身并从卡组特殊召唤怪兽的效果
function s.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合或者对方场上有攻击力2000以上的怪兽存在的场合才能发动。这张卡从手卡特殊召唤，从卡组把「无限龙 施瓦西龙」以外的1只光·暗属性的龙族·8星怪兽守备表示特殊召唤。这个效果从卡组特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤自身并特殊召唤卡组"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 设置计数器，用于限制每回合只能发动一次效果
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，用于判断是否满足限制条件
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ))
end
-- 条件过滤函数，用于判断对方场上是否存在攻击力2000以上的怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2000)
end
-- 效果发动条件函数，判断是否满足发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 判断对方场上是否存在攻击力2000以上的怪兽
		or Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil,e,tp)
end
-- 效果发动时的费用函数，设置不能特殊召唤的限制
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已经发动过效果
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 设置不能特殊召唤的限制效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册不能特殊召唤的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标过滤函数，禁止从额外卡组特殊召唤非龙族超量怪兽
function s.splimit(e,c)
	return not (c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
-- 特殊召唤目标过滤函数，筛选符合条件的怪兽
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsLevel(8)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的目标设定函数，检查是否满足发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查场上是否有足够的空间
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果发动时的操作函数，执行特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择符合条件的怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 使特殊召唤的怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e1)
			-- 使特殊召唤的怪兽效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e2)
		end
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
