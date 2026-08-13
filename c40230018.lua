--魔導書庫クレッセン
-- 效果：
-- 自己墓地没有名字带有「魔导书」的魔法卡存在的场合才能发动。从卡组选名字带有「魔导书」的魔法卡3种类给对方观看，对方从那之中随机选1张。对方选的1张卡加入自己手卡，剩下的卡回到卡组。「魔导书库 科瑞森」在1回合只能发动1张，这张卡发动的回合，自己不能把名字带有「魔导书」的卡以外的魔法卡发动。
function c40230018.initial_effect(c)
	-- 自己墓地没有名字带有「魔导书」的魔法卡存在的场合才能发动。从卡组选名字带有「魔导书」的魔法卡3种类给对方观看，对方从那之中随机选1张。对方选的1张卡加入自己手卡，剩下的卡回到卡组。「魔导书库 科瑞森」在1回合只能发动1张，这张卡发动的回合，自己不能把名字带有「魔导书」的卡以外的魔法卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40230018,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,40230018+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c40230018.condition)
	e1:SetCost(c40230018.cost)
	e1:SetTarget(c40230018.target)
	e1:SetOperation(c40230018.operation)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于记录本回合是否发动过非「魔导书」的魔法卡（一旦发动过，计数器为1），供发动cost检查使用。
	Duel.AddCustomActivityCounter(40230018,ACTIVITY_CHAIN,c40230018.chainfilter)
end
-- 该过滤器用于上述计数器：当发动的是魔法卡效果（EFFECT_TYPE_ACTIVATE且TYPE_SPELL）且卡名不属于「魔导书」（0x106e）时返回false，使计数器加1；其余情况返回true，不计数。
function c40230018.chainfilter(re,tp,cid)
	return not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and not re:GetHandler():IsSetCard(0x106e))
end
-- 判定一张卡是否为名字带有「魔导书」的魔法卡（字段0x106e且为魔法卡），用于检查墓地是否存在满足条件的卡。
function c40230018.cfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL)
end
-- 发动条件函数：只有自己墓地不存在名字带有「魔导书」的魔法卡时，此卡才能发动。
function c40230018.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在名字带有「魔导书」的魔法卡；不存在（not ...）则条件成立。
	return not Duel.IsExistingMatchingCard(c40230018.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 代价/誓约函数：先检查本回合尚未发动过非「魔导书」魔法卡；随后给自己施加一个持续到结束阶段的誓约效果——本回合不能发动非「魔导书」的魔法卡。
function c40230018.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价确认（chk==0）时，检查自定义活动计数器的值是否为0，即本回合还没有发动过非「魔导书」的魔法卡，以此作为能否发动的前提之一。
	if chk==0 then return Duel.GetCustomActivityCount(40230018,tp,ACTIVITY_CHAIN)==0 end
	-- 这张卡发动的回合，自己不能把名字带有「魔导书」的卡以外的魔法卡发动。从卡组选名字带有「魔导书」的魔法卡3种类给对方观看，对方从那之中随机选1张。对方选的1张卡加入自己手卡，剩下的卡回到卡组。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c40230018.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上面创建的禁止发动效果e1注册到场上，使其对玩家tp生效（本方），持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 作为禁止发动效果的判定函数：如果某个效果是魔法卡的发动，且该魔法卡不是「魔导书」（0x106e），则禁止其发动。
function c40230018.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and not re:GetHandler():IsSetCard(0x106e)
end
-- 筛选函数：选出卡组中满足“名字带有「魔导书」、是魔法卡、且能被加入手卡”的卡，作为检索候选。
function c40230018.filter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 发动时目标检查：确认自己卡组中是否存在至少3种卡名不同的「魔导书」魔法卡（用GetClassCount统计不同卡号数量）；若存在，则设置效果信息：处理时将有1张卡从卡组加入手卡。
function c40230018.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己卡组中所有可作为检索对象的「魔导书」魔法卡集合。
		local g=Duel.GetMatchingGroup(c40230018.filter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=3
	end
	-- 设置操作信息：效果处理时有1张卡会从卡组加入手卡（取对象不确定，targets为nil，count=1，来源位置为卡组），供其他卡/效果进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果处理：再次取得卡组中可检索的「魔导书」魔法卡集合；若仍有至少3种，则让发动者从中选出3张卡名互不相同的卡给对方确认，洗切卡组，再由对方选择其中1张，将该卡加入持有者手卡（其余卡留在卡组）。
function c40230018.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有符合条件的「魔导书」魔法卡集合，供处理阶段使用。
	local g=Duel.GetMatchingGroup(c40230018.filter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 then
		-- 给发动者显示提示：请选择要展示给对方确认的卡，为接下来的选卡过程作准备。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 让发动者从候选集合中选择3张卡名互不相同的「魔导书」魔法卡（不可取消，正好3张），返回选出的卡组。
		local sg1=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
		-- 将选出的3张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg1)
		-- 洗切发动者的卡组，使未被选中的卡回到卡组并随机排序（实现“剩下的卡回到卡组”）。
		Duel.ShuffleDeck(tp)
		-- 给对方玩家显示提示：请选择要加入手卡的卡，用于让对方从3张中指定1张。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg1:Select(1-tp,1,1,nil)
		local tc=tg:GetFirst()
		tc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方选择的卡加入其持有者的手卡（nil表示回到持有者手卡），原因记为效果，从而加入发动者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
