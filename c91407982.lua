--フォーチュン・ヴィジョン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「命运女郎」卡加入手卡。
-- ②：1回合1次，自己场上的卡被效果除外的场合才能发动。这个回合，自己场上的怪兽不会被效果破坏。
-- ③：1回合1次，对方场上的卡被效果除外的场合才能发动。这个回合，自己受到的战斗伤害只有1次变成0。
function c91407982.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「命运女郎」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,91407982+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c91407982.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上的卡被效果除外的场合才能发动。这个回合，自己场上的怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91407982,1))  --"自己场上的怪兽不会被效果破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c91407982.indcon)
	e2:SetOperation(c91407982.indop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(91407982,2))  --"自己受到的战斗伤害只有1次变成0"
	e3:SetCondition(c91407982.damcon)
	e3:SetOperation(c91407982.damop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中可以加入手牌的「命运女郎」卡片
function c91407982.filter(c)
	return c:IsSetCard(0x31) and c:IsAbleToHand()
end
-- 卡片发动时的效果处理：可以从卡组把1张「命运女郎」卡加入手卡
function c91407982.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中检索符合条件的「命运女郎」卡片
	local g=Duel.GetMatchingGroup(c91407982.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的卡，询问玩家是否发动检索效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(91407982,0)) then  --"是否从卡组把1张「命运女郎」卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片因效果加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤原本在场上、由指定玩家控制且因效果被除外的卡片
function c91407982.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
end
-- 效果②的发动条件：检测是否有自己场上的卡因效果被除外
function c91407982.indcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c91407982.cfilter,1,nil,tp)
end
-- 效果②的效果处理：使自己场上的怪兽在这个回合不会被效果破坏
function c91407982.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ③：1回合1次，对方场上的卡被效果除外的场合才能发动。这个回合，自己受到的战斗伤害只有1次变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该不会被效果破坏的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果③的发动条件：检测是否有对方场上的卡因效果被除外
function c91407982.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c91407982.cfilter,1,nil,1-tp)
end
-- 效果③的效果处理：使自己在这个回合受到的战斗伤害只有1次变成0
function c91407982.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己受到的战斗伤害只有1次变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL+PHASE_END)
	-- 注册该战斗伤害变成0的全局效果
	Duel.RegisterEffect(e1,tp)
end
