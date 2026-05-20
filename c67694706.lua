--魔溶生物ゾル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的陷阱卡的效果让怪兽特殊召唤的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果从墓地特殊召唤的这张卡从场上离开的场合除外。
-- ②：对方战斗阶段，可以从以下效果选择1个发动。
-- ●用包含这张卡的自己场上的怪兽为素材进行同调召唤。
-- ●用包含这张卡的自己场上的怪兽为素材进行超量召唤。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果
function s.initial_effect(c)
	-- ①：自己的陷阱卡的效果让怪兽特殊召唤的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果从墓地特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方战斗阶段，可以从以下效果选择1个发动。●用包含这张卡的自己场上的怪兽为素材进行同调召唤。●用包含这张卡的自己场上的怪兽为素材进行超量召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"进行特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.sccon)
	e2:SetTarget(s.sctarg)
	e2:SetOperation(s.scop)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查特殊召唤的怪兽是否是由自己陷阱卡的效果特殊召唤的
function s.cfilter(c,tp)
	local typ,se,sp=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_REASON_EFFECT,SUMMON_INFO_REASON_PLAYER)
	return se and typ&TYPE_TRAP~=0 and se:IsActivated() and sp==tp
end
-- ①效果的发动条件：检查特殊召唤的怪兽中是否存在满足由自己的陷阱卡效果特殊召唤的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ①效果的靶向处理：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的运行处理：将自身特殊召唤，若从墓地特殊召唤则添加离场除外的约束
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡片是否仍与效果相关，且不受王家之谷影响，并成功以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and c:IsSummonLocation(LOCATION_GRAVE) then
		-- 这个效果从墓地特殊召唤的这张卡从场上离开的场合除外。对方战斗阶段，可以从以下效果选择1个发动。●用包含这张卡的自己场上的怪兽为素材进行同调召唤。●用包含这张卡的自己场上的怪兽为素材进行超量召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
-- ②效果的发动条件：对方的战斗阶段
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即必须是对方回合）
	if Duel.GetTurnPlayer()==tp then return false end
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤条件：检查额外卡组的怪兽是否能以包含这张卡在内的场上怪兽为素材进行超量召唤
function s.exgfilter(c,mg,mc)
	return mg:CheckSubGroup(s.exgselect,1,#mg,c,mc)
end
-- 检查选定的怪兽组是否包含这张卡，并且能作为素材超量召唤指定的额外怪兽
function s.exgselect(g,exc,mc)
	return g:IsContains(mc) and exc:IsXyzSummonable(g,#g,#g)
end
-- ②效果的靶向处理：检查是否能进行同调召唤或超量召唤，并让玩家选择其中一个效果发动
function s.sctarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己场上所有表侧表示的怪兽作为潜在的召唤素材
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 过滤出额外卡组中可以使用包含这张卡在内的场上怪兽进行超量召唤的怪兽
	local exg=Duel.GetMatchingGroup(s.exgfilter,tp,LOCATION_EXTRA,0,nil,mg,c)
	-- 检查额外卡组中是否存在可以使用包含这张卡在内的场上怪兽进行同调召唤的怪兽
	local b1=Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c)
	local b2=#exg>0
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 让玩家在“进行同调召唤”和“进行超量召唤”之间选择一个效果
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"进行同调召唤/进行超量召唤"
	elseif b1 then
		-- 只能进行同调召唤时，强制选择“进行同调召唤”选项
		op=Duel.SelectOption(tp,aux.Stringid(id,2))  --"进行同调召唤"
	else
		-- 只能进行超量召唤时，强制选择“进行超量召唤”选项（返回值加1以匹配选项索引）
		op=Duel.SelectOption(tp,aux.Stringid(id,3))+1  --"进行超量召唤"
	end
	e:SetLabel(op)
	-- 设置连锁处理中的操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的运行处理：根据玩家的选择，使用包含这张卡的场上怪兽为素材，进行同调召唤或超量召唤
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if e:GetLabel()==0 then
		-- 过滤出额外卡组中可以使用包含这张卡在内的场上怪兽进行同调召唤的怪兽组
		local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
		if g:GetCount()>0 then
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 以这张卡为素材，对选定的怪兽进行同调召唤
			Duel.SynchroSummon(tp,sg:GetFirst(),c)
		end
	else
		-- 重新获取自己场上所有表侧表示的怪兽作为超量素材的候选
		local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		-- 重新过滤出额外卡组中可以使用包含这张卡在内的场上怪兽进行超量召唤的怪兽组
		local exg=Duel.GetMatchingGroup(s.exgfilter,tp,LOCATION_EXTRA,0,nil,mg,c)
		if exg:GetCount()>0 then
			-- 提示玩家选择要特殊召唤的超量怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=exg:Select(tp,1,1,nil):GetFirst()
			-- 提示玩家选择要作为超量素材的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			local msg=mg:SelectSubGroup(tp,s.exgselect,false,1,#mg,sc,c)
			-- 使用选定的怪兽作为素材，对选定的怪兽进行超量召唤
			Duel.XyzSummon(tp,sc,msg,#msg,#msg)
		end
	end
end
