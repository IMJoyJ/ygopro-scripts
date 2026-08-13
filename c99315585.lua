--幻影騎士団クラックヘルム
-- 效果：
-- 「幻影骑士团 裂头盔」的①②的效果1回合各能使用1次。
-- ①：「幻影骑士团」卡或者「幻影」魔法·陷阱卡被送去自己墓地的场合发动。这张卡的攻击力上升500。
-- ②：把墓地的这张卡除外才能发动。这个回合的结束阶段，从自己墓地选1张「幻影骑士团」卡或者「幻影」魔法·陷阱卡加入手卡。
function c99315585.initial_effect(c)
	-- ①：「幻影骑士团」卡或者「幻影」魔法·陷阱卡被送去自己墓地的场合发动。这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99315585,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,99315585)
	e1:SetCondition(c99315585.atkcon)
	e1:SetOperation(c99315585.atkop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。这个回合的结束阶段，从自己墓地选1张「幻影骑士团」卡或者「幻影」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99315585,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,99315586)
	-- 设定②效果的发动代价：把墓地中的这张卡除外（aux.bfgcost实现），满足“把墓地的这张卡除外才能发动”。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c99315585.regop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数：判断一张卡是否为己方控制且属于「幻影骑士团」卡，或属于「幻影」魔法·陷阱卡（0x10db为幻影骑士团，0xdb为幻影，且仅限魔法·陷阱）。
function c99315585.tgfilter(c,tp)
	return c:IsControler(tp) and (c:IsSetCard(0x10db) or c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP))
end
-- ①效果的发动条件：本次被送去墓地的卡组（eg）中存在至少1张符合tgfilter过滤的卡，即“「幻影骑士团」卡或者「幻影」魔法·陷阱卡被送去自己墓地”。
function c99315585.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c99315585.tgfilter,1,nil,tp)
end
-- ①效果的处理：若这张卡仍表侧表示且与效果关联，则给它赋予一个攻击力上升500的效果，该效果在离场、无效等标准时机重置。
function c99315585.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ②效果发动后的处理：在当前回合的结束阶段，给己方注册一个不入连锁的延迟效果，用于执行“从自己墓地选1张「幻影骑士团」卡或者「幻影」魔法·陷阱卡加入手卡”的检索，该延迟效果在结束阶段时一次性生效并重置。
function c99315585.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，从自己墓地选1张「幻影骑士团」卡或者「幻影」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c99315585.thcon)
	e1:SetOperation(c99315585.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述结束阶段处理效果注册给当前玩家tp，使其在结束阶段被触发执行。
	Duel.RegisterEffect(e1,tp)
end
-- 定义检索对象的过滤条件：必须满足「幻影骑士团」卡或「幻影」魔法·陷阱卡，并且可以加入手卡。
function c99315585.thfilter(c)
	return (c:IsSetCard(0x10db) or (c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP))) and c:IsAbleToHand()
end
-- 结束阶段延迟效果的发动条件：检查自己墓地是否存在至少1张满足thfilter检索条件的卡，若存在则可执行回收。
function c99315585.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己墓地是否存在至少1张符合条件的「幻影骑士团」卡或「幻影」魔法·陷阱卡。
	return Duel.IsExistingMatchingCard(c99315585.thfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 结束阶段时的实际回收处理：从自己墓地选择1张符合条件的「幻影骑士团」卡或「幻影」魔法·陷阱卡加入手卡，并向对手展示那张卡。
function c99315585.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示内容为“请选择要加入手牌的卡”，供玩家在选择卡片时看到。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地筛选并选择1张满足thfilter且不受「王家长眠之谷」影响的卡（若适用），作为回收对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c99315585.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的卡片加入手卡，reason为效果（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将回收的那张卡展示给对手确认（ConfirmCards）。
		Duel.ConfirmCards(1-tp,tc)
	end
end
