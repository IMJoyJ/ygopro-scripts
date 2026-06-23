--クリッター
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡从场上送去墓地的场合发动。从卡组把1只攻击力1500以下的怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
function c26202165.initial_effect(c)
	-- ①：这张卡从场上送去墓地的场合发动。从卡组把1只攻击力1500以下的怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26202165,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,26202165)
	e1:SetCondition(c26202165.condition)
	e1:SetTarget(c26202165.target)
	e1:SetOperation(c26202165.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡是从场上送去墓地的
function c26202165.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果处理目标：从卡组检索一张攻击力1500以下的怪兽加入手牌
function c26202165.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：从卡组检索一张怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索过滤条件：攻击力不超过1500的怪兽卡
function c26202165.filter(c)
	return c:IsAttackBelow(1500) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理执行：选择满足条件的怪兽卡从卡组加入手牌，并禁止发动同名卡效果
function c26202165.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 检索满足条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,c26202165.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将检索到的怪兽卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_HAND) then
			-- 设置永续效果：禁止发动同名卡的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(c26202165.aclimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册效果给玩家
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 效果限制函数：判断是否为同名卡
function c26202165.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
