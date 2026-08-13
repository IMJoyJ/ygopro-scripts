--戦刀匠サイバ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只6星以下的战士族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这张卡在这个回合不能作为同调素材。
-- ②：对方主要阶段才能发动。用包含战士族怪兽的自己场上的怪兽为素材进行同调召唤。
local s,id,o=GetID()
-- 初始化效果函数：为卡片添加同调召唤手续（调整+调整以外怪兽1只以上），并注册①和②两个效果。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：以自己墓地1只6星以下的战士族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这张卡在这个回合不能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从墓地特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段才能发动。用包含战士族怪兽的自己场上的怪兽为素材进行同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"同调召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.sccon)
	e2:SetTarget(s.sctg)
	e2:SetOperation(s.scop)
	c:RegisterEffect(e2)
end
-- 定义①效果可特殊召唤的墓地怪兽条件：6星以下、战士族、且能被效果特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动条件与取对象判定：确认选择的对象是自己墓地满足条件的战士族怪兽；并检查场上是否有空位及墓地是否存在至少1只符合条件的对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 发动合法性检查：自己主要怪兽区有空闲格位时才能发动特殊召唤效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地存在至少1只满足条件且能成为对象的战士族怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的战士族怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁将进行1只怪兽的特殊召唤（对象为已选择的卡）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：确认对象仍关联且不受王家长眠之谷影响后，将其表侧特殊召唤；给该怪兽附加效果无效化状态；若本卡仍在场，则给本卡附加本回合不能作为同调素材的制约。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时所选择的墓地怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 检查对象仍与效果关联、不受王家长眠之谷影响，并尝试将其以表侧表示特殊召唤到自己的怪兽区。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤手续，确认特殊召唤成功。
	Duel.SpecialSummonComplete()
	if c:IsRelateToEffect(e) then
		-- 这张卡在这个回合不能作为同调素材。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3,true)
	end
end
-- ②效果的发动条件函数：仅在对方主要阶段且当前是主要阶段时才能发动。
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前处于主要阶段且回合玩家不是自己，即满足“对方主要阶段”的条件。
	return Duel.IsMainPhase() and Duel.GetTurnPlayer()~=tp
end
-- 定义同调素材中必须包含的战士族怪兽：表侧表示且种族为战士族的怪兽。
function s.mfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_MONSTER) and c:IsFaceupEx()
end
-- 定义素材组的合法性：素材组包含至少1只战士族怪兽、符合手牌同调素材规则，且等级合计满足同调怪兽的召唤要求。
function s.syncheck(g,tp,syncard)
	-- 检查素材组中是否有战士族怪兽、通过手牌同调辅助检查，且该同调怪兽可以这些素材进行同调召唤。
	return g:IsExists(s.mfilter,1,nil) and aux.SynMixHandCheck(g,tp,syncard) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
-- 筛选额外卡组中的同调怪兽候选：必须是同调怪兽，且能用当前素材组成至少2只怪兽的合法同调素材组。
function s.scfilter(c,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	-- 设置临时的等级校验辅助函数，用于核对素材组等级和与同调怪兽等级一致。
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(s.syncheck,2,#mg,tp,c)
	-- 清除临时等级校验辅助函数，恢复默认判断。
	aux.GCheckAdditional=nil
	return res
end
-- ②效果发动条件与选择：确认可特殊召唤；获取可用同调素材（可能包含手牌）；检查额外卡组是否存在可用素材同调召唤的同调怪兽；发动时向对方显示效果描述并设置特殊召唤操作信息。
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若当前玩家不能进行特殊召唤，则不能发动②效果。
		if not Duel.IsPlayerCanSpecialSummon(tp) then return false end
		-- 获取当前玩家场上可用的同调素材（场上怪兽）。
		local mg=Duel.GetSynchroMaterial(tp)
		if mg:IsExists(Card.GetHandSynchro,1,nil) then
			-- 若场上存在支持手牌同调的效果，则获取手牌中的所有怪兽作为额外候选素材。
			local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
			if mg2:GetCount()>0 then mg:Merge(mg2) end
		end
		-- 检查额外卡组是否存在至少1只同调怪兽，使得②效果能够发动。
		return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	-- 向对方玩家提示已选择发动该效果，并展示②效果的文字。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次效果将从额外卡组特殊召唤1只同调怪兽（具体怪兽在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：重新获取同调素材（可能包含手牌）；筛选可同调召唤的同调怪兽；让玩家选择要同调召唤的怪兽及素材组，随后进行同调召唤。
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家可用的同调素材。
	local mg=Duel.GetSynchroMaterial(tp)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		-- 若存在手牌同调，则获取手牌怪兽以扩充素材候选。
		local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	-- 筛选额外卡组中所有能用当前素材进行同调召唤的同调怪兽。
	local g=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要同调召唤的同调怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 提示玩家选择要作为同调素材的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local tg=mg:SelectSubGroup(tp,s.syncheck,false,2,#mg,tp,sc)
		-- 使用选中的素材组进行同调召唤，特殊召唤选择的同调怪兽。
		Duel.SynchroSummon(tp,sc,nil,tg,#tg-1,#tg-1)
	end
end
