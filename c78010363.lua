--黒き森のウィッチ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡从场上送去墓地的场合发动。从卡组把1只守备力1500以下的怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
function c78010363.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡从场上送去墓地的场合发动。从卡组把1只守备力1500以下的怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78010363,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,78010363)
	e1:SetCondition(c78010363.condition)
	e1:SetTarget(c78010363.target)
	e1:SetOperation(c78010363.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否是从场上送去墓地。
function c78010363.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果发动的靶向处理，设置操作信息为从卡组将1张卡加入手牌。
function c78010363.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤卡组中守备力1500以下、是怪兽且能加入手牌的卡。
function c78010363.filter(c)
	return c:IsDefenseBelow(1500) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理：从卡组检索1只守备力1500以下的怪兽，并在这个回合内限制该卡及同名卡的效果发动。
function c78010363.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,c78010363.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_HAND) then
			-- 这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(c78010363.aclimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册该限制效果给玩家，使其在这个回合内生效。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 限制发动的卡片判定，若发动的卡片卡名与加入手牌的卡片相同，则无法发动。
function c78010363.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
