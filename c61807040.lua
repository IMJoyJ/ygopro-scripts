--フルエルフ
-- 效果：
-- 1回合1次，把手卡1只怪兽给对方观看才能发动。直到结束阶段时，这张卡的等级上升给人观看的怪兽的等级数值。
function c61807040.initial_effect(c)
	-- 1回合1次，把手卡1只怪兽给对方观看才能发动。直到结束阶段时，这张卡的等级上升给人观看的怪兽的等级数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61807040,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c61807040.cost)
	e1:SetOperation(c61807040.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡中未给对方观看（非公开）的怪兽卡
function c61807040.cfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 发动代价（Cost）：检查并选择手卡中1只未公开的怪兽给对方观看，并将该怪兽的等级作为Label记录在效果中
function c61807040.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己手卡是否存在至少1只未公开的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c61807040.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认（观看）的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手卡选择1只未公开的怪兽
	local g=Duel.SelectMatchingCard(tp,c61807040.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽卡给对方玩家确认（观看）
	Duel.ConfirmCards(1-tp,g)
	-- 洗切发动者的手卡
	Duel.ShuffleHand(tp)
	e:SetLabel(g:GetFirst():GetLevel())
end
-- 效果处理：若此卡在场上表侧表示存在，则直到结束阶段时，其等级上升被观看怪兽的等级数值
function c61807040.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 直到结束阶段时，这张卡的等级上升给人观看的怪兽的等级数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
