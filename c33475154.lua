--大魔女サンドリヨン
local s,id,o=GetID()
-- 定义一个函数s.initial_effect(c)，用于初始化卡片的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用怪兽种族魔法师作为素材。
	aux.AddFusionProcCodeFun(c,21522601,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),2,true,true)
	-- 创建效果e1，描述信息来自id对应的字符串0，设置效果类别为特殊召唤，类型为单次触发型，触发条件为成功特殊召唤，延迟生效，限制每回合一次，条件为s.spcon，目标为s.sptg，操作为s.spop，并将效果注册到卡片c。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 创建效果e2，描述信息来自id对应的字符串1，设置效果类别为特殊召唤，类型为场地触发型，触发条件为阶段结束时，生效范围为墓地，限制每回合一次，条件为s.spcon2，费用为s.spcost2，目标为s.sptg2，操作为s.spop2，并将效果注册到卡片c。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 定义函数s.spcon(e,tp,eg,ep,ev,re,r,rp)，判断触发条件是否满足：如果被处理的怪兽是以融合方式召唤的则返回真。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 定义函数s.spfilter(c,e,tp)，用于过滤符合条件的卡片：种族为魔法师，等级低于7，且可以特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x128) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义函数s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)，设置特殊召唤的目标。如果检查标记为0，则返回玩家场上是否有空的怪兽区，以及手牌或卡组中是否存在符合s.spfilter过滤条件的卡片。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家的怪兽区数量是否大于0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌或者卡组中是否存在满足条件的可特殊召唤的卡片
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示进行特殊召唤，目标数量为1，在手牌或卡组中选择。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义函数s.spop(e,tp,eg,ep,ev,re,r,rp)，执行特殊召唤的操作。获取玩家的怪兽区空位数量（最多3个），如果【青眼精灵龙】效果生效，则限制为1个。从符合条件的卡片组中选择一定数量的卡片进行特殊召唤，并注册一个场地效果，禁止融合怪兽在额外区域特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家的怪兽区空位数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>3 then ft=3 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) and ft>1 then ft=1 end
	-- 从手牌和卡组中筛选出符合条件的怪兽卡
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if ft>0 and g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从筛选出的卡片中选择一定数量的卡片进行特殊召唤
		local sg=g:SelectSubGroup(tp,aux.dabcheck,false,1,ft)
		if sg:GetCount()>0 then
			-- 将选定的卡片以表侧表示特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 创建场地效果，禁止融合怪兽在额外区域特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册场地效果到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义函数s.splimit(e,c)，用于限制特殊召唤的目标：如果目标不是融合怪兽且位于额外区域，则返回真。
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 定义函数s.spcon2(e,tp,eg,ep,ev,re,r,rp)，判断触发条件是否满足：如果当前回合的玩家是tp，则返回真。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为tp
	return Duel.GetTurnPlayer()==tp
end
-- 定义函数s.cfilter(c)，用于过滤符合条件的卡片：类型为魔法且未公开。
function s.cfilter(c)
	return c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 定义函数s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)，设置特殊召唤的费用。如果检查标记为0，则返回手牌中是否存在符合s.cfilter过滤条件的卡片。
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手牌中是否存在满足条件的可确认的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌中选择一张魔法卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选定的卡片给对方确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
end
-- 定义函数s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)，设置特殊召唤的目标。如果检查标记为0，则返回玩家场上是否有空的怪兽区，以及当前卡片是否可以特殊召唤。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断玩家的怪兽区数量是否大于0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息，表示进行特殊召唤，目标数量为1，在手牌或卡组中选择。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义函数s.spop2(e,tp,eg,ep,ev,re,r,rp)，执行特殊召唤的操作。如果当前卡片处于连锁中，则以表侧防御表示进行特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将当前卡片以表侧防御表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
