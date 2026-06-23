--ジャンク・ウォリアー・エクストリーム
-- 效果：
-- 「废品同调士」＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己墓地把2星以下的怪兽尽可能特殊召唤，这个回合，那些怪兽的效果不能发动。这个效果的发动后，直到回合结束时自己只能有1次特殊召唤。
-- ②：这张卡战斗破坏对方怪兽时，把这张卡除外才能发动。从额外卡组把1只「废品」同调怪兽当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤条件并注册两个触发效果
function s.initial_effect(c)
	-- 为该卡添加素材代码列表，允许使用废品同调士（63977008）作为同调素材
	aux.AddMaterialCodeList(c,63977008)
	-- 设置同调召唤程序，要求1只调整（s.tfilter）和1只非调整怪兽作为素材
	aux.AddSynchroProcedure(c,s.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 效果①：这张卡同调召唤成功时发动，从墓地特殊召唤2星以下怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从墓地特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 效果②：这张卡战斗破坏对方怪兽时发动，将此卡除外并从额外卡组特殊召唤1只「废品」同调怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从额外卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1,id+o)
	-- 设置效果②的发动条件，检测是否与对方怪兽战斗并被破坏
	e2:SetCondition(aux.bdocon)
	-- 设置效果②的发动费用，将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
s.material_setcode=0x1017
-- 同调素材过滤函数，判断是否为废品同调士或具有特定效果的卡
function s.tfilter(c)
	return c:IsCode(63977008) or c:IsHasEffect(20932152)
end
-- 效果①的发动条件，判断此卡是否为同调召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 墓地特殊召唤过滤函数，筛选2星以下可特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动时的判定函数，检查是否有满足条件的怪兽可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果①的发动信息，提示将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①的处理函数，检索并特殊召唤满足条件的怪兽，并限制本回合特殊召唤次数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家当前场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取满足条件的墓地怪兽组，排除受王家长眠之谷影响的怪兽
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		local g=nil
		if tg:GetCount()>ft then
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			g=tg:Select(tp,ft,ft,nil)
		else
			g=tg
		end
		if g:GetCount()>0 then
			-- 遍历选择的怪兽组进行特殊召唤
			for tc in aux.Next(g) do
				-- 特殊召唤一张怪兽到场上
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				-- 为特殊召唤的怪兽设置效果，使其本回合不能发动效果
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
			-- 完成特殊召唤流程
			Duel.SpecialSummonComplete()
		end
	end
	-- 设置效果①的发动后限制，禁止本回合再次特殊召唤
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetLabel(s.getsummoncount(tp))
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果①的发动后限制效果
	Duel.RegisterEffect(e2,tp)
	-- 设置效果①的发动后限制，限制本回合特殊召唤次数
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetLabel(s.getsummoncount(tp))
	e3:SetValue(s.countval)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果①的发动后限制效果
	Duel.RegisterEffect(e3,tp)
end
-- 获取玩家当前特殊召唤次数
function s.getsummoncount(tp)
	-- 获取玩家当前特殊召唤次数
	return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
end
-- 限制特殊召唤的判定函数，若超过已特殊召唤次数则禁止召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return s.getsummoncount(sump)>e:GetLabel()
end
-- 限制特殊召唤次数的值函数，若超过已特殊召唤次数则返回0，否则返回1
function s.countval(e,re,tp)
	if s.getsummoncount(tp)>e:GetLabel() then return 0 else return 1 end
end
-- 效果②的特殊召唤过滤函数，筛选「废品」同调怪兽
function s.spfilter2(c,e,tp,ec)
	return c:IsSetCard(0x43) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查额外卡组怪兽是否可以特殊召唤到场上
		and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0
end
-- 效果②的发动时的判定函数，检查是否有满足条件的怪兽可特殊召唤
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足必须成为素材的条件
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置效果②的发动信息，提示将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理函数，将此卡除外并从额外卡组特殊召唤1只「废品」同调怪兽
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足必须成为素材的条件
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的额外卡组怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 特殊召唤选定的怪兽到场上
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
