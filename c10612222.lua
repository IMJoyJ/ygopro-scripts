--妖仙獣の居太刀風
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上没有怪兽存在的场合，从手卡把最多2只卡名不同的「妖仙兽」怪兽给对方观看，以给人观看的数量的对方场上的表侧表示的卡为对象才能发动。那些卡回到持有者手卡。
function c10612222.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上没有怪兽存在的场合，从手卡把最多2只卡名不同的「妖仙兽」怪兽给对方观看，以给人观看的数量的对方场上的表侧表示的卡为对象才能发动。那些卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,10612222+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c10612222.condition)
	e1:SetTarget(c10612222.target)
	e1:SetOperation(c10612222.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件函数：自己场上没有怪兽存在时才能发动。
function c10612222.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上主要怪兽区域怪兽数量是否为0，即自己场上没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 筛选条件：手卡中满足『妖仙兽』字段、是怪兽且未公开表示的卡，用于选择给对方观看的「妖仙兽」怪兽。
function c10612222.cfilter(c)
	return c:IsSetCard(0xb3) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 筛选条件：对方场上的表侧表示且能够返回手卡的卡，作为可选取的对象。
function c10612222.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 目标处理函数：进行发动合法性判定、选择要展示的手卡、选择对应数量的对象，并登记操作信息。
function c10612222.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsAbleToHand() end
	-- 发动时检查：自己手卡中是否存在至少1张符合条件的『妖仙兽』怪兽（字段·怪兽·非公开）可以展示。
	if chk==0 then return Duel.IsExistingMatchingCard(c10612222.cfilter,tp,LOCATION_HAND,0,1,nil)
		-- 发动时检查：对方场上是否存在至少1张表侧表示且能返回手卡的卡可以作为对象。
		and Duel.IsExistingTarget(c10612222.tgfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=1
	-- 如果对方场上有至少2张合法对象，则将可展示数量上限设为2，实现『最多2只』。
	if Duel.IsExistingTarget(c10612222.tgfilter,tp,0,LOCATION_ONFIELD,2,nil) then ct=2 end
	-- 获取自己手卡中所有符合条件的『妖仙兽』怪兽，组成候选组。
	local g=Duel.GetMatchingGroup(c10612222.cfilter,tp,LOCATION_HAND,0,nil)
	-- 提示己方玩家选择要给对方确认的手卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从候选组中选择1到ct张卡名互不相同的『妖仙兽』怪兽（aux.dncheck保证卡名不同）。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
	-- 将选中的手卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,sg)
	-- 由于手卡被公开过，展示后洗切手卡，重置手卡顺序。
	Duel.ShuffleHand(tp)
	-- 提示己方玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择与展示数量（#sg）相同的对方场上表侧表示且能回手卡的卡作为效果对象。
	local tg=Duel.SelectTarget(tp,c10612222.tgfilter,tp,0,LOCATION_ONFIELD,#sg,#sg,nil)
	-- 设置操作信息：将选中的对象卡登记为回手牌的卡片及数量，供后续处理与连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,#tg,0,0)
end
-- 效果处理函数：取得连锁对象中仍与效果关联的卡，并全部返回持有者手卡。
function c10612222.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁记录的对象卡，并筛选出仍与效果相关的卡（排除已离场或不受影响的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将筛选出的卡返回持有者手卡，返回原因是效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
