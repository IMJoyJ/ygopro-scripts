--賤竜の魔術師
-- 效果：
-- ←2 【灵摆】 2→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域有「魔术师」卡存在的场合才能发动。从自己的额外卡组（表侧）把1只「贱龙之魔术师」以外的「魔术师」灵摆怪兽或「异色眼」灵摆怪兽加入手卡。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以自己墓地1只「贱龙之魔术师」以外的「魔术师」灵摆怪兽或「异色眼」怪兽为对象才能发动。那只怪兽加入手卡。
function c14920218.initial_effect(c)
	-- 为这张卡注册灵摆召唤属性，使其可以作为灵摆怪兽进行灵摆召唤、灵摆设置（以及发动灵摆卡）。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：另一边的自己的灵摆区域有「魔术师」卡存在的场合才能发动。从自己的额外卡组（表侧）把1只「贱龙之魔术师」以外的「魔术师」灵摆怪兽或「异色眼」灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14920218,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,14920218)
	e2:SetCondition(c14920218.pcon)
	e2:SetTarget(c14920218.ptg)
	e2:SetOperation(c14920218.pop)
	c:RegisterEffect(e2)
	-- 这个卡名的怪兽效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合，以自己墓地1只「贱龙之魔术师」以外的「魔术师」灵摆怪兽或「异色眼」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(14920218,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,14920219)
	e3:SetTarget(c14920218.thtg)
	e3:SetOperation(c14920218.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 灵摆效果的发动条件判定：检查自己的灵摆区域是否有另一张「魔术师」卡存在（本卡自身除外）。
function c14920218.pcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否存在至少1张满足Card.IsSetCard且setname为0x98（「魔术师」）的卡，并排除效果发动的这张卡自身。
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x98)
end
-- 灵摆效果检索卡的过滤条件：表侧表示、灵摆怪兽、属于「魔术师」（0x98）或「异色眼」（0x99）系列、卡名不是「贱龙之魔术师」（14920218）、且能够加入手牌。
function c14920218.pfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x98,0x99) and not c:IsCode(14920218) and c:IsAbleToHand()
end
-- 灵摆效果的发动时点：确认额外卡组存在符合条件的灵摆怪兽，并设置操作信息（从额外卡组将1张卡加入手牌）。
function c14920218.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己的额外卡组（表侧）是否存在至少1只满足pfilter的灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c14920218.pfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：本次效果类别为回手牌，处理目标为从自己的额外卡组将1张卡加入手牌（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 灵摆效果处理：从自己的额外卡组（表侧）选择1只符合条件的灵摆怪兽加入手牌，并让对方确认。
function c14920218.pop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示“请选择要加入手牌的卡”（用于从额外卡组选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的额外卡组（表侧）选择1张满足pfilter的卡。
	local g=Duel.SelectMatchingCard(tp,c14920218.pfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽效果取对象的过滤条件：怪兽卡，且属于「魔术师」灵摆怪兽或「异色眼」怪兽，卡名不是「贱龙之魔术师」，且能够加入手牌。
function c14920218.thfilter(c)
	return c:IsType(TYPE_MONSTER) and ((c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)) or c:IsSetCard(0x99)) and not c:IsCode(14920218) and c:IsAbleToHand()
end
-- 怪兽效果的发动时点：选择自己墓地1只符合条件的怪兽作为对象，并设置操作信息。
function c14920218.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14920218.thfilter(chkc) end
	-- 发动合法性检查：自己墓地是否存在至少1只满足thfilter的怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c14920218.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示“请选择要加入手牌的卡”（用于选择墓地怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1只满足thfilter的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c14920218.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选择的对象卡加入手牌，类别为回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 怪兽效果处理：将墓地对象怪兽加入手牌，并让对方确认。
function c14920218.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时当前连锁的对象卡（即发动时选择的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入其持有者的手卡，原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
