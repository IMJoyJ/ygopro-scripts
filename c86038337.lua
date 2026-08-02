--密林の狩猟者フザン
-- 效果：
-- 战士族·地属性怪兽×2
-- 这张卡在主要阶段期间不受对方发动的效果影响。
-- 战斗阶段（诱发即时效果）：可以把融合召唤的这张卡解放；从自己墓地把「深林狩哨 雉鸡」以外的2只战士族·地属性怪兽特殊召唤，再让自己场上的战士族·地属性怪兽直到回合结束时不会被战斗破坏。「深林狩哨 雉鸡」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片信息，添加融合手续并注册各个效果
function s.initial_effect(c)
	-- 用2只满足相同条件的怪兽作为融合素材
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
	-- 战斗阶段（诱发即时效果）：可以把融合召唤的这张卡解放；从自己墓地把「深林狩哨 雉鸡」以外的2只战士族·地属性怪兽特殊召唤
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
-- 检查怪兽是否为地属性的战士族怪兽
function s.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
end
-- 检查发动的效果是否是对方玩家的发动效果且当前处于主要阶段
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
		-- 检查当前是否为主要阶段
		and Duel.IsMainPhase()
end
-- 检查当前是否为战斗阶段且这张卡是融合召唤出场的
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为战斗阶段且这张卡是融合召唤出场的
	return Duel.IsBattlePhase() and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 检查这张卡能否解放，并将这张卡作为代价解放
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡作为代价解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 检查怪兽是否是除同名卡以外的地属性战士族怪兽且可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
		and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查场上是否有足够怪兽区空格，没受青眼精灵龙影响，且墓地存在2只满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的可用怪兽区数量是否大于1个
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查墓地是否存在至少2只满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 设置从墓地特殊召唤2只怪兽的效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
-- 从墓地特殊召唤2只满足条件的怪兽，并赋予己方场上的地属性战士族怪兽战破抗性
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 向玩家发送选择要特殊召唤的怪兽的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从墓地选择2只满足特殊召唤条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽表侧表示特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			-- 再让自己场上的战士族·地属性怪兽直到回合结束时不会被战斗破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetTargetRange(LOCATION_MZONE,0)
			e1:SetTarget(s.indtg)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetValue(1)
			-- 将赋予抗性的效果注册给全局环境
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 检查怪兽是否是地属性战士族怪兽
function s.indtg(e,c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
end
