--百鬼羅刹 巨魁ガボンガ
-- 效果：
-- 3星怪兽×2
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从卡组把1只「哥布林」怪兽加入手卡。
-- ②：场上的超量素材被取除的场合，以场上1只其他的表侧表示怪兽为对象才能发动。那只怪兽作为这张卡的超量素材。
-- ③：自己·对方的结束阶段才能发动。从卡组把1只「哥布林」怪兽作为这张卡的超量素材。
function c34001672.initial_effect(c)
	-- 启用全局标记，使游戏能够监听超量素材被取除的事件，为②效果提供触发条件。
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	-- 为这张卡添加超量召唤手续：用2只等级3的怪兽作为素材进行超量召唤，对应『3星怪兽×2』。
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
-- ①效果的发动条件：这张卡成功进行超量召唤（召唤类型为XYZ）时才可发动。
function c34001672.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- ①效果检索的筛选条件：满足「哥布林」字段、是怪兽卡且可以加入手卡。
function c34001672.filter(c)
	return c:IsSetCard(0xac) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
-- ①效果的发动时点判定与效果信息登记：确认卡组中有符合条件的「哥布林」怪兽则可以发动；同时向系统声明本次操作会将卡组中的卡加入手卡。
function c34001672.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中至少存在1只满足条件的「哥布林」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c34001672.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果处理时将从卡组把1只怪兽加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1只「哥布林」怪兽加入手卡，并让对方确认加入手卡的卡。
function c34001672.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，引导玩家从卡组选择要加入手卡的「哥布林」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张满足filter条件的「哥布林」怪兽。
	local g=Duel.SelectMatchingCard(tp,c34001672.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示自己加入手卡的怪兽，完成检索确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果选择对象的筛选条件：场上表侧表示怪兽，且可以作为超量素材。
function c34001672.xmfilter(c)
	return c:IsFaceup() and c:IsCanOverlay()
end
-- ②效果触发条件：检测到场上（怪兽区域）有超量素材被取除的事件发生。
function c34001672.xmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
end
-- ②效果的取对象选择：选择场上1只其他怪兽作为对象，该对象必须表侧表示且可作为超量素材，不能选择这张卡自身。
function c34001672.xmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return (chkc:IsLocation(LOCATION_MZONE)) and (chkc~=c) and (c34001672.xmfilter(chkc)) end
	-- 对象选择合法性检查：场上是否存在除这张卡以外的、满足条件的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c34001672.xmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 弹出选择提示，引导玩家选择要作为超量素材的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从场上选择1只表侧表示且可作为超量素材的其他怪兽，并将其设置为效果对象。
	Duel.SelectTarget(tp,c34001672.xmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
end
-- ②效果处理：将选择的对象怪兽作为这张卡的超量素材；若对象怪兽自身带有超量素材，则先将那些素材按规则送入墓地。
function c34001672.xmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果所选定的对象怪兽（即要叠放为超量素材的怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将对象怪兽原本持有的超量素材按规则送去墓地（超量怪兽作为素材时其素材不随之叠放）。
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将目标怪兽叠放在这张卡下方，作为这张卡的超量素材。
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- ③效果从卡组选素材的筛选条件：满足「哥布林」字段、是怪兽卡且可以作为超量素材。
function c34001672.mtfilter(c)
	return c:IsSetCard(0xac) and c:IsCanOverlay() and c:IsType(TYPE_MONSTER)
end
-- ③效果的发动条件：这张卡是超量怪兽，并且卡组中存在可以叠放的「哥布林」怪兽；同时该效果只在结束阶段的事件中触发。
function c34001672.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 确认卡组中是否存在至少1只满足条件的「哥布林」怪兽，保证③效果可以发动并处理。
		and Duel.IsExistingMatchingCard(c34001672.mtfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ③效果处理：从卡组选择1只「哥布林」怪兽，将其作为这张卡的超量素材叠放。
function c34001672.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 弹出选择提示，引导玩家从卡组选择要作为超量素材的「哥布林」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从卡组中选出1张满足mtfilter条件的「哥布林」怪兽。
	local g=Duel.SelectMatchingCard(tp,c34001672.mtfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「哥布林」怪兽叠放在这张卡下方，作为这张卡的超量素材。
		Duel.Overlay(c,g)
	end
end
