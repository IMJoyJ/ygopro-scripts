--ヴァイロン・マター
-- 效果：
-- 选择自己墓地存在的3张装备魔法卡发动。选择的卡加入卡组洗切，从以下效果选择1个适用。
-- ●从自己卡组抽1张卡。
-- ●对方场上存在的1张卡破坏。
function c41858121.initial_effect(c)
	-- 选择自己墓地存在的3张装备魔法卡发动。选择的卡加入卡组洗切，从以下效果选择1个适用。●从自己卡组抽1张卡。●对方场上存在的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c41858121.target)
	e1:SetOperation(c41858121.activate)
	c:RegisterEffect(e1)
end
-- 筛选墓地中满足条件的卡：必须是装备魔法卡，且能够返回卡组。
function c41858121.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToDeck()
end
-- 发动合法性判定：确认自己墓地存在至少3张可返回卡组的装备魔法卡，且抽卡或破坏对方场上卡片的可选路线至少有一条成立；同时处理连锁中对象是否为合法对象的校验。
function c41858121.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41858121.filter(chkc) end
	-- 检查是否存在至少3张满足条件的装备魔法卡可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c41858121.filter,tp,LOCATION_GRAVE,0,3,nil)
		-- 并且自己可以进行抽卡（未受到不能抽卡限制）且卡组中有卡，保证抽卡选项可用。
		and ((Duel.IsPlayerCanDraw(tp) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0)
		-- 或者对方场上存在至少1张卡，保证破坏选项可用。
		or Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil))
	end
	-- 向玩家发出选择提示，要求选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择3张满足条件的装备魔法卡，并将它们设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c41858121.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置操作信息：本次效果将要把3张卡返回卡组（对象为g，返回持有者卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
end
-- 效果处理：将连锁对象中仍与效果关联的卡返回持有者卡组并洗牌，然后根据可执行选项让玩家选择抽卡或破坏，并执行对应操作。
function c41858121.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡组，并筛选出仍与该效果相关的卡（未被无效、未离场导致关系重置等）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()<=0 then return end
	-- 将筛选出的卡以效果原因返回持有者卡组，使用SEQ_DECKSHUFFLE表示需要洗切卡组。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 取得刚才实际被返回卡组操作的卡片组。
	local og=Duel.GetOperatedGroup()
	if not og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then return end
	-- 洗切己方卡组（因为卡片返回卡组后需要洗牌）。
	Duel.ShuffleDeck(tp)
	-- 中断当前效果处理，使后续的抽卡/破坏处理视为独立处理，避免与前面的回卡组处理同时进行而错失时点。
	Duel.BreakEffect()
	local op=0
	-- 检测己方是否能够抽1张卡。
	local b1=Duel.IsPlayerCanDraw(tp,1)
	-- 检测对方场上是否存在至少1张卡（任意卡片），以保证破坏选项能够执行。
	local b2=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	-- 进行通用选择提示，准备弹出选项菜单让玩家在抽卡或破坏中选择。
	Duel.Hint(HINT_SELECTMSG,tp,0)
	-- 若抽卡和破坏两个选项均可行，则显示“从自己卡组抽1张卡”和“对方场上存在的1张卡破坏”两个选项，返回选择结果。
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(41858121,0),aux.Stringid(41858121,1))  --"从自己卡组抽1张卡。/对方场上存在的1张卡破坏。"
	-- 若只有抽卡可行，则只提供“从自己卡组抽1张卡”选项，选择结果对应抽卡分支。
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(41858121,0))  --"从自己卡组抽1张卡。"
	-- 若只有破坏可行，则只提供“对方场上存在的1张卡破坏”选项，同时将op设为1，进入破坏分支。
	elseif b2 then Duel.SelectOption(tp,aux.Stringid(41858121,1)) op=1  --"对方场上存在的1张卡破坏。"
	else return end
	if op==0 then
		-- 执行抽卡：己方抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	else
		-- 提示玩家选择要破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的1张卡作为破坏对象。
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 以效果原因破坏所选卡片。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
