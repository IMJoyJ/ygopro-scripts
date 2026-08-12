--光波異邦臣
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡在手卡·墓地存在的场合，以自己场上1只「光波」超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把1张「光波」魔法·陷阱卡加入手卡。
function c79094383.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，以自己场上1只「光波」超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79094383,0))  --"这张卡作为超量素材"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCountLimit(1,79094383)
	e1:SetTarget(c79094383.mattg)
	e1:SetOperation(c79094383.matop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把1张「光波」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79094383,1))  --"「光波」魔法·陷阱卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,79094383)
	e2:SetTarget(c79094383.thtg)
	e2:SetOperation(c79094383.thop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「光波」超量怪兽
function c79094383.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe5) and c:IsType(TYPE_XYZ)
end
-- 效果①的发动准备与合法性检测
function c79094383.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c79094383.matfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「光波」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c79094383.matfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「光波」超量怪兽作为对象
	Duel.SelectTarget(tp,c79094383.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 若此卡在墓地发动，设置此卡离开墓地的操作信息
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- 效果①的处理，将此卡重叠在作为对象的怪兽下面作为超量素材
function c79094383.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsCanOverlay() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 将此卡重叠在目标怪兽下面作为超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
-- 过滤卡组中可以加入手牌的「光波」魔法·陷阱卡
function c79094383.thfilter(c)
	return c:IsSetCard(0xe5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的发动准备与操作信息设置
function c79094383.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「光波」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c79094383.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组的1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理，从卡组选择1张「光波」魔法·陷阱卡加入手牌并给对方确认
function c79094383.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的「光波」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c79094383.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
