--無敗将軍 フリード
-- 效果：
-- 只要这张卡在场上表侧表示存在，这张卡为对象的魔法卡的效果无效并破坏。只要这张卡在场上表侧表示存在，可以作为自己的抽卡阶段时进行通常抽卡的代替，从自己卡组把1只4星以下的战士族怪兽加入手卡。
function c49681811.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，这张卡为对象的魔法卡的效果无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c49681811.distg)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，这张卡为对象的魔法卡的效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c49681811.disop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，这张卡为对象的魔法卡的效果无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e3:SetTarget(c49681811.distg)
	c:RegisterEffect(e3)
	-- 只要这张卡在场上表侧表示存在，可以作为自己的抽卡阶段时进行通常抽卡的代替，从自己卡组把1只4星以下的战士族怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(49681811,0))  --"检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PREDRAW)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c49681811.condition)
	e4:SetTarget(c49681811.target)
	e4:SetOperation(c49681811.operation)
	c:RegisterEffect(e4)
end
-- 用于判断目标魔法卡是否以这张卡为对象
function c49681811.distg(e,c)
	if not c:IsType(TYPE_SPELL) or c:GetCardTargetCount()==0 then return false end
	return c:GetCardTarget():IsContains(e:GetHandler())
end
-- 处理连锁中针对魔法卡的效果，若该效果的对象包含这张卡，则使该效果无效并破坏发动的魔法卡
function c49681811.disop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_SPELL) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not e:GetHandler():IsRelateToEffect(re) then return end
	-- 获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()==0 then return end
	if g:IsContains(e:GetHandler()) then
		-- 使当前连锁的效果无效，并检查发动的魔法卡是否仍然存在
		if Duel.NegateEffect(ev,true) and re:GetHandler():IsRelateToEffect(re) then
			-- 破坏发动的魔法卡
			Duel.Destroy(re:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 判断是否为当前回合玩家的抽卡阶段
function c49681811.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家的抽卡阶段
	return tp==Duel.GetTurnPlayer()
end
-- 过滤满足条件的4星以下战士族怪兽
function c49681811.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 设置检索效果的目标信息，准备从卡组检索符合条件的怪兽
function c49681811.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否可以进行通常抽卡且卡组中是否存在符合条件的怪兽
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.IsExistingMatchingCard(c49681811.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要从卡组检索一张怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 执行检索效果，选择并把符合条件的怪兽加入手牌
function c49681811.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否可以进行通常抽卡
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	-- 使当前玩家放弃通常抽卡
	aux.GiveUpNormalDraw(e,tp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c49681811.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()~=0 then
		-- 将选中的怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
