--黄昏の忍者－シンゲツ
-- 效果：
-- 「黄昏之忍者-新月」的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，对方不能把其他的「忍者」怪兽作为攻击对象，也不能作为效果的对象。
-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从卡组把「黄昏之忍者-新月」以外的1只「忍者」怪兽加入手卡。
function c14541657.initial_effect(c)
	-- 效果原文内容：①：只要这张卡在怪兽区域存在，对方不能把其他的「忍者」怪兽作为攻击对象，也不能作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c14541657.atlimit)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：只要这张卡在怪兽区域存在，对方不能把其他的「忍者」怪兽作为攻击对象，也不能作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c14541657.tglimit)
	-- 规则层面操作：设置效果值为aux.tgoval函数，用于判断是否能成为对方效果的对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从卡组把「黄昏之忍者-新月」以外的1只「忍者」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,14541657)
	e3:SetCondition(c14541657.thcon)
	e3:SetTarget(c14541657.thtg)
	e3:SetOperation(c14541657.thop)
	c:RegisterEffect(e3)
end
-- 规则层面操作：定义atlimit函数，用于判断是否不能被选为攻击对象，条件为对方的「忍者」怪兽且不是自身。
function c14541657.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x2b) and c~=e:GetHandler()
end
-- 规则层面操作：定义tglimit函数，用于判断是否不能成为效果的对象，条件为对方的「忍者」怪兽且不是自身。
function c14541657.tglimit(e,c)
	return c:IsSetCard(0x2b) and c~=e:GetHandler()
end
-- 规则层面操作：定义thcon函数，用于判断是否满足发动条件，即被战斗破坏或被对方效果破坏并回到自己场上。
function c14541657.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
end
-- 规则层面操作：定义thfilter函数，用于过滤卡组中符合条件的「忍者」怪兽，排除自身。
function c14541657.thfilter(c)
	return c:IsSetCard(0x2b) and c:IsType(TYPE_MONSTER) and not c:IsCode(14541657) and c:IsAbleToHand()
end
-- 规则层面操作：定义thtg函数，用于设置发动时的操作信息，检查是否有满足条件的卡可加入手牌。
function c14541657.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否满足发动条件，即卡组中是否存在至少一张符合条件的「忍者」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c14541657.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面操作：设置连锁操作信息，表示将从卡组检索一张「忍者」怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：定义thop函数，用于执行效果的处理流程，包括选择和将卡加入手牌。
function c14541657.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：向玩家发送提示信息，提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 规则层面操作：从卡组中选择一张符合条件的「忍者」怪兽。
	local g=Duel.SelectMatchingCard(tp,c14541657.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的卡以效果原因送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面操作：确认对方看到被选中的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
