--伍世壊心像
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只「末那愚子族」怪兽或者「维萨斯-斯塔弗罗斯特」给对方观看才能发动。自己从卡组抽2张。那之后，选1张手卡回到卡组最下面。
-- ②：把墓地的这张卡除外，以自己场上1只攻击力1500/守备力2100的怪兽为对象才能发动。那只怪兽直到回合结束时当作调整使用。
local s,id,o=GetID()
-- 定义本卡初始化效果注册函数：记录关联卡名，并创建注册①（展示手卡抽2回1）和②（墓地除外变调整）两个效果。
function s.initial_effect(c)
	-- 记录这张卡上记载了卡号56099748（维萨斯-斯塔弗罗斯特）的卡名，用于关联字段或检索判断。
	aux.AddCodeList(c,56099748)
	-- ①：把手卡1只「末那愚子族」怪兽或者「维萨斯-斯塔弗罗斯特」给对方观看才能发动。自己从卡组抽2张。那之后，选1张手卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只攻击力1500/守备力2100的怪兽为对象才能发动。那只怪兽直到回合结束时当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变成调整"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价为把墓地的这张卡除外（使用aux.bfgcost实现代价过滤与支付）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tuntg)
	e2:SetOperation(s.tunop)
	c:RegisterEffect(e2)
end
-- 定义代价筛选函数：判断手卡中的卡是否为维萨斯-斯塔弗罗斯特，或是末那愚子族怪兽，且当前未公开，满足条件即可作为展示代价。
function s.cfilter(c)
	local b1=c:IsCode(56099748)
	local b2=c:IsSetCard(0x190) and c:IsType(TYPE_MONSTER)
	return not c:IsPublic() and (b1 or b2)
end
-- ①效果的代价操作：从手卡选择1张符合条件的卡，给对方确认后洗切手卡，完成“给对方观看”的发动代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己手卡存在至少1张符合展示条件的卡，否则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出“请选择给对方确认的卡”的提示，并设置选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡选择1张符合条件的卡（维萨斯或末那愚子族怪兽），作为展示给对方确认的代价卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手卡展示给对方玩家确认，满足“给对方观看”的发动条件。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切手牌，避免展示操作暴露其他手牌顺序。
	Duel.ShuffleHand(tp)
end
-- ①效果的发动目标设定：将对象玩家设为自身、抽卡数设为2，并登记抽卡与回卡组的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认当前玩家可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁的对象玩家为当前玩家tp，即抽卡动作的受益者。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的对象参数为2，表示抽卡数量。
	Duel.SetTargetParam(2)
	-- 登记抽卡效果的操作信息：玩家tp将抽2张卡，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 登记回卡组效果的操作信息：预计从玩家tp的手卡选1张返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：抽2张卡；若抽卡成功，则洗手牌，再选择1张手卡返回卡组最下面。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的对象玩家p和抽卡数量d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，并判断是否实际抽到2张。
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		-- 抽卡后洗切玩家p的手牌。
		Duel.ShuffleHand(p)
		-- 弹出“请选择要返回卡组的卡”的提示，用于后续选择。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从手卡中选择1张可以返回卡组的卡（不取对象，效果处理时选择）。
		local sg=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,1,1,nil)
		if #sg>0 then
			-- 中断当前效果，使回卡组操作与抽卡处理视为不同时处理，避免时点冲突。
			Duel.BreakEffect()
			-- 将选中的手卡以效果原因送回持有者卡组最下面（SEQ_DECKBOTTOM），实现“回到卡组最下面”。
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
-- 定义②效果的对象筛选条件：表侧表示、攻击力1500且守备力2100、且不是调整的怪兽。
function s.tfilter(c)
	return not c:IsType(TYPE_TUNER) and c:IsFaceup() and c:IsAttack(1500) and c:IsDefense(2100)
end
-- ②效果的取对象目标设定：选择自己场上1只满足攻击力1500/守备力2100的表侧表示怪兽作为对象。
function s.tuntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tfilter(chkc) end
	-- 发动合法性检查：确认自己场上存在至少1只符合条件的对象怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出“请选择效果的对象”的提示，用于选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己场上选择1只符合条件的表侧表示怪兽，并登记为效果的对象。
	Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：取得对象怪兽，若其仍与效果相关且表侧表示，则赋予其“直到回合结束时当作调整使用”的效果。
function s.tunop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果所选择的唯一对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽直到回合结束时当作调整使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
