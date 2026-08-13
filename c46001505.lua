--王者の鼓動
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●对方战斗阶段才能发动。对方回复1000基本分。那之后，战斗阶段结束。
-- ●对方场上的卡数量比自己场上的卡多，对方把怪兽的效果发动时才能发动。从自己的额外卡组·墓地把1只「红莲魔龙」或「琰魔龙 红莲魔」特殊召唤，那个发动的效果无效并破坏。
local s,id,o=GetID()
-- 定义卡的初始化函数，将“王者的鼓动”的发动效果注册给这张卡：设置效果描述、效果类别为特殊召唤/回复/无效/破坏、类型为魔法卡发动、可在自由时点发动、提示相关时点、加入同名卡1回合1次（誓约）限制，并指定目标选择与效果处理函数。
function s.initial_effect(c)
	-- 向系统记录这张卡上记载着卡号39765958（琰魔龙 红莲魔）和70902743（红莲魔龙），使相关“记载卡名”的检索与判定能够生效。
	aux.AddCodeList(c,39765958,70902743)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER+CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_CHAIN_END)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤的过滤函数：筛选卡名为「红莲魔龙」或「琰魔龙 红莲魔」且能够被特殊召唤的卡；同时根据卡所在位置判断是否有足够的怪兽区域可用。
function s.spfilter(c,e,tp)
	return c:IsCode(39765958,70902743) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 如果该卡位于墓地，则要求我方场上存在可用的主怪兽区空格。
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 如果该卡位于额外卡组，则要求我方场上存在可供额外卡组怪兽出场的可用怪兽区空格。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 目标选择函数：分别判定两个可选效果是否满足发动条件——选项1为对方战斗阶段，选项2为对方怪兽效果发动且对方场上卡更多；再通过选项选择让玩家决定发动哪一个，并设置对应的效果类别与操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定选项1的发动条件：当前不是自己的回合且处于战斗阶段，即对方战斗阶段。
	local b1=Duel.GetTurnPlayer()~=tp and Duel.IsBattlePhase()
	-- 获取当前连锁序号，用于检查正在处理的连锁上是否有对方发动的怪兽效果。
	local ch=Duel.GetCurrentChain()
	local b2=false
	local og=Group.CreateGroup()
	local tsp=-1
	local tse=nil
	if e:GetHandler():IsStatus(STATUS_CHAINING) then ch=ch-1 end
	if ch>0 then
		-- 从当前连锁中取得触发玩家和触发效果，以判断是否为对方发动的效果以及具体效果对象。
		tsp,tse=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
		og:AddCard(tse:GetHandler())
		-- 当触发连锁的玩家为对方、触发效果为怪兽效果、且该连锁效果可被无效时，选项2的发动条件成立。
		if tsp==1-tp and tse:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev) then
			-- 判定选项2的卡数条件：对方场上的卡数量多于自己场上的卡数量。
			b2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
				-- 判定选项2的检索条件：存在至少1张满足特殊召唤条件的「红莲魔龙」或「琰魔龙 红莲魔」可供特殊召唤。
				and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp)
		end
	end
	if chk==0 then return b1 or b2 end
	-- 调用选项选择函数，让玩家在“战斗阶段结束”和“特殊召唤”两个可选效果中选择一项发动。
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},  --"战斗阶段结束"
		{b2,aux.Stringid(id,2),2})  --"特殊召唤"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_RECOVER)
		-- 设置操作信息：本次效果将使对方玩家回复1000基本分（恢复类别）。
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_DESTROY)
		-- 设置操作信息：将从自己的墓地或额外卡组特殊召唤1只符合条件的怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
		-- 设置操作信息：将以对方发动效果的那张怪兽卡为对象，使其效果无效（无效类别）。
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,og,1,0,0)
		if tse and tse:GetHandler():IsDestructable() and tse:GetHandler():IsRelateToEffect(tse) then
			-- 设置操作信息：当对方效果怪兽可被破坏且与效果仍有联系时，将其破坏（破坏类别）。
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,og,1,0,0)
		end
	end
end
-- 效果处理函数：根据发动时选择的选项执行——选项1回复对方1000LP并跳过战斗阶段；选项2从墓地/额外选择怪兽特殊召唤，然后无效并破坏对方发动的那个怪兽效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 让对手回复1000基本分，仅当回复成功执行（大于0）时才继续后续跳过战斗阶段的操作。
		if Duel.Recover(1-tp,1000,REASON_EFFECT)>0 then
			-- 中断当前效果处理，使得回复基本分与跳过战斗阶段作为不同步骤处理，避免错过相关时点。
			Duel.BreakEffect()
			-- 跳过对方的战斗阶段，使战斗阶段强制结束。
			Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		end
	else
		-- 显示特殊召唤的选择提示，提示内容为“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的墓地或额外卡组中选取1张满足特殊召唤条件且不受王家长眠之谷影响的「红莲魔龙/琰魔龙 红莲魔」。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
		-- 若成功选取并且以表侧表示特殊召唤成功，则继续执行无效并破坏对方效果的后续处理。
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 获取当前连锁序号，此时本卡的效果正在处理，对方发动的那组效果在前一个连锁。
			local ch=Duel.GetCurrentChain()
			-- 获取前一个连锁（即对方发动效果）的触发效果对象，用于进行无效和破坏。
			local tse=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_EFFECT)
			-- 无效对方那个连锁的效果，并确认该效果怪兽仍与其效果保持关联（没有离场或关系被重置）。
			if Duel.NegateEffect(ch-1) and tse:GetHandler():IsRelateToEffect(tse) then
				-- 将对方发动效果的那只怪兽卡破坏。
				Duel.Destroy(tse:GetHandler(),REASON_EFFECT)
			end
		end
	end
end
