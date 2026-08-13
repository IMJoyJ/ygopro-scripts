--アルトメギア・メセナ－覚醒－
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1只「神艺」怪兽或「无垢者 米底乌斯」特殊召唤。这个回合，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化，在那次融合召唤成功时对方不能把卡的效果发动。
-- ②：把墓地的这张卡除外，以自己场上1只「神艺」怪兽为对象才能发动。那只怪兽回到手卡·额外卡组，对方场上1张卡破坏。
local s,id,o=GetID()
-- s.initial_effect 初始化函数：注册两个效果。e1为①的发动效果（从卡组特殊召唤并附加融合召唤保护），e2为②的墓地诱发即时效果（除外自身，回手/额外并破坏对方场上1张卡）。两个效果通过 SetCountLimit(1,id) 共享同一回合1次的使用次数。
function s.initial_effect(c)
	-- 将卡号97556336（无垢者 米底乌斯）记录为本卡记载的卡名，使涉及‘记载卡名’的检索/判断能识别该卡。
	aux.AddCodeList(c,97556336)
	-- ①：从卡组把1只「神艺」怪兽或「无垢者 米底乌斯」特殊召唤。这个回合，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化，在那次融合召唤成功时对方不能把卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「神艺」怪兽为对象才能发动。那只怪兽回到手卡·额外卡组，对方场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- 设置效果②的发动代价：将墓地的这张卡除外（aux.bfgcost 实现除外自身作为Cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- s.spfilter 是特殊召唤对象过滤函数：卡名属于「神艺」字段或是「无垢者 米底乌斯」，且能够被效果特殊召唤。
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0x1cd) or c:IsCode(97556336)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件判定：只有在己方主要怪兽区有空位，且卡组中存在满足 s.spfilter 的怪兽时，该卡才能发动。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「神艺」怪兽或「无垢者 米底乌斯」。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将特殊召唤卡组中的1只怪兽，供连锁检测和时点判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数：先从卡组选择1只符合条件的怪兽特殊召唤；随后注册‘本回合自己发动的包含融合召唤的效果不会被无效化’以及‘那次融合召唤成功时对方不能发动卡的效果’的场合限制效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认己方主要怪兽区仍存在空格。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向操作者显示‘请选择要特殊召唤的卡’的提示，并将选择消息缓存。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足 s.spfilter 的怪兽作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到己方主要怪兽区。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化（EFFECT_CANNOT_INACTIVATE 实现发动保护）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_INACTIVATE)
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述‘融合召唤效果发动不会被无效化’的持续效果注册到当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- 在那次融合召唤成功时对方不能把卡的效果发动（通过监听特殊召唤成功事件来触发连锁限制）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.limcon)
	e2:SetOperation(s.limop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册监听融合召唤成功的事件效果，用于在满足条件时设置对方不能发动卡的效果。
	Duel.RegisterEffect(e2,tp)
	-- 在那次融合召唤成功时对方不能把卡的效果发动（负责在融合召唤成功时检查事件并设置连锁限制，同时在连锁结束时清理相关状态）。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetOperation(s.limop2)
	-- 注册 E3：当连锁结束时调用 s.limop2 清理‘待施加连锁限制’的标志，确保限制只在正确的连锁内生效。
	Duel.RegisterEffect(e3,tp)
end
-- s.efilter 是‘发动不会被无效化’的过滤条件：仅当己方玩家发动的效果包含融合召唤类别时，该发动才不被无效化。
function s.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 获取正在连锁的效果及其发动玩家，用于判断该效果是否为己方发动且属于融合召唤类效果。
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsHasCategory(CATEGORY_FUSION_SUMMON)
end
-- s.limfilter 判断一只怪兽是否为通过包含融合召唤的效果而被融合召唤成功：由己方玩家进行融合召唤，并且该特殊召唤在效果类别上属于融合召唤。
function s.limfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_FUSION)
		and c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT):IsHasCategory(CATEGORY_FUSION_SUMMON)
