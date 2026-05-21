--ティンダングル・イントルーダー
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡反转的场合才能发动。从卡组把1张「廷达魔三角」卡加入手卡。
-- ②：这张卡召唤成功时才能发动。从卡组把1张「廷达魔三角」卡送去墓地。
-- ③：这张卡在墓地存在，自己场上有怪兽里侧守备表示特殊召唤的场合发动。这张卡从墓地里侧守备表示特殊召唤。
function c94142993.initial_effect(c)
	-- 注册一个用于检测此卡是否已在墓地的辅助效果，以确保墓地发动效果的合法性。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：这张卡反转的场合才能发动。从卡组把1张「廷达魔三角」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94142993,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,94142993)
	e1:SetTarget(c94142993.target)
	e1:SetOperation(c94142993.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤成功时才能发动。从卡组把1张「廷达魔三角」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94142993,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,94142994)
	e2:SetTarget(c94142993.tgtg)
	e2:SetOperation(c94142993.tgop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在，自己场上有怪兽里侧守备表示特殊召唤的场合发动。这张卡从墓地里侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94142993,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,94142995)
	e3:SetLabelObject(e0)
	e3:SetCondition(c94142993.spcon)
	e3:SetTarget(c94142993.sptg)
	e3:SetOperation(c94142993.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中可以加入手牌的「廷达魔三角」卡。
function c94142993.thfilter(c)
	return c:IsSetCard(0x10b) and c:IsAbleToHand()
end
-- ①号效果（反转检索）的发动准备与合法性检测。
function c94142993.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「廷达魔三角」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c94142993.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示该效果会将卡组的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果（反转检索）的效果处理。
function c94142993.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「廷达魔三角」卡。
	local g=Duel.SelectMatchingCard(tp,c94142993.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手牌。
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤卡组中可以送去墓地的「廷达魔三角」卡。
function c94142993.tgfilter(c)
	return c:IsSetCard(0x10b) and c:IsAbleToGrave()
end
-- ②号效果（召唤送墓）的发动准备与合法性检测。
function c94142993.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以送去墓地的「廷达魔三角」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c94142993.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示该效果会将卡组的1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②号效果（召唤送墓）的效果处理。
function c94142993.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的「廷达魔三角」卡。
	local g=Duel.SelectMatchingCard(tp,c94142993.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤在自己场上里侧守备表示特殊召唤的怪兽，且排除由本效果自身特殊召唤的情况。
function c94142993.cfilter(c,tp,se)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsControler(tp) and (se==nil or c:GetReasonEffect()~=se)
end
-- ③号效果（墓地特召）的发动条件判断。
function c94142993.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c94142993.cfilter,1,nil,tp,se)
end
-- ③号效果（墓地特召）的发动准备与合法性检测。
function c94142993.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，表示该效果会将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③号效果（墓地特召）的效果处理。
function c94142993.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果关联，并尝试将自身以里侧守备表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 向对方玩家展示特殊召唤的里侧表示怪兽（确认是这张卡）。
		Duel.ConfirmCards(1-tp,c)
	end
end
