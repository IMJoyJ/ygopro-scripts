--凍てつく呪いの神碑
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这张卡的发动后，下次的自己战斗阶段跳过。
-- ●以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。那之后，从对方卡组上面把3张卡除外。
-- ●从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
local s,id,o=GetID()
-- 注册两个可选效果：e1对应无效对象怪兽并除外对方卡组顶3张，e2对应从额外卡组特召1只神碑怪兽到额外怪兽区；二者通过相同CountLimit(1,id+EFFECT_COUNT_CODE_OATH)实现同名卡1回合只能发动1张，发动后均调用s.skipop跳过下次自己战斗阶段。
function s.initial_effect(c)
	-- ●以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。那之后，从对方卡组上面把3张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"怪兽无效"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ●从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 第一个效果的发动条件与对象选择：需要对方场上有1只可被无效的效果怪兽，且对方卡组顶3张均可除外；选择1只效果怪兽作为对象，并设置从对方卡组顶除外3张的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 若是在连锁处理时确认对象是否合法的chkc分支：检查指定卡位于对方怪兽区、由对方控制且是表侧表示可被无效的效果怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 发动合法性检测：检查对方场上是否存在至少1只满足aux.NegateEffectMonsterFilter（表侧表示可被无效的效果怪兽）的卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		-- 同时确认对方卡组最上方3张卡都能被除外（FilterCount==3），满足“从对方卡组上面把3张卡除外”的发动条件。
		and Duel.GetDecktopGroup(1-tp,3):FilterCount(Card.IsAbleToRemove,nil)==3 end
	-- 向对方玩家提示自己选择了哪个效果，显示该效果的描述文字（无效怪兽并除外卡组）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 向操作者显示“请选择要无效的卡”的文字提示，供后续选择对象使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从对方怪兽区选择1只满足aux.NegateEffectMonsterFilter的效果怪兽作为对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：预定将对方卡组顶部的3张卡除外，用于给其他卡（如星尘龙等）进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,1-tp,LOCATION_DECK)
end
-- 处理第一个效果：若对象仍在场上表侧且与本效果关联并能被无效，则将其相关连锁无效化，并给对象赋予效果无效化效果；随后将对方卡组顶3张表侧除外；最后调用s.skipop设置跳过下次自己战斗阶段。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得该效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与该对象怪兽相关的连锁无效化，并在其变里侧或离场等时重置，确保其效果被彻底无效。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 取得对方卡组最上方的3张卡，准备用于除外。
		local g=Duel.GetDecktopGroup(1-tp,3)
		if #g>0 then
			-- 中断当前效果链，使“无效怪兽”与“除外卡组”两个处理在不同时点进行，避免被关联处理干扰。
			Duel.BreakEffect()
			-- 关闭本次从卡组取出卡片后自动洗牌检查，因为这是按顺序从卡组顶端除外，不应洗切卡组。
			Duel.DisableShuffleCheck()
			-- 将取得的对方卡组顶3张卡以表侧表示从游戏中除外（除外原因：效果）。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
	s.skipop(e,tp)
end
-- 第二个效果的特召筛选：检查额外卡组的卡是否是「神碑」怪兽、能否被当前效果特殊召唤，以及能否被特殊召唤到额外怪兽区。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 额外检查：计算将这张额外卡组怪兽特殊召唤到额外怪兽区（zone=0x60）时，是否还有可用的空格（>0）。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0
end
-- 第二个效果的发动条件与操作信息：确认额外卡组存在满足s.spfilter的「神碑」怪兽；向对方提示选择了该效果，并设置从额外卡组特召1只怪兽的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检测：额外卡组中是否存在至少1只满足s.spfilter条件的「神碑」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向对方玩家提示自己选择了‘从额外卡组特殊召唤神碑怪兽’这一效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：预定从额外卡组进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理第二个效果：从额外卡组选择1只「神碑」怪兽，表侧表示特殊召唤到我方额外怪兽区；随后调用s.skipop设置跳过下次自己战斗阶段。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示“请选择要特殊召唤的卡”的提示，用于后续选择额外卡组中的「神碑」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足s.spfilter条件的「神碑」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽由我方以表侧表示特殊召唤到额外怪兽区域（zone=0x60）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
	end
	s.skipop(e,tp)
end
-- 创建跳过战斗阶段的效果：以誓约（OATH）方式作用于我方；若在己方回合的战斗阶段区间发动，则记录回合数并等到下一次战斗阶段才跳过，否则跳过最近的一次战斗阶段；随后注册该效果。
function s.skipop(e,tp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 获取当前所处阶段，用于判断跳过战斗阶段的具体时机。
		local ph=Duel.GetCurrentPhase()
		-- 这张卡的发动后，下次的自己战斗阶段跳过。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		-- 如果当前是己方回合且处于主要阶段1之后、主要阶段2之前（战斗阶段区间），则说明需要跳过的是‘下一次’（跨回合的）战斗阶段，采用带回合标记的条件处理。
		if Duel.GetTurnPlayer()==tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2 then
			-- 将当前回合数记录到效果中，以便之后判断是否已到达下一次战斗阶段。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(s.skipcon)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
		end
		-- 将跳过战斗阶段的效果注册到场上，持续影响己方玩家。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义跳过战斗阶段效果的发动条件：只有当前回合数与记录回合数不同（即已进入下一次回合）时，才满足跳过条件。
function s.skipcon(e)
	-- 条件判断：当前回合数不等于记录值，表示已经到了‘下次’战斗阶段，应当跳过。
	return Duel.GetTurnCount()~=e:GetLabel()
end
