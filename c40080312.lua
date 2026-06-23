--E・HERO ネビュラ・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·大地鼹鼠」＋「新空间侠·黑暗豹」
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：这张卡从额外卡组的特殊召唤成功的场合发动。自己从卡组抽出对方场上的卡的数量。那之后，选场上1张表侧表示的卡，那个效果直到回合结束时无效。
-- ②：结束阶段发动。这张卡回到额外卡组，场上的卡全部里侧表示除外。
function c40080312.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为89943723,80344569,43237273的3只怪兽为融合素材
	aux.AddFusionProcCode3(c,89943723,80344569,43237273,false,false)
	-- 添加接触融合特殊召唤规则，要求自己场上的符合条件的素材怪兽返回卡组作为召唤条件
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 特殊召唤条件限制：此卡不能从额外卡组特殊召唤（必须在额外卡组中才能特殊召唤）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c40080312.splimit)
	c:RegisterEffect(e1)
	-- 注册「新宇」系列怪兽共通的结束阶段返回卡组效果
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
-- 限制此卡不能从额外卡组特殊召唤，即必须在额外卡组中才能特殊召唤
function c40080312.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 设置结束阶段返回卡组效果的处理分类和操作信息，包括将场上的里侧表示卡除外
function c40080312.set_category(e,tp,eg,ep,ev,re,r,rp)
	e:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	-- 获取场上所有可以除外的里侧表示卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),tp,POS_FACEDOWN)
	-- 设置操作信息，指定要除外的卡的数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 结束阶段返回卡组并处理场上的卡，将所有里侧表示卡除外
function c40080312.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 将此卡送回卡组
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if c:IsLocation(LOCATION_EXTRA) then
		-- 获取场上所有可以除外的里侧表示卡
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tp,POS_FACEDOWN)
		-- 将场上符合条件的卡除外
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end
-- 判断此卡是否从额外卡组特殊召唤成功
function c40080312.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end
-- 设置效果发动时的抽卡数量和目标玩家
function c40080312.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 获取对方场上的卡的数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 设置操作信息，指定要抽卡的数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 发动效果：抽卡并选择场上一张卡使其效果无效
function c40080312.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取对方场上的卡的数量
	local d=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 获取场上所有可以成为无效化目标的卡
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 判断是否成功抽卡且场上存在可无效的卡
	if Duel.Draw(p,d,REASON_EFFECT)~=0 and #g>0 then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 提示玩家选择要无效的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		-- 使目标卡的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标卡的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标卡的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使目标陷阱怪兽的效果无效化
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
