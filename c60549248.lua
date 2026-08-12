--電池メン－角型
-- 效果：
-- 「电池人-角型」的①的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功时才能发动。从卡组把1只「电池人」怪兽加入手卡，这张卡的攻击力·守备力变成原本的2倍。
-- ②：自己结束阶段发动。这张卡破坏。
function c60549248.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功时才能发动。从卡组把1只「电池人」怪兽加入手卡，这张卡的攻击力·守备力变成原本的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60549248,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,60549248)
	e1:SetTarget(c60549248.thtg)
	e1:SetOperation(c60549248.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：自己结束阶段发动。这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(60549248,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c60549248.descon)
	e4:SetTarget(c60549248.destg)
	e4:SetOperation(c60549248.desop)
	c:RegisterEffect(e4)
end
-- 过滤条件：卡组中「电池人」怪兽且能加入手卡
function c60549248.filter(c)
	return c:IsSetCard(0x28) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检测
function c60549248.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「电池人」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c60549248.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行：从卡组选1只「电池人」怪兽加入手卡，并使这张卡的攻击力·守备力变成原本的2倍
function c60549248.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c60549248.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 这张卡的攻击力·守备力变成原本的2倍。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(c:GetBaseAttack()*2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(c:GetBaseDefense()*2)
			c:RegisterEffect(e2)
		end
	end
end
-- 破坏效果的发动条件：自己回合的结束阶段
function c60549248.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 破坏效果的发动准备
function c60549248.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的操作信息为：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 破坏效果的执行：将自身破坏
function c60549248.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 因效果破坏自身
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
