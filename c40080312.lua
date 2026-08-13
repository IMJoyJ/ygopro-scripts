--E・HERO ネビュラ・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·大地鼹鼠」＋「新空间侠·黑暗豹」
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：这张卡从额外卡组的特殊召唤成功的场合发动。自己从卡组抽出对方场上的卡的数量。那之后，选场上1张表侧表示的卡，那个效果直到回合结束时无效。
-- ②：结束阶段发动。这张卡回到额外卡组，场上的卡全部里侧表示除外。
function c40080312.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册以卡号89943723（元素英雄 新宇侠）、80344569（新空间侠·大地鼹鼠）、43237273（新空间侠·黑暗豹）为融合素材的融合召唤手续。
	aux.AddFusionProcCode3(c,89943723,80344569,43237273,false,false)
	-- 注册接触融合特殊召唤手续：素材仅限己方场上、可作为融合素材且能回到卡组/额外卡组的卡，素材处理为送回持有者卡组并洗牌，实现“让自己场上的上记卡回到卡组才能从额外卡组特殊召唤（不需要「融合」）”。
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 「元素英雄 新宇侠」＋「新空间侠·大地鼹鼠」＋「新空间侠·黑暗豹」让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c40080312.splimit)
	c:RegisterEffect(e1)
	-- 启用新空间融合怪兽通用的结束阶段回额外卡组效果，并关联②效果的处理函数retop和效果类别设置函数set_category，用于实现“②：结束阶段发动。这张卡回到额外卡组，场上的卡全部里侧表示除外。”
	aux.EnableNeosReturn(c,c40080312.retop,c40080312.set_category)
	-- ①：这张卡从额外卡组的特殊召唤成功的场合发动。自己从卡组抽出对方场上的卡的数量。那之后，选场上1张表侧表示的卡，那个效果直到回合结束时无效。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(40080312,1))  --"请选择要无效的卡"
	e5:SetCategory(CATEGORY_DRAW+CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c40080312.drcon)
	e5:SetTarget(c40080312.drtg)
	e5:SetOperation(c40080312.drop)
	c:RegisterEffect(e5)
end
c40080312.material_setcode=0x8
-- 特殊召唤条件判定：当前卡不在额外卡组时才允许特殊召唤；在额外卡组时禁止被其他效果特殊召唤，从而限定该卡必须通过正规融合/接触融合手续从额外卡组出场，并保留苏生限制后的正常特殊召唤。
function c40080312.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 设置②效果的处理类别为回卡组+除外，并收集场上所有能被里侧表示除外的卡（不包括自身）作为操作信息，用于系统识别和判定该效果。
function c40080312.set_category(e,tp,eg,ep,ev,re,r,rp)
	e:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	-- 获取双方场上所有可以里侧表示除外、且不是这张卡自身的卡，作为②效果中“场上的卡全部里侧表示除外”的预定对象集合。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),tp,POS_FACEDOWN)
	-- 将当前连锁的操作信息设为除外类别：预定除外的卡组为g，数量为#g，不对应特定玩家和位置（因为是全体不取对象除外），供系统记录和时点判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- ②效果处理：若这张卡仍关联此效果且表侧表示，则先将这张卡送回持有者卡组（额外卡组怪兽回额外卡组）并洗牌；若成功回到额外卡组，再将场上所有可里侧除外的卡以里侧表示除外。
function c40080312.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 将这张卡以效果原因送回持有者卡组（作为额外卡组怪兽会回到额外卡组），并标记需要洗牌。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if c:IsLocation(LOCATION_EXTRA) then
		-- 获取双方场上所有可以里侧表示除外的卡（不排除任何卡），用于②效果中除外全场的对象。
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tp,POS_FACEDOWN)
		-- 将场上所有可除外的卡以里侧表示除外，执行“场上的卡全部里侧表示除外”。
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end
-- ①效果的发动条件：这张卡从额外卡组特殊召唤成功（特殊召唤前所在区域为额外卡组）。
function c40080312.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end
-- ①效果发动时：将目标玩家设为自己，统计对方场上卡的数量作为抽卡张数，并设置抽卡效果的操作信息。
function c40080312.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为自己，以便在处理阶段获取抽卡的玩家。
	Duel.SetTargetPlayer(tp)
	-- 获取对方场上的卡数量，作为要抽的卡的数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 设置抽卡效果的操作信息：目标玩家为自己，参数记录对方场上卡的数量作为抽卡张数。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- ①效果处理：先获取目标玩家和当前对方场上卡数作为抽卡数，再取得场上所有可无效化的卡；执行抽卡，若抽卡成功且存在可无效的卡，则中断效果处理，让玩家选择1张表侧表示的卡，将其相关连锁无效，并使其效果直到回合结束时无效（陷阱怪兽另加无效其陷阱怪兽化）。
function c40080312.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从连锁信息中取出之前设置的目标玩家（自己），作为抽卡玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算当前对方场上卡的数量，作为实际抽卡张数（以效果处理时的数量为准）。
	local d=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 获取场上所有表侧表示且能被无效化效果的卡（包含怪兽、魔法、陷阱），供玩家选择1张来无效。
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 执行抽卡，若实际抽到了d张卡且场上存在可无效的卡，则继续进行后续无效处理；否则不处理。
	if Duel.Draw(p,d,REASON_EFFECT)~=0 and #g>0 then
		-- 中断当前效果处理，将抽卡与后续无效操作分开处理，以匹配“那之后”的时序。
		Duel.BreakEffect()
		-- 向己方玩家显示选择提示“请选择要无效的卡”，并设定选择类型为无效化。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		-- 将所选卡相关的连锁（包括其已发动的效果）无效化，重置时点为回合结束时。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那个效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那个效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那个效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
