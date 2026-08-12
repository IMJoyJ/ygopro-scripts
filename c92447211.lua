--尾長黒馬
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，把手卡1只不死族怪兽给对方观看，从卡组把1只不死族·地属性怪兽送去墓地才能发动。给人观看的怪兽送去墓地，这张卡的攻击力直到回合结束时上升500。
local s,id,o=GetID()
-- 注册这张卡召唤·特殊召唤成功时发动的诱发效果。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，把手卡1只不死族怪兽给对方观看，从卡组把1只不死族·地属性怪兽送去墓地才能发动。给人观看的怪兽送去墓地，这张卡的攻击力直到回合结束时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可送去墓地的不死族·地属性怪兽的过滤函数。
function s.gyfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToGraveAsCost()
end
-- 过滤手牌中可给对方观看且可送去墓地的不死族怪兽的过滤函数。
function s.handfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave() and not c:IsPublic()
end
-- 效果发动的检测，确认卡组中存在符合条件的不死族·地属性怪兽且手牌中存在可展示的不死族怪兽。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：确认卡组中是否存在至少1只满足条件的不死族·地属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,1,nil)
		-- 发动检测：确认手牌中是否存在至少1只满足条件的不死族怪兽。
		and Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择给对方确认的手牌卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手牌中1只满足过滤条件的不死族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的那只手牌怪兽给对方确认。
	Duel.ConfirmCards(1-tp,g)
	-- 洗切玩家的手牌。
	Duel.ShuffleHand(tp)
	-- 把选中的那只手牌怪兽设为当前连锁的处理对象（取对象）。
	Duel.SetTargetCard(g)
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中选择1只满足条件的不死族·地属性怪兽。
	local cg=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的那只卡组怪兽作为发动代价送去墓地。
	Duel.SendtoGrave(cg,REASON_COST)
	-- 设置连锁的操作信息：将卡组选中的怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,cg,1,tp,0)
end
-- 效果处理：将展示的那只手牌怪兽送去墓地，并使这张卡的攻击力直到回合结束时上升500。
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时给对方确认并设置为连锁处理目标的手牌怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	-- 将选中的那只展示的手牌怪兽送去墓地，并确认其已成功送去墓地。
	if Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 这张卡的攻击力直到回合结束时上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
