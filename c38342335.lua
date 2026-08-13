--トロイメア・ユニコーン
-- 效果：
-- 卡名不同的怪兽2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合，丢弃1张手卡，以场上1张卡为对象才能发动。那张卡回到卡组。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以抽1张。
-- ②：只要互相连接状态的「幻崩」怪兽存在，自己抽卡阶段的通常抽卡数量变成那些「幻崩」怪兽种类的数量。
function c38342335.initial_effect(c)
	-- 为这张卡添加连接召唤手续：使用2只以上怪兽作为素材，且素材卡名必须各不相同（对应‘卡名不同的怪兽2只以上’）。
	aux.AddLinkProcedure(c,nil,2,nil,c38342335.lcheck)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡连接召唤的场合，丢弃1张手卡，以场上1张卡为对象才能发动。那张卡回到卡组。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38342335,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,38342335)
	e1:SetCondition(c38342335.tdcon)
	e1:SetCost(c38342335.tdcost)
	e1:SetTarget(c38342335.tdtg)
	e1:SetOperation(c38342335.tdop)
	c:RegisterEffect(e1)
	-- ②：只要互相连接状态的「幻崩」怪兽存在，自己抽卡阶段的通常抽卡数量变成那些「幻崩」怪兽种类的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DRAW_COUNT)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c38342335.drcon)
	e2:SetValue(c38342335.drval)
	c:RegisterEffect(e2)
end
-- 检查作为连接素材的怪兽是否全部卡名不同（对应‘卡名不同的怪兽2只以上’的素材限制）。
function c38342335.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- ①效果的发动条件：这张卡是连接召唤成功时（通过连接召唤方式特殊召唤成功）。
function c38342335.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果的发动代价：丢弃1张手卡。
function c38342335.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手牌中存在可以丢弃的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手卡挑选1张卡丢弃，丢弃原因为代价丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设定①效果的目标与操作信息：选择场上1张卡为对象（可回卡组），设置回卡组操作信息；若这张卡处于互相连接状态，则将效果类别加上抽卡并标记标签1，否则标签0，用于效果处理时决定是否抽卡。
function c38342335.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() end
	-- 取对象合法性检查：确认场上存在1张可以被返回卡组的卡才能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上1张卡作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的处理信息：将1张对象卡返回卡组（回卡组效果）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	if e:GetHandler():GetMutualLinkedGroupCount()>0 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_TODECK)
		e:SetLabel(0)
	end
end
-- 处理①效果：若对象卡仍与效果相关，则将其返回卡组；若返回成功且发动时本卡为互相连接状态，则由玩家选择是否抽1张卡，若选择是则先断开连锁处理再抽卡。
function c38342335.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判定对象卡仍与效果相关，并将其返回卡组（以洗牌方式返回）；同时确认返回操作成功。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		-- 确认本卡发动时处于互相连接状态（标签为1），且玩家可以抽1张卡，才继续抽卡分支。
		and e:GetLabel()==1 and Duel.IsPlayerCanDraw(tp,1)
		-- 询问玩家是否要抽1张卡（对应‘再让自己可以抽1张’的选发效果）。
		and Duel.SelectYesNo(tp,aux.Stringid(38342335,1)) then  --"是否抽卡？"
		-- 中断效果处理，使随后的抽卡视为与之前的回卡组不同时处理，以正确触发时点。
		Duel.BreakEffect()
		if tc:IsLocation(LOCATION_DECK) and tc:IsControler(tp) then
			-- 若对象卡返回的是自己卡组，则洗切卡组。
			Duel.ShuffleDeck(tp)
		end
		-- 让自己抽1张卡（效果抽卡）。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 过滤条件：表侧表示、属于「幻崩」系列、且处于互相连接状态的怪兽。
function c38342335.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x112) and c:GetMutualLinkedGroupCount()>0
end
-- ②效果的适用条件：场上存在至少1只满足条件的互相连接状态的「幻崩」怪兽。
function c38342335.drcon(e)
	-- 统计场上满足条件的「幻崩」怪兽数量是否大于0。
	return Duel.GetMatchingGroupCount(c38342335.drfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)>0
end
-- 计算②效果适用的抽卡数量：场上所有满足条件的互相连接状态的「幻崩」怪兽的卡名种类数。
function c38342335.drval(e)
	-- 获取场上所有满足条件的互相连接状态的表侧「幻崩」怪兽的集合。
	local g=Duel.GetMatchingGroup(c38342335.drfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	return g:GetClassCount(Card.GetCode)
end
