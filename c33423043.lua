--異次元の指名者
-- 效果：
-- 宣言1张卡的名称。确认对方手卡，若被宣言的卡在对方手卡中存在，则将其中1张被宣言的卡从游戏中除外；若被宣言的卡未在对方手卡中存在，则自己随机从游戏中除外1张手卡。
function c33423043.initial_effect(c)
	-- 宣言1张卡的名称。确认对方手卡，若被宣言的卡在对方手卡中存在，则将其中1张被宣言的卡从游戏中除外；若被宣言的卡未在对方手卡中存在，则自己随机从游戏中除外1张手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetTarget(c33423043.target)
	e1:SetOperation(c33423043.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件的判定：对方手牌数量大于0，且我方手牌中存在至少1张除本卡以外的卡，满足条件才允许发动。
function c33423043.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌数量是否大于0，即对方有手牌以供确认。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		-- 检查我方手牌中是否存在至少1张除本卡以外的卡，以保证若对方没有宣言的卡时，有手牌可供随机除外。
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 向当前玩家发送选择提示，要求宣言一个卡名（HINTMSG_CODE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 根据预设过滤条件（不能是融合/同调/超量/连接怪兽），让当前玩家宣言一张卡的卡名，并返回其卡号ac。
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡号ac存入当前连锁的目标参数，供效果处理时取出使用。
	Duel.SetTargetParam(ac)
	-- 设置当前连锁的操作信息为CATEGORY_ANNOUNCE，表示本效果包含宣言卡名，供系统及关联效果检测。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果结算：获取发动时宣言的卡名，在对方手牌中检索该卡；若存在则由当前玩家选择其中1张除外，若不存在则从当前玩家手牌中随机选1张除外；最后洗切对方手牌。
function c33423043.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标参数，即发动时宣言的卡名。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 在对方手牌中筛选出所有卡名与宣言卡名一致的卡。
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_HAND,nil,ac)
	-- 获取对方全部手牌。
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 向当前玩家展示对方全部手牌，以确认其中是否存在宣言的卡。
	Duel.ConfirmCards(tp,hg)
	if g:GetCount()>0 then
		-- 提示当前玩家选择要除外的卡（HINTMSG_REMOVE）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的那张宣言卡以表侧表示从游戏中除外。
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		-- 洗切对方手牌，因为处理中确认过对方手牌，需恢复其随机顺序。
		Duel.ShuffleHand(1-tp)
	else
		-- 获取当前玩家自己的手牌，作为随机除外的候选对象。
		local sg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		local dg=sg:RandomSelect(tp,1)
		-- 将随机选出的1张手牌以表侧表示从游戏中除外。
		Duel.Remove(dg,POS_FACEUP,REASON_EFFECT)
		-- 洗切对方手牌（因效果处理中确认过对方手牌，需恢复随机顺序）。
		Duel.ShuffleHand(1-tp)
	end
end
