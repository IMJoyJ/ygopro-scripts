--レアル・ジェネクス・チューリング
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方主要阶段，自己场上有「次世代」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以进行1只「次世代」同调怪兽的同调召唤。
-- ②：把场上的这张卡作为「次世代」同调怪兽的同调素材的场合，可以把这张卡的等级当作1星或者3星使用。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤及同调召唤的二速效果；②作为「次世代」同调素材时可当作1星或3星；③用于标记等级改变效果的永续效果。
function s.initial_effect(c)
	-- ①：对方主要阶段，自己场上有「次世代」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以进行1只「次世代」同调怪兽的同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把场上的这张卡作为「次世代」同调怪兽的同调素材的场合，可以把这张卡的等级当作1星或者3星使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e2:SetTarget(s.syntg)
	e2:SetValue(1)
	e2:SetOperation(s.synop)
	c:RegisterEffect(e2)
	-- ②：把场上的这张卡作为「次世代」同调怪兽的同调素材的场合，可以把这张卡的等级当作1星或者3星使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(id)
	e3:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e3)
end
-- 计算该卡作为「次世代」同调素材时的等级（可当作1星或3星使用）。
function s.cardiansynlevel(c,sc)
	if c:IsHasEffect(id) and sc:IsSetCard(0x2) then
		return 3+(1<<16)
	else
		return c:GetSynchroLevel(sc)
	end
end
-- 过滤可作为同调素材的卡片（必须在场上表侧表示存在，且可以作为该同调怪兽的素材）。
function s.synfilter(c,syncard,tuner,f)
	return c:IsFaceupEx() and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
-- 递归检查当前选定的卡片组是否能满足同调召唤的素材要求。
function s.syncheck(c,g,mg,tp,lv,syncard,minc,maxc)
	g:AddCard(c)
	local ct=g:GetCount()
	local res=s.syngoal(g,tp,lv,syncard,minc,ct)
		or (ct<maxc and mg:IsExists(s.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc))
	g:RemoveCard(c)
	return res
end
-- 检查当前素材组的数量、等级合计（包含等级当作1星或3星的情况）以及额外卡组区域是否满足同调召唤的条件。
function s.syngoal(g,tp,lv,syncard,minc,ct)
	-- 检查已选素材数量是否达到下限，且额外卡组怪兽特殊召唤的区域是否充足。
	return ct>=minc and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0
		and (g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,syncard)
			or g:CheckWithSumEqual(s.cardiansynlevel,lv,ct,ct,syncard))
		-- 检查所选素材是否满足必须作为同调素材的限制效果。
		and aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL)
end
-- 自定义同调素材选择的目标过滤函数，判断是否存在合法的同调素材组合。
function s.syntg(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	if lv<=c:GetLevel() and lv<=s.cardiansynlevel(c) then return false end
	local g=Group.FromCards(c)
	-- 获取玩家场上可用于该同调怪兽同调召唤的素材卡片组。
	local mg=Duel.GetSynchroMaterial(tp):Filter(s.synfilter,c,syncard,c,f)
	return mg:IsExists(s.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc)
end
-- 自定义同调素材选择的操作函数，让玩家依次选择符合条件的同调素材。
function s.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local lv=syncard:GetLevel()
	local g=Group.FromCards(c)
	-- 获取玩家场上可用于该同调怪兽同调召唤的素材卡片组。
	local mg=Duel.GetSynchroMaterial(tp):Filter(s.synfilter,c,syncard,c,f)
	for i=1,maxc do
		local cg=mg:Filter(s.syncheck,g,g,mg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if s.syngoal(g,tp,lv,syncard,minc,i) then
			minct=0
		end
		-- 提示玩家选择要作为同调素材的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local sg=cg:Select(tp,minct,1,nil)
		if sg:GetCount()==0 then break end
		g:Merge(sg)
	end
	-- 将选定的卡片组设置为同调素材。
	Duel.SetSynchroMaterial(g)
end
-- 过滤自己场上表侧表示的「次世代」怪兽。
function s.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2)
end
-- 检查发动条件：对方主要阶段，且自己场上有表侧表示的「次世代」怪兽存在。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 确认当前是对方回合的主要阶段，且自己场上存在表侧表示的「次世代」怪兽。
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备：检查自身是否能从手卡特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动效果时，检查自己场上是否有可用于特殊召唤怪兽的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，包含手卡（自身特召）和额外卡组（后续同调召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,0,tp,LOCATION_HAND+ LOCATION_EXTRA)
end
-- 过滤额外卡组中可以进行同调召唤的「次世代」同调怪兽。
function s.syncfilter(c,tp)
	return c:IsSetCard(0x2) and c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil)
end
-- 效果①的处理：将这张卡特殊召唤，之后可以进行1只「次世代」同调怪兽的同调召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与效果相关，并将其以表侧表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 立即刷新场上卡片状态信息，确保后续同调召唤时素材状态正确。
		Duel.AdjustAll()
		-- 检查额外卡组是否存在可同调召唤的「次世代」怪兽，并询问玩家是否进行同调召唤。
		if Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_EXTRA,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否同调召唤？"
			-- 中断当前效果处理，使后续的同调召唤与特殊召唤不视为同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤（同调召唤）的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从额外卡组选择1只满足同调召唤条件的「次世代」同调怪兽。
			local g=Duel.SelectMatchingCard(tp,s.syncfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
			-- 对选定的怪兽进行同调召唤。
			Duel.SynchroSummon(tp,g:GetFirst(),nil)
		end
	end
end
