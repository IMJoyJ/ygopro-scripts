--トリックスター・キャンディナ
-- 效果：
-- ①：这张卡召唤时才能发动。从卡组把1张「淘气仙星」卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，每次对方把魔法·陷阱卡发动给与对方200伤害。
function c61283655.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把1张「淘气仙星」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61283655,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c61283655.target)
	e1:SetOperation(c61283655.operation)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次对方把魔法·陷阱卡发动给与对方200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c61283655.regop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，每次对方把魔法·陷阱卡发动给与对方200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c61283655.damcon)
	e3:SetOperation(c61283655.damop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组中属于「淘气仙星」字段且能加入手卡的卡
function c61283655.filter(c)
	return c:IsSetCard(0xfb) and c:IsAbleToHand()
end
-- ①效果的发动准备：检查卡组中是否存在可检索的「淘气仙星」卡，并设置将卡组的卡加入手卡的操作信息
function c61283655.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「淘气仙星」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c61283655.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选择1张「淘气仙星」卡加入手卡并给对方确认
function c61283655.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「淘气仙星」卡
	local g=Duel.SelectMatchingCard(tp,c61283655.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 在对方发动魔法·陷阱卡时，给自身注册一个在当前连锁结算前有效的标记
function c61283655.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():RegisterFlagEffect(61283655,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- 检查伤害效果的触发条件：对方发动了魔法·陷阱卡，且自身带有对应的标记
function c61283655.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c:GetFlagEffect(61283655)~=0 and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 伤害效果的处理：展示卡片并给与对方200点伤害
function c61283655.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上展示该卡片以提示效果发动
	Duel.Hint(HINT_CARD,0,61283655)
	-- 给与对方玩家200点效果伤害
	Duel.Damage(1-tp,200,REASON_EFFECT)
end
