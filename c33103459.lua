--EMコン
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的回合的自己主要阶段只有1次，以这张卡以外的自己场上1只攻击力1000以下的「娱乐伙伴」怪兽为对象才能发动。自己场上的同是表侧攻击表示的那只怪兽和这张卡变成守备表示，从卡组把1只「异色眼」怪兽加入手卡。
-- ②：对方回合，从自己墓地把这张卡和1只「娱乐伙伴 小角」以外的「娱乐伙伴」怪兽除外才能发动。自己回复500基本分。
function c33103459.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤·特殊召唤成功的回合的自己主要阶段只有1次，以这张卡以外的自己场上1只攻击力1000以下的「娱乐伙伴」怪兽为对象才能发动。自己场上的同是表侧攻击表示的那只怪兽和这张卡变成守备表示，从卡组把1只「异色眼」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33103459,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c33103459.thcon)
	e1:SetTarget(c33103459.thtg)
	e1:SetOperation(c33103459.thop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：对方回合，从自己墓地把这张卡和1只「娱乐伙伴 小角」以外的「娱乐伙伴」怪兽除外才能发动。自己回复500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33103459,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c33103459.lpcon)
	e2:SetCost(c33103459.lpcost)
	e2:SetTarget(c33103459.lptg)
	e2:SetOperation(c33103459.lpop)
	c:RegisterEffect(e2)
	if not c33103459.global_check then
		c33103459.global_check=true
		-- 效果原文内容：（全局注册效果部分）
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(33103459)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 规则层面操作：注册EVENT_SUMMON_SUCCESS事件的处理函数为aux.sumreg，用于处理“这张卡召唤的回合”的效果
		ge1:SetOperation(aux.sumreg)
		-- 规则层面操作：将ge1效果注册到玩家0（全局）
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(33103459)
		-- 规则层面操作：将ge2效果注册到玩家0（全局），用于处理特殊召唤成功事件
		Duel.RegisterEffect(ge2,0)
	end
end
-- 规则层面操作：判断当前回合是否为该卡召唤/特殊召唤成功的回合
function c33103459.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(33103459)~=0
end
-- 规则层面操作：过滤函数，用于筛选满足条件的「娱乐伙伴」怪兽（表侧攻击表示、攻击力1000以下）
function c33103459.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c:IsAttackBelow(1000)
		and c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 规则层面操作：过滤函数，用于筛选满足条件的「异色眼」怪兽（怪兽类型、可加入手牌）
function c33103459.thfilter(c)
	return c:IsSetCard(0x99) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 规则层面操作：设置效果目标，检查是否存在满足条件的「娱乐伙伴」怪兽作为目标
function c33103459.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c33103459.filter(chkc) and chkc~=e:GetHandler() end
	-- 规则层面操作：检查卡组是否存在满足条件的「异色眼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c33103459.thfilter,tp,LOCATION_DECK,0,1,nil)
		and e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
		-- 规则层面操作：检查场上是否存在满足条件的「娱乐伙伴」怪兽作为目标
		and Duel.IsExistingTarget(c33103459.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 规则层面操作：选择满足条件的「娱乐伙伴」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c33103459.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 规则层面操作：设置连锁操作信息，表示将从卡组检索1张「异色眼」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：效果处理函数，执行效果的处理逻辑
function c33103459.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面操作：获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) and c:IsControler(tp)
		and tc:IsRelateToEffect(e) and tc:IsPosition(POS_FACEUP_ATTACK) and tc:IsControler(tp)
		-- 规则层面操作：将目标怪兽和自身变为守备表示
		and Duel.ChangePosition(Group.FromCards(c,tc),POS_FACEUP_DEFENSE)==2 then
		-- 规则层面操作：提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 规则层面操作：从卡组选择1张满足条件的「异色眼」怪兽
		local g=Duel.SelectMatchingCard(tp,c33103459.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 规则层面操作：将选中的「异色眼」怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 规则层面操作：向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 规则层面操作：过滤函数，用于筛选满足条件的「娱乐伙伴」怪兽（可除外作为费用）
function c33103459.cfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and not c:IsCode(33103459)
end
-- 规则层面操作：判断是否为对方回合
function c33103459.lpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断当前回合玩家是否为非当前玩家
	return Duel.GetTurnPlayer()~=tp
end
-- 规则层面操作：设置效果费用，检查是否满足除外条件
function c33103459.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 规则层面操作：检查墓地是否存在满足条件的「娱乐伙伴」怪兽作为费用
		and Duel.IsExistingMatchingCard(c33103459.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 规则层面操作：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 规则层面操作：选择满足条件的「娱乐伙伴」怪兽作为费用
	local g=Duel.SelectMatchingCard(tp,c33103459.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 规则层面操作：将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 规则层面操作：设置效果目标，表示回复500基本分
function c33103459.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置效果目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 规则层面操作：设置效果目标参数为500
	Duel.SetTargetParam(500)
	-- 规则层面操作：设置连锁操作信息，表示回复500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 规则层面操作：效果处理函数，执行回复LP的处理逻辑
function c33103459.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面操作：使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
