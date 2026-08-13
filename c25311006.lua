--三戦の才
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这个回合的自己主要阶段对方是已把怪兽的效果发动的场合，可以从以下效果选择1个发动。
-- ●自己抽2张。
-- ●对方场上1只怪兽的控制权直到结束阶段得到。
-- ●把对方手卡确认，选那之内的1张回到卡组。
function c25311006.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这个回合的自己主要阶段对方是已把怪兽的效果发动的场合，可以从以下效果选择1个发动。●自己抽2张。●对方场上1只怪兽的控制权直到结束阶段得到。●把对方手卡确认，选那之内的1张回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,25311006+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c25311006.condition)
	e1:SetTarget(c25311006.target)
	e1:SetOperation(c25311006.operation)
	c:RegisterEffect(e1)
	-- 注册自定义活动计数器，用于记录对方在本回合主要阶段发动怪兽效果的行为，以作为三战之才的发动条件。
	Duel.AddCustomActivityCounter(25311006,ACTIVITY_CHAIN,c25311006.chainfilter)
end
-- 活动计数器的过滤函数：当前玩家发动效果时，若该效果为怪兽效果且当前处于主要阶段，则返回false使计数器增加；否则不计数。
function c25311006.chainfilter(re,tp,cid)
	-- 获取当前游戏阶段，用于判断是否处于主要阶段（主1或主2）。
	local ph=Duel.GetCurrentPhase()
	return not (re:IsActiveType(TYPE_MONSTER) and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2))
end
-- 三战之才的发动条件函数：检查对方的怪兽效果发动计数器是否为非0，即对方是否已在本回合自己主要阶段发动过怪兽效果。
function c25311006.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 查询对方（1-tp）的怪兽效果发动计数器是否非0，若不为0则满足发动条件。
	return Duel.GetCustomActivityCount(25311006,1-tp,ACTIVITY_CHAIN)~=0
end
-- 目标选择与效果选择函数：先判断抽卡、获得控制权、回卡组三个选项是否可行，再让玩家选择其中一个，并根据所选选项设置效果类别、属性和操作信息。
function c25311006.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己是否可以抽2张卡，作为“自己抽2张”选项的可行性判断。
	local b1=Duel.IsPlayerCanDraw(tp,2)
	-- 检查对方场上是否存在至少1只可变更控制权的怪兽，作为“获得控制权”选项的可行性判断。
	local b2=Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
	-- 检查对方手卡是否至少有1张卡，作为“确认手卡并选1张返回卡组”选项的可行性判断。
	local b3=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
	if chk==0 then return b1 or b2 or b3 end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(25311006,0)  --"自己抽2张"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(25311006,1)  --"对方场上1只怪兽的控制权直到结束阶段得到"
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(25311006,2)  --"把对方手卡确认，选那之内的1张回到卡组"
		opval[off-1]=3
		off=off+1
	end
	-- 向操作玩家显示“请选择要发动的效果”的提示，为后续选项选择做准备。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	-- 让操作玩家从可选的三个效果中做出选择，并返回所选选项的序号。
	local op=Duel.SelectOption(tp,table.unpack(ops))
	e:SetLabel(opval[op])
	if opval[op]==1 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		-- 将当前连锁的对象玩家设为操作玩家自身，表示抽卡效果中的抽卡玩家是自己。
		Duel.SetTargetPlayer(tp)
		-- 将当前连锁的对象参数设为2，表示抽卡数量为2张。
		Duel.SetTargetParam(2)
		-- 设置抽卡效果的处理信息，声明该效果为抽卡分类，处理时由玩家tp抽2张卡。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	elseif opval[op]==2 then
		e:SetCategory(CATEGORY_CONTROL)
		e:SetProperty(0)
		-- 获取对方场上的全部怪兽，并筛选出其中可变更控制权的怪兽，作为控制权改变效果的可能对象。
		local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE):Filter(Card.IsControlerCanBeChanged,nil)
		-- 设置控制权改变效果的处理信息，声明该效果为控制权变更分类，可能处理的对象为g中的1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	elseif opval[op]==3 then
		e:SetCategory(CATEGORY_TODECK)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		-- 将当前连锁的对象玩家设为操作玩家自身，表示在“确认手卡并选1张返回卡组”效果中由自己进行确认和选择。
		Duel.SetTargetPlayer(tp)
		-- 设置回卡组效果的处理信息，声明该效果为返回卡组分类，处理时从对方（1-tp）手卡中选1张返回卡组。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,1-tp,LOCATION_HAND)
	end
end
-- 效果处理入口：根据发动时选择并存储在效果标签中的选项编号，分派到对应的抽卡、控制权或回卡组处理函数。
function c25311006.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		c25311006.draw(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		c25311006.control(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then
		c25311006.todeck(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 抽卡效果的实际处理：从连锁信息中取出目标玩家和抽卡数量，执行抽卡。
function c25311006.draw(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁信息中的目标玩家和目标参数，分别作为抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 获得控制权效果的实际处理：从对方场上选择1只可变更控制权的怪兽，使其控制权直到结束阶段转移给自己。
function c25311006.control(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要改变控制权的怪兽”的提示，引导玩家选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让操作玩家从对方场上选择1只可变更控制权的怪兽，作为控制权转移的对象。
	local g=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		-- 为选中的怪兽显示选为对象的动画，并记录该卡已被选为对象。
		Duel.HintSelection(g)
		-- 将选中的怪兽的控制权转移给操作玩家，持续到结束阶段。
		Duel.GetControl(g:GetFirst(),tp,PHASE_END,1)
	end
end
-- 回卡组效果的实际处理：先确认对方手卡，再由操作者选择其中1张返回卡组，最后洗切对方手卡。
function c25311006.todeck(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家，用于获取对方手卡和作为选择手牌的主体。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取玩家p的整手手卡，用于确认和选择。
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if #g>0 then
		-- 将玩家p的手卡展示给其确认，使操作者能看到对方手卡内容。
		Duel.ConfirmCards(p,g)
		-- 显示“请选择要返回卡组的卡”的提示，引导操作者从已确认的手卡中选择1张。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:FilterSelect(p,Card.IsAbleToDeck,1,1,nil)
		if #sg<=0 then return end
		-- 将选中的卡以效果原因返回持有者卡组，使用SEQ_DECKSHUFFLE表示返回后需要洗牌。
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切对方（1-p）的手卡，以完成“选1张回到卡组”后的手牌洗切。
		Duel.ShuffleHand(1-p)
	end
end
