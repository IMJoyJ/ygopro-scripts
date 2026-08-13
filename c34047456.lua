--ギガンティック・サンダークロス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己和对方的除外状态的卡数量差的数量的双方的场上·墓地的怪兽为对象才能发动。那些怪兽除外。那之后，对方可以从自身卡组把1只怪兽特殊召唤。
local s,id,o=GetID()
-- 定义卡片的初始效果注册函数：创建并注册该卡的效果e1，该效果为魔法卡发动效果，包含同名卡1回合1次的使用限制，以及取对象除外双方场上/墓地怪兽、之后对方可从卡组特殊召唤1只怪兽的①效果。
function s.initial_effect(c)
	-- 对应效果原文：这个卡名的卡在1回合只能发动1张。①：以自己和对方的除外状态的卡数量差的数量的双方的场上·墓地的怪兽为对象才能发动。那些怪兽除外。那之后，对方可以从自身卡组把1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义对象筛选函数：卡片必须是怪兽且可以被除外，用于选择可被除外的对象以及判断是否存在满足条件的对象。
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 定义效果发动时的目标选择与合法性判定：先计算双方除外区卡数量差ct，若ct大于0且场上/墓地存在至少ct只符合条件的怪兽则允许发动；发动时从双方场上/墓地选择ct只符合条件的怪兽作为对象，并设置本次除外操作的信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(0x14) and s.filter(chkc) end
	-- 计算自己和对方除外区的卡数量差的绝对值，作为需要选择为对象的怪兽数量。
	local ct=math.abs(Duel.GetFieldGroupCount(tp,LOCATION_REMOVED,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_REMOVED))
	-- 发动合法性检查：必须满足除外区数量差ct>0，且双方场上/墓地存在至少ct只可以被除外的怪兽，效果才可发动。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.filter,tp,0x14,0x14,ct,nil) end
	-- 向己方玩家显示“请选择要除外的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让己方玩家从双方场上（怪兽区域）和墓地选择ct只满足筛选条件的怪兽作为效果对象，这些对象会被自动记为连锁对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,0x14,0x14,ct,ct,nil)
	-- 设置当前连锁的处理信息：本次操作包含除外效果，处理对象为已选择的对象卡g，预计数量为ct，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,ct,0,0)
end
-- 定义卡组特殊召唤的筛选函数：判断卡组中的怪兽是否可以被对方玩家通过该效果特殊召唤（检查召唤条件和苏生限制）。
function s.sfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果处理函数：先获取并除外仍与效果相关的对象卡；若除外成功且对方怪兽区有空位，则对方可选择是否从卡组特殊召唤1只怪兽；若选择是，则从卡组选1只怪兽表侧表示特殊召唤到对方场上。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁发动时选择的对象卡组，并过滤出仍然与当前效果相关的对象（排除已离场或联系重置的卡），作为接下来要除外的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选出的对象卡以表侧表示除外；如果实际除外数量少于1，或对方怪兽区域没有可用空格，则不再进行后续特殊召唤处理。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)<1 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<1 then return end
	-- 从对方卡组中筛选出可以被对方玩家特殊召唤的怪兽卡，形成一个可供对方选择的候选集合sg。
	local sg=Duel.GetMatchingGroup(s.sfilter,tp,0,LOCATION_DECK,nil,e,1-tp)
	-- 判断是否存在可特殊召唤的候选怪兽，并询问对方玩家是否要发动“从卡组特殊召唤1只怪兽”的效果。
	if #sg>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then  --"是否从卡组特殊召唤？"
		-- 向己方玩家（实际是提示选择方）显示“请选择要特殊召唤的卡”的选择提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(1-tp,1,1,nil)
		-- 中断当前效果处理，使后续的特殊召唤处理与之前的除外处理视为不同时处理，形成错开时点。
		Duel.BreakEffect()
		-- 将对方选择的那只怪兽以表侧表示特殊召唤到对方场上，不检查召唤条件且不限制苏生限制（效果允许的特殊召唤）。
		Duel.SpecialSummon(tg,0,1-tp,1-tp,false,false,POS_FACEUP)
	end
end
