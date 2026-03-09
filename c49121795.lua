--重装甲列車アイアン・ヴォルフ
-- 效果：
-- 机械族4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只机械族怪兽为对象才能发动。这个回合，那只怪兽以外的怪兽不能攻击，那只怪兽可以直接攻击。
-- ②：这张卡被对方破坏送去墓地的场合才能发动。从卡组把1只机械族·4星怪兽加入手卡。
function c49121795.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用满足种族为机械族条件的4星怪兽作为素材进行叠放，需要2只怪兽
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只机械族怪兽为对象才能发动。这个回合，那只怪兽以外的怪兽不能攻击，那只怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49121795,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c49121795.dacon)
	e1:SetCost(c49121795.dacost)
	e1:SetTarget(c49121795.datg)
	e1:SetOperation(c49121795.daop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏送去墓地的场合才能发动。从卡组把1只机械族·4星怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49121795,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c49121795.thcon)
	e2:SetTarget(c49121795.thtg)
	e2:SetOperation(c49121795.thop)
	c:RegisterEffect(e2)
end
-- 判断是否能进入战斗阶段，用于效果①的发动条件
function c49121795.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否能进入战斗阶段，用于效果①的发动条件
	return Duel.IsAbleToEnterBP()
end
-- 支付效果①的代价，移除1个超量素材
function c49121795.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足条件的机械族怪兽（表侧表示且未拥有直接攻击效果）
function c49121795.dafilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and not c:IsHasEffect(EFFECT_DIRECT_ATTACK)
end
-- 选择目标怪兽，要求为己方场上表侧表示的机械族怪兽
function c49121795.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c49121795.dafilter(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c49121795.dafilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只己方场上的机械族怪兽作为对象
	Duel.SelectTarget(tp,c49121795.dafilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果①的发动效果，设置不能攻击的效果并赋予目标怪兽直接攻击效果
function c49121795.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 创建一个影响全场怪兽的不能攻击效果，仅对目标怪兽以外的怪兽生效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c49121795.ftarget)
	e1:SetLabel(tc:GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能攻击效果注册到游戏环境
	Duel.RegisterEffect(e1,tp)
	if tc:IsRelateToEffect(e) then
		-- 为被选中的怪兽添加直接攻击效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 判断目标怪兽是否与当前效果中指定的怪兽不同（用于设置不能攻击效果）
function c49121795.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 判断该卡是否在对方破坏并送去墓地时触发效果②
function c49121795.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_DESTROY)
end
-- 过滤满足条件的机械族4星怪兽（可加入手牌）
function c49121795.thfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsLevel(4) and c:IsAbleToHand()
end
-- 设置效果②的发动目标，检查是否有符合条件的怪兽可以检索
function c49121795.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c49121795.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要从卡组检索1张机械族4星怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果②的发动效果，从卡组选择1只机械族4星怪兽加入手牌并确认
function c49121795.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张机械族4星怪兽
	local g=Duel.SelectMatchingCard(tp,c49121795.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
