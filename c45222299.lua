--イビリチュア・ガストクラーケ
-- 效果：
-- 「遗式」仪式魔法卡降临。
-- ①：这张卡仪式召唤成功的场合发动。对方手卡随机选最多2张确认，选那之内的1张回到卡组。
function c45222299.initial_effect(c)
	c:EnableReviveLimit()
	-- 「遗式」仪式魔法卡降临。①：这张卡仪式召唤成功的场合发动。对方手卡随机选最多2张确认，选那之内的1张回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45222299,0))  --"确认手卡"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c45222299.condition)
	e1:SetTarget(c45222299.target)
	e1:SetOperation(c45222299.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件判断：确认这张卡是以仪式召唤方式特殊召唤成功，即召唤类型为仪式召唤时才满足触发条件。
function c45222299.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果发动的目标阶段处理：chk==0时无条件允许发动；随后登记本效果将涉及把对方手卡返回卡组的处理，以便系统监测相关连锁。
function c45222299.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将本次效果标记为‘让对方手牌返回卡组’类别，预期处理对方手牌中的1张卡（实际数量在效果处理时可能不同）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_HAND)
end
-- 效果处理流程：若对方手卡为0则直接结束；否则由对方手卡随机选取1或2张确认，再由控制方从确认的卡中选1张返回持有者卡组，最后洗切对方手牌。
function c45222299.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌数量（对方手牌张数），用于判断能否随机选牌以及可选数量范围。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if ct==0 then return end
	local ac=1
	if ct>1 then
		-- 弹出数量选择提示，让控制方选择要确认的对方手卡数量（1或2）。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(45222299,1))  --"请选择要确认的手卡的数量"
		-- 让控制方从数字1和2中宣言一个，作为实际随机确认的手卡张数。
		ac=Duel.AnnounceNumber(tp,1,2)
	end
	-- 弹出“请选择给对方确认的卡”的提示，提示玩家即将展示对方手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从对方手卡中随机选取ac张卡，作为本次效果确认的对象。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,ac)
	-- 将随机选出的对方手牌展示给控制方确认。
	Duel.ConfirmCards(tp,g)
	-- 弹出“请选择要返回卡组的卡”的提示，要求控制方从已确认的手牌中选择1张。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 将选中的那张卡送回持有者卡组，并触发卡组洗切；REASON_EFFECT表示这是由卡牌效果进行的移动。
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切对方手牌，因为其手牌被确认且其中一张已返回卡组，需要重新随机化手牌顺序。
	Duel.ShuffleHand(1-tp)
end
