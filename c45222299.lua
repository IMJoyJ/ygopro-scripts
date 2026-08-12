--イビリチュア・ガストクラーケ
-- 效果：
-- 「遗式」仪式魔法卡降临。
-- ①：这张卡仪式召唤成功的场合发动。对方手卡随机选最多2张确认，选那之内的1张回到卡组。
function c45222299.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合发动。
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
-- 效果发动条件：此卡为仪式召唤成功
function c45222299.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果处理目标：选择对方手卡1张送回卡组
function c45222299.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：将对方手卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_HAND)
end
-- 效果处理流程：对方手卡随机选最多2张确认，选那之内的1张回到卡组
function c45222299.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if ct==0 then return end
	local ac=1
	if ct>1 then
		-- 提示玩家选择确认的手卡数量
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(45222299,1))  --"请选择要确认的手卡的数量"
		-- 玩家宣言确认手卡数量（1或2）
		ac=Duel.AnnounceNumber(tp,1,2)
	end
	-- 提示玩家选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从对方手卡中随机选择指定数量的卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,ac)
	-- 向玩家确认所选的卡
	Duel.ConfirmCards(tp,g)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 将选定的卡送回卡组并洗牌
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 将对方手卡洗牌
	Duel.ShuffleHand(1-tp)
end
