--逆巻く炎の宝札
-- 效果：
-- 这个卡名在规则上也当作「转生炎兽」卡使用。这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是炎属性怪兽不能召唤·特殊召唤。
-- ①：对方场上的卡数量比自己场上的卡多的场合，以对方场上1只连接怪兽为对象才能发动。自己抽出那只怪兽的连接标记的数量。
function c46898368.initial_effect(c)
	-- 这个卡名在规则上也当作「转生炎兽」卡使用。这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是炎属性怪兽不能召唤·特殊召唤。①：对方场上的卡数量比自己场上的卡多的场合，以对方场上1只连接怪兽为对象才能发动。自己抽出那只怪兽的连接标记的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,46898368+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c46898368.condition)
	e1:SetCost(c46898368.cost)
	e1:SetTarget(c46898368.target)
	e1:SetOperation(c46898368.activate)
	c:RegisterEffect(e1)
	-- 为这张卡注册一个自定义活动计数器（代号46898368），统计玩家进行“召唤”操作后不符合过滤器的次数，用于后续自肃检测。
	Duel.AddCustomActivityCounter(46898368,ACTIVITY_SUMMON,c46898368.counterfilter)
	-- 为这张卡注册一个自定义活动计数器（代号46898368），统计玩家进行“特殊召唤”操作后不符合过滤器的次数，用于后续自肃检测。
	Duel.AddCustomActivityCounter(46898368,ACTIVITY_SPSUMMON,c46898368.counterfilter)
end
-- 计数器过滤器：判断一只怪兽是否为炎属性；若为炎属性则返回true，不会被计数；若非炎属性则返回false，会使对应召唤/特殊召唤计数增加。
function c46898368.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 效果发动条件判断函数：仅在满足规则条件时才允许发动。
function c46898368.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回对方场上的卡数量是否多于我方场上的卡数量，即对方场上的卡数>自己场上的卡数。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
-- 效果发动cost函数：检查本回合是否没有进行过非炎属性怪兽的召唤/特殊召唤，若满足则支付cost并设置本回合的召唤/特殊召唤自肃效果。
function c46898368.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在cost检查阶段确认本回合自定义召唤计数为0，即本回合尚未召唤过非炎属性怪兽。
	if chk==0 then return Duel.GetCustomActivityCount(46898368,tp,ACTIVITY_SUMMON)==0
		-- 同时确认本回合自定义特殊召唤计数也为0，即本回合尚未特殊召唤过非炎属性怪兽；二者都满足时cost才合法。
		and Duel.GetCustomActivityCount(46898368,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名在规则上也当作「转生炎兽」卡使用。这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是炎属性怪兽不能召唤·特殊召唤。①：对方场上的卡数量比自己场上的卡多的场合，以对方场上1只连接怪兽为对象才能发动。自己抽出那只怪兽的连接标记的数量。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c46898368.splimit)
	-- 将“不能召唤非炎属性怪兽”的永续效果注册给当前玩家tp，使其在本回合生效。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 将“不能特殊召唤非炎属性怪兽”的永续效果注册给当前玩家tp，使其在本回合生效。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃限制函数：若怪兽不是炎属性，则返回true，表示该怪兽不能进行召唤/特殊召唤。
function c46898368.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 取对象时的过滤器函数：筛选出符合条件的对象卡，作为效果的对象候补。
function c46898368.filter(c,tp)
	-- 对象卡需同时满足：表侧表示、是连接怪兽、并且玩家tp可以抽取该怪兽连接标记数量的卡。
	return c:IsFaceup() and c:IsType(TYPE_LINK) and Duel.IsPlayerCanDraw(tp,c:GetLink())
end
-- 效果发动时的目标选择处理函数：选择对方场上的1只连接怪兽作为对象，并记录抽卡玩家与抽卡数量。
function c46898368.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c46898368.filter(chkc,tp) end
	-- 在目标选择检查阶段确认对方场上存在至少1只符合filter条件的连接怪兽，可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c46898368.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 给玩家tp显示“请选择效果的对象”的卡片选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家tp从对方场上选择1只符合filter条件的连接怪兽，并将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c46898368.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	local lk=g:GetFirst():GetLink()
	-- 将当前连锁的对象玩家设置为tp，即抽卡玩家是发动者自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为所选怪兽的连接标记数量lk，用于决定抽卡张数。
	Duel.SetTargetParam(lk)
	-- 设置本次操作信息：为抽卡效果，预计使玩家tp抽lk张卡，供其他效果或规则检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,lk)
end
-- 效果处理函数：若对象卡仍与效果关联，则让对象玩家根据那只怪兽的连接标记数量抽卡。
function c46898368.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的第一张对象卡，即被选择的那只连接怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 从当前连锁信息中取得对象玩家（即抽卡玩家，通常是发动者tp）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=tc:GetLink()
	-- 执行抽卡：让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
