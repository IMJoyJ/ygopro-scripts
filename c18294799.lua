--無限竜シュヴァルツシルト
-- 效果：
-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不是龙族超量怪兽不能从额外卡组特殊召唤。
-- ①：自己场上没有怪兽存在的场合或者对方场上有攻击力2000以上的怪兽存在的场合才能发动。这张卡从手卡特殊召唤，从卡组把「无限龙 施瓦西龙」以外的1只光·暗属性的龙族·8星怪兽守备表示特殊召唤。这个效果从卡组特殊召唤的怪兽的效果无效化。
local s,id,o=GetID()
-- 初始化卡片效果，注册手卡特召自身并从卡组特召怪兽的效果，并添加特召玩家行为的活动计数器
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不是龙族超量怪兽不能从额外卡组特殊召唤。①：自己场上没有怪兽存在的场合或者对方场上有攻击力2000以上的怪兽存在的场合才能发动。这张卡从手卡特殊召唤，从卡组把「无限龙 施瓦西龙」以外的1只光·暗属性的龙族·8星怪兽守备表示特殊召唤。
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
	-- 添加自定义活动计数器，用于监控玩家是否从额外卡组特殊召唤了非龙族超量怪兽
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 过滤函数：检查特殊召唤的怪兽是否非额外卡组特召，或者是表侧表示的龙族超量怪兽
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:IsFaceup())
end
-- 过滤条件：对方场上表侧表示且攻击力在2000以上的怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2000)
end
-- 发动条件：自己场上没有怪兽存在，或者对方场上有攻击力2000以上的怪兽存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 或者对方场上存在至少1只攻击力2000以上的表侧表示怪兽
		or Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil,e,tp)
end
-- Cost：检查本回合是否未进行过限制外的特殊召唤，并在发动时注册本回合不能特殊召唤非龙族超量怪兽的誓约效果
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查本回合是否进行过不符合限制的特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不是龙族超量怪兽不能从额外卡组特殊召唤。①：自己场上没有怪兽存在的场合或者对方场上有攻击力2000以上的怪兽存在的场合才能发动。这张卡从手卡特殊召唤，从卡组把「无限龙 施瓦西龙」以外的1只光·暗属性的龙族·8星怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 在玩家身上注册本回合只能特殊召唤龙族超量怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制：不能从额外卡组特殊召唤非龙族超量怪兽
function s.splimit(e,c)
	return not (c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤卡组中满足条件的怪兽：卡名非「无限龙 施瓦西龙」的光·暗属性龙族8星怪兽
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsLevel(8)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 检查发动目标：不能受到精灵龙限制、自己主要怪兽区域有2个以上的空位、手牌的这张卡可特召且卡组存在可特召的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域是否空余2个以上的格子（因为需要同时特殊召唤2只怪兽）
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在至少1只符合特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息：特殊召唤手牌的这张卡片（数量为1）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：将手牌的这张卡特殊召唤，并从卡组特殊召唤符合条件的怪兽，同时将卡组特殊召唤的怪兽效果无效化
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 向玩家发送选择特殊召唤怪兽的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只满足条件的特殊召唤怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将卡组中选出的怪兽以表侧守备表示特殊召唤到场上
			Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 这个效果从卡组特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e1)
			-- 这个效果从卡组特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e2)
		end
	end
	-- 完成特殊的特殊召唤流程
	Duel.SpecialSummonComplete()
end
