--リヴェンデット・エグゼクター
-- 效果：
-- 「复仇死者」仪式魔法卡降临。这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡只要在怪兽区域存在，卡名当作「归魂复仇死者·屠魔侠」使用。
-- ②：只要仪式召唤的这张卡在怪兽区域存在，对方不能把自己场上的其他卡作为效果的对象。
-- ③：仪式召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1张「复仇死者」卡加入手卡。
function c34093683.initial_effect(c)
	c:EnableReviveLimit()
	-- 使该卡在怪兽区域存在时视为卡号为4388680的卡片
	aux.EnableChangeCode(c,4388680)
	-- 只要仪式召唤的这张卡在怪兽区域存在，对方不能把自己场上的其他卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetCondition(c34093683.tgcon)
	e2:SetTarget(c34093683.tgtg)
	-- 设置该效果的值为过滤函数aux.tgoval，用于判断是否能成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 仪式召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1张「复仇死者」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34093683,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,34093683)
	e3:SetCondition(c34093683.thcon)
	e3:SetTarget(c34093683.thtg)
	e3:SetOperation(c34093683.thop)
	c:RegisterEffect(e3)
end
-- 判断该卡是否为仪式召唤 summoned
function c34093683.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 判断目标卡是否不为该卡本身
function c34093683.tgtg(e,c)
	return c~=e:GetHandler()
end
-- 判断该卡是否因战斗或对方效果破坏且在怪兽区域被破坏且为仪式召唤
function c34093683.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤函数，用于检索卡组中「复仇死者」卡且能加入手牌
function c34093683.thfilter(c)
	return c:IsSetCard(0x106) and c:IsAbleToHand()
end
-- 设置连锁操作信息，表示将从卡组检索1张「复仇死者」卡加入手牌
function c34093683.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件，即卡组中存在至少1张「复仇死者」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c34093683.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索1张「复仇死者」卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，用于选择并把符合条件的卡加入手牌
function c34093683.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「复仇死者」卡
	local g=Duel.SelectMatchingCard(tp,c34093683.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
