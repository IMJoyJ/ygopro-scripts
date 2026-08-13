--黄昏の忍者－シンゲツ
-- 效果：
-- 「黄昏之忍者-新月」的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，对方不能把其他的「忍者」怪兽作为攻击对象，也不能作为效果的对象。
-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从卡组把「黄昏之忍者-新月」以外的1只「忍者」怪兽加入手卡。
function c14541657.initial_effect(c)
	-- 对应①效果前一句：对方不能把其他的「忍者」怪兽作为攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c14541657.atlimit)
	c:RegisterEffect(e1)
	-- 对应①效果后一句：也不能作为效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c14541657.tglimit)
	-- 为“不能成为效果对象”限制设置判定函数：仅当效果发动者是这张卡的控制者的对方时，对方不能选择这些「忍者」怪兽作为效果对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 对应②效果原文：「黄昏之忍者-新月」的②的效果1回合只能使用1次。②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从卡组把「黄昏之忍者-新月」以外的1只「忍者」怪兽加入手卡。
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
-- 攻击对象限制的判定条件：c须为表侧表示的「忍者」怪兽且不是这张卡自身（即“其他的「忍者」怪兽”）
function c14541657.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x2b) and c~=e:GetHandler()
end
-- 效果对象限制的判定条件：c须为「忍者」怪兽且不是这张卡自身（即“其他的「忍者」怪兽”）
function c14541657.tglimit(e,c)
	return c:IsSetCard(0x2b) and c~=e:GetHandler()
end
-- 诱发条件：这张卡被战斗破坏送去墓地，或者被对方的效果破坏送去墓地（且破坏前由这张卡的控制者tp控制）时满足
function c14541657.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
end
-- 检索过滤条件：卡名含有「忍者」字段的怪兽，且不是「黄昏之忍者-新月」，并且能够加入手卡
function c14541657.thfilter(c)
	return c:IsSetCard(0x2b) and c:IsType(TYPE_MONSTER) and not c:IsCode(14541657) and c:IsAbleToHand()
end
-- 发动时：确认卡组中存在满足检索条件的「忍者」怪兽，并将本次操作信息标记为“从卡组将卡加入手卡”
function c14541657.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己卡组中是否存在至少1张满足thfilter检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c14541657.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将从卡组把1张卡加入手卡，供后续处理与连锁判定使用
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让玩家选择卡组中1张满足条件的「忍者」怪兽加入手卡，并让对方确认
function c14541657.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己卡组精确选择1张满足thfilter条件的「忍者」怪兽作为加入手牌的对象
	local g=Duel.SelectMatchingCard(tp,c14541657.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，原因记为效果
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