end
-- s.limcon 是融合召唤成功事件的触发条件：本次特殊召唤成功的事件中至少存在1只满足‘由己方通过效果融合召唤’的怪兽。
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.limfilter,1,nil,tp)
end
-- s.limop 为融合召唤成功时的处理：若此时不再处于连锁中（融合召唤成功作为独立时点），直接设置连锁限制使对方无法发动效果；若融合召唤本身位于连锁1，则登记延迟监听，在当前连锁结束后的下一个连锁开始时再施加限制。
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果融合召唤成功时当前不在任何连锁中，则立即从此时点开始限制对方发动卡的效果。
	if Duel.GetCurrentChain()==0 then
		-- 设置直到连锁结束为止的连锁限制：只允许己方玩家（tp）发动效果，对方不能发动效果。
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 如果融合召唤成功时当前正是连锁1（即融合召唤作为连锁1被处理），则需要等待后续连锁继续时再施加限制。
	elseif Duel.GetCurrentChain()==1 then
		-- 为己方玩家注册临时标志，表示‘待施加融合召唤成功时的对方效果发动限制’，该标志会在适当时候被读取并清除。
		Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- ①后半句‘在那次融合召唤成功时对方不能把卡的效果发动’的连锁限制维护逻辑（通过监听 EVENT_CHAINING/EVENT_BREAK_EFFECT 在合适的连锁节点施加/重置限制）；以及②的完整效果：‘把墓地的这张卡除外，以自己场上1只「神艺」怪兽为对象才能发动。那只怪兽回到手卡·额外卡组，对方场上1张卡破坏。’的实现代码。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册当连锁开始/效果被无效时重置标志的监听效果，用于在合适的时机恢复可发动状态。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册克隆的 EVENT_BREAK_EFFECT 监听效果，在连锁断开时也执行重置，确保标志不会残留。
		Duel.RegisterEffect(e2,tp)
	end
end
-- s.resetop：重置己方玩家的待施加限制标志，并销毁触发重置监听的效果。
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	-- 清除己方玩家的‘待施加限制’标志，防止后续误用。
	Duel.ResetFlagEffect(tp,id)
	e:Reset()
end
-- s.limop2：在连锁结束时检查是否仍有待施加的限制标志；若有，则立即设置连锁限制；最后总是清除该标志。
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方玩家是否存在‘待施加限制’标志，以决定是否需要在连锁结束时补设限制。
	if Duel.GetFlagEffect(tp,id)~=0 then
		-- 在连锁结束时补设‘直到连锁结束，对方不能发动效果’的连锁限制。
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	-- 清除己方玩家的‘待施加限制’标志，完成收尾。
	Duel.ResetFlagEffect(tp,id)
end
-- s.chainlm 为连锁限制条件：仅允许连锁的发动玩家是己方玩家（tp）时才能继续发动效果，从而禁止对方发动效果。
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- s.thfilter 是效果②的取对象过滤函数：选择自己场上表侧表示的「神艺」怪兽，且能被加入手卡。
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动条件与取对象判定：检查自己场上是否存在1只可回手的表侧「神艺」怪兽，并且对方场上有至少1张可破坏的卡；若已选择对象则确认其合法。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.thfilter(chkc) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 检查自己场上是否存在至少1只满足条件的表侧「神艺」怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1张可以破坏的卡（用 aux.TRUE 匹配全部卡，后续处理时再实际选择）。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示‘请选择要加入手卡的卡’的提示，用于选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己场上的1只表侧「神艺」怪兽作为效果②的对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：被选择的对象怪兽将加入手卡（或额外卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 获取对方场上的全部卡（作为可能被破坏的对象集合），用于破坏效果的操作信息登记。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：本效果将破坏对方场上1张卡（操作信息中的对象为对方场上所有卡，处理时再选择实际破坏的对象）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
end
-- 效果②的处理函数：取得对象怪兽，若其仍与效果相关且成功回到手卡/额外卡组，则再从对方场上选择1张卡破坏。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果②的目标怪兽（发动时选择的那只「神艺」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽仍与连锁相关且为怪兽，并将其送去持有者手卡；若成功返回手卡/额外卡组，才继续处理破坏。
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND+LOCATION_EXTRA) then
		-- 显示‘请选择要破坏的卡’的提示，让操作者选择对方场上要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上选择1张卡作为破坏对象（选择时使用 aux.TRUE，实际可能有卡，所以数量1）。
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			-- 将选中的破坏对象高亮显示，并标记为被选择对象。
			Duel.HintSelection(g)
			-- 以效果原因破坏选中的卡片。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
