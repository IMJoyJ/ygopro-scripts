--妖仙獣の居太刀風
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上没有怪兽存在的场合，从手卡把最多2只卡名不同的「妖仙兽」怪兽给对方观看，以给人观看的数量的对方场上的表侧表示的卡为对象才能发动。那些卡回到持有者手卡。
function c10612222.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
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
-- 效果作用：判断是否满足发动条件（自己场上没有怪兽）
function c10612222.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 效果作用：过滤手卡中卡名不同的妖仙兽怪兽
function c10612222.cfilter(c)
	return c:IsSetCard(0xb3) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 效果作用：过滤对方场上的表侧表示且能回到手卡的卡
function c10612222.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果作用：设置效果的目标选择函数
function c10612222.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsAbleToHand() end
	-- 效果作用：检查是否满足发动条件（手卡有妖仙兽怪兽且对方场上存在可选的卡）
	if chk==0 then return Duel.IsExistingMatchingCard(c10612222.cfilter,tp,LOCATION_HAND,0,1,nil)
		-- 效果作用：检查是否满足发动条件（手卡有妖仙兽怪兽且对方场上存在可选的卡）
		and Duel.IsExistingTarget(c10612222.tgfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=1
	-- 效果作用：根据对方场上的卡数量决定最多可选妖仙兽怪兽数量
	if Duel.IsExistingTarget(c10612222.tgfilter,tp,0,LOCATION_ONFIELD,2,nil) then ct=2 end
	-- 效果作用：获取手卡中所有满足条件的妖仙兽怪兽
	local g=Duel.GetMatchingGroup(c10612222.cfilter,tp,LOCATION_HAND,0,nil)
	-- 效果作用：提示玩家选择要确认的妖仙兽怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	-- 效果作用：从满足条件的妖仙兽怪兽中选择数量为1~2且卡名不同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
	-- 效果作用：将选择的妖仙兽怪兽展示给对方玩家
	Duel.ConfirmCards(1-tp,sg)
	-- 效果作用：将自己手卡洗切
	Duel.ShuffleHand(tp)
	-- 效果作用：提示玩家选择要返回手卡的对方场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	-- 效果作用：选择对方场上的卡作为效果对象
	local tg=Duel.SelectTarget(tp,c10612222.tgfilter,tp,0,LOCATION_ONFIELD,#sg,#sg,nil)
	-- 效果作用：设置效果处理时要操作的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,#tg,0,0)
end
-- 效果作用：设置效果的发动处理函数
function c10612222.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中被选择的目标卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 效果作用：将目标卡送回持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
