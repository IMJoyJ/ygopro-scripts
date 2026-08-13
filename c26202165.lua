--クリッター
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡从场上送去墓地的场合发动。从卡组把1只攻击力1500以下的怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
function c26202165.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡从场上送去墓地的场合发动。从卡组把1只攻击力1500以下的怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
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
-- 发动条件判定：该卡之前所在位置为场上，即满足“这张卡从场上送去墓地”的场合才发动。
function c26202165.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果发动时无取对象要求，chk==0直接返回true允许发动；同时设置操作信息，表明后续将进行从卡组检索卡加入手卡的处理。
function c26202165.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：声明本效果将把1张卡从卡组加入手卡（CATEGORY_TOHAND），用于其他效果对此类检索行为的检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义检索卡的过滤条件：攻击力1500以下的怪兽，且能够加入手卡。
function c26202165.filter(c)
	return c:IsAttackBelow(1500) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理：从卡组选择1只满足条件的怪兽加入手卡；若成功加入手卡，则给己方附加直到回合结束的封印，使自己不能发动被检索卡及其同名卡的效果。
function c26202165.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要加入手牌的卡”的提示，并将该提示信息缓存供选择卡片时使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组中选择1张满足c26202165.filter条件的卡片（攻击力1500以下的怪兽且能加入手卡）。
	local g=Duel.SelectMatchingCard(tp,c26202165.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌加入其持有者的手卡，加入原因为效果处理（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家公开确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_HAND) then
			-- 这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(c26202165.aclimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将该“不能发动效果”的自肃效果注册给当前玩家tp，持续到结束阶段。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 自肃判定函数：若某效果的发动者是自己，且发动该效果的那张卡的卡号与记录的被检索卡卡号相同，则禁止该效果发动；以此限制被检索卡及其同名卡的效果发动。
function c26202165.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
