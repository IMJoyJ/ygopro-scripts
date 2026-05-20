--Faisan, Hunting Scout of the Deep Forest
-- 效果：
-- 战士族·地属性怪兽×2
-- 这张卡在主要阶段期间不受对方发动的效果影响。
-- 战斗阶段（诱发即时效果）：可以把融合召唤的这张卡解放；从自己墓地把「深林狩哨 雉鸡」以外的2只战士族·地属性怪兽特殊召唤，再让自己场上的战士族·地属性怪兽直到回合结束时不会被战斗破坏。「深林狩哨 雉鸡」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果，注册融合召唤手续、主要阶段不受对方发动效果影响的永续效果，以及战斗阶段解放自身特召墓地怪兽并赋予战破抗性的诱发即时效果
function s.initial_effect(c)
	-- 设定融合素材为2只地属性·战士族怪兽
	aux.AddFusionProcFunRep(c,s.matfilter,2,true)
	c:EnableReviveLimit()
	-- 这张卡在主要阶段期间不受对方发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- 战斗阶段（诱发即时效果）：可以把融合召唤的这张卡解放；从自己墓地把「深林狩哨 雉鸡」以外的2只战士族·地属性怪兽特殊召唤，再让自己场上的战士族·地属性怪兽直到回合结束时不会被战斗破坏。「深林狩哨 雉鸡」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤融合素材：地属性且是战士族的怪兽
function s.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
end
-- 过滤不受效果影响的范围：仅不受对方玩家发动的效果影响，且仅在主要阶段适用
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
		-- 检查当前阶段是否为主要阶段
		and Duel.IsMainPhase()
end
-- 检查特殊召唤效果的发动条件：当前为战斗阶段，且自身是融合召唤入场的
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为战斗阶段，且此卡是否是通过融合召唤特殊召唤的
	return Duel.IsBattlePhase() and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 定义特殊召唤效果的发动代价：解放自身
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤特殊召唤的怪兽：墓地中除「深林狩哨 雉鸡」以外的地属性·战士族怪兽，且可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
		and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义特殊召唤效果的发动靶向：检查怪兽区域空位、青眼精灵龙的限制，以及墓地中是否存在2只满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在解放自身后，自己场上是否有2个或以上的空余怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己墓地是否存在至少2只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 设置特殊召唤的操作信息：从自己墓地特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
-- 定义特殊召唤效果的效果处理：特殊召唤2只怪兽，并注册让场上地属性·战士族怪兽直到回合结束时不会被战斗破坏的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己墓地选择2只满足特殊召唤条件的地属性·战士族怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			-- 再让自己场上的战士族·地属性怪兽直到回合结束时不会被战斗破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetTargetRange(LOCATION_MZONE,0)
			e1:SetTarget(s.indtg)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetValue(1)
			-- 注册该战斗破坏抗性的全局效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 过滤战斗破坏抗性效果的适用对象：自己场上的地属性·战士族怪兽
function s.indtg(e,c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
end
