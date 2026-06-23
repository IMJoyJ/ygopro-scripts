--鋼炎の剣士
-- 效果：
-- 这张卡不能通常召唤，用把5星以上的战士族怪兽解放发动的「金属化·强化反射装甲」的效果可以特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。把「钢炎之剑士」以外的有「金属化·强化反射装甲」的卡名记述的1张卡从卡组加入手卡，这张卡回到卡组。
-- ②：只要这张卡在怪兽区域存在，每次对方把效果发动，这张卡的攻击力上升300，给与对方500伤害。
local s,id,o=GetID()
-- 初始化卡片效果，注册金属化·强化反射装甲的卡号，启用特殊召唤限制，创建①效果、②效果和③效果
function s.initial_effect(c)
	-- 记录该卡具有金属化·强化反射装甲的卡号
	aux.AddCodeList(c,89812483)
	c:EnableReviveLimit()
	-- ①：把手卡的这张卡给对方观看才能发动。把「钢炎之剑士」以外的有「金属化·强化反射装甲」的卡名记述的1张卡从卡组加入手卡，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次对方把效果发动，这张卡的攻击力上升300，给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，每次对方把效果发动，这张卡的攻击力上升300，给与对方500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数，判断是否满足解放条件（ft=1，等级≥5，种族为战士族）
function s.mfilter(ft,lv,race,att)
	return ft==1 and lv>=5 and race&RACE_WARRIOR~=0
end
s.Metallization_material=s.mfilter
-- ①效果的费用支付函数，检查手牌是否公开
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- ①效果的检索过滤函数，筛选非钢炎之剑士且记载金属化·强化反射装甲的卡
function s.thfilter(c)
	-- 筛选非钢炎之剑士且记载金属化·强化反射装甲的卡
	return not c:IsCode(id) and aux.IsCodeListed(c,89812483) and c:IsAbleToHand()
end
-- ①效果的发动条件判断函数，检查卡组是否存在满足条件的卡并确认该卡可送入卡组
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查卡组是否存在满足条件的卡并确认该卡可送入卡组
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and c:IsAbleToDeck() end
	-- 设置操作信息，提示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理函数，选择卡组中的卡加入手牌并送回卡组
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToEffect(e) then
			-- 将该卡送回卡组并洗牌
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- ②效果的触发处理函数，记录对方发动效果的标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- ②效果的触发条件函数，判断对方是否发动效果且该卡已记录标记
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c:GetFlagEffect(id)~=0
end
-- ②效果的处理函数，提升攻击力并给予对方伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了钢炎之剑士的卡
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	-- 提升该卡攻击力300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 给予对方500伤害
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
