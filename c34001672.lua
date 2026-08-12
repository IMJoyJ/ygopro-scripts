--百鬼羅刹 巨魁ガボンガ
-- 效果：
-- 3星怪兽×2
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从卡组把1只「哥布林」怪兽加入手卡。
-- ②：场上的超量素材被取除的场合，以场上1只其他的表侧表示怪兽为对象才能发动。那只怪兽作为这张卡的超量素材。
-- ③：自己·对方的结束阶段才能发动。从卡组把1只「哥布林」怪兽作为这张卡的超量素材。
function c34001672.initial_effect(c)
	-- 设置全局标记，用于监听超量素材被去除的事件
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	-- 为卡片添加超量召唤手续，使用3星怪兽2只进行超量召唤
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合才能发动。从卡组把1只「哥布林」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34001672,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,34001672)
	e1:SetCondition(c34001672.thcon)
	e1:SetTarget(c34001672.thtg)
	e1:SetOperation(c34001672.thop)
	c:RegisterEffect(e1)
	-- ②：场上的超量素材被取除的场合，以场上1只其他的表侧表示怪兽为对象才能发动。那只怪兽作为这张卡的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34001672,1))  --"场上怪兽作为超量素材"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DETACH_MATERIAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,34001672+100)
	e2:SetCondition(c34001672.xmcon)
	e2:SetTarget(c34001672.xmtg)
	e2:SetOperation(c34001672.xmop)
	c:RegisterEffect(e2)
	-- ③：自己·对方的结束阶段才能发动。从卡组把1只「哥布林」怪兽作为这张卡的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34001672,2))  --"卡组怪兽作为超量素材"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,34001672+1)
	e3:SetTarget(c34001672.mttg)
	e3:SetOperation(c34001672.mtop)
	c:RegisterEffect(e3)
end
-- 效果条件：确认此卡是否为超量召唤
function c34001672.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 检索过滤器：筛选卡组中种族为哥布林且能加入手牌的怪兽
function c34001672.filter(c)
	return c:IsSetCard(0xac) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
-- 效果目标：检查卡组中是否存在满足条件的哥布林怪兽
function c34001672.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果目标：检查卡组中是否存在满足条件的哥布林怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c34001672.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：指定效果将从卡组检索1张哥布林怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择并把符合条件的哥布林怪兽加入手牌并确认
function c34001672.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择：提示玩家选择要加入手牌的哥布林怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择卡片：从卡组中选择1张符合条件的哥布林怪兽
	local g=Duel.SelectMatchingCard(tp,c34001672.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 操作：将选中的哥布林怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认卡片：向对方确认加入手牌的哥布林怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 取对象过滤器：筛选场上表侧表示且能作为超量素材的怪兽
function c34001672.xmfilter(c)
	return c:IsFaceup() and c:IsCanOverlay()
end
-- 效果条件：确认是否有怪兽从场上被去除超量素材
function c34001672.xmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
end
-- 效果目标：选择场上其他表侧表示且能作为超量素材的怪兽
function c34001672.xmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return (chkc:IsLocation(LOCATION_MZONE)) and (chkc~=c) and (c34001672.xmfilter(chkc)) end
	-- 效果目标：检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c34001672.xmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 提示选择：提示玩家选择要作为超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择对象：选择场上1只符合条件的怪兽作为超量素材
	Duel.SelectTarget(tp,c34001672.xmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
end
-- 效果处理：将选中的怪兽叠放至本卡上
function c34001672.xmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对象：获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 操作：将目标怪兽身上的叠放卡送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 操作：将目标怪兽叠放至本卡上
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- 检索过滤器：筛选卡组中种族为哥布林且能叠放的怪兽
function c34001672.mtfilter(c)
	return c:IsSetCard(0xac) and c:IsCanOverlay() and c:IsType(TYPE_MONSTER)
end
-- 效果目标：检查卡组中是否存在满足条件的哥布林怪兽
function c34001672.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 效果目标：检查卡组中是否存在满足条件的哥布林怪兽
		and Duel.IsExistingMatchingCard(c34001672.mtfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：选择并把符合条件的哥布林怪兽叠放至本卡上
function c34001672.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示选择：提示玩家选择要作为超量素材的哥布林怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择卡片：从卡组中选择1张符合条件的哥布林怪兽
	local g=Duel.SelectMatchingCard(tp,c34001672.mtfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 操作：将选中的哥布林怪兽叠放至本卡上
		Duel.Overlay(c,g)
	end
end
