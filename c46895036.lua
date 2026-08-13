--ゴーストリック・デュラハン
-- 效果：
-- 1星怪兽×2
-- ①：这张卡的攻击力上升自己场上的「鬼计」卡数量×200。
-- ②：1回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成一半。这个效果在对方回合也能发动。
-- ③：这张卡被送去墓地的场合，以这张卡以外的自己墓地1张「鬼计」卡为对象才能发动。那张卡加入手卡。
function c46895036.initial_effect(c)
	-- 为这张卡添加超量召唤规则：以2只1星怪兽作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升自己场上的「鬼计」卡数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c46895036.atkval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成一半。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46895036,0))  --"攻击降低"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	-- 设置②效果的发动条件，限制在伤害步骤中只能在伤害计算前发动（不能在伤害计算后发动）。
	e2:SetCondition(aux.dscon)
	e2:SetCost(c46895036.cost)
	e2:SetTarget(c46895036.target)
	e2:SetOperation(c46895036.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以这张卡以外的自己墓地1张「鬼计」卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetDescription(aux.Stringid(46895036,1))  --"返回手卡"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(c46895036.thtg)
	e3:SetOperation(c46895036.thop)
	c:RegisterEffect(e3)
end
-- 定义攻击力上升效果中“自己场上的「鬼计」卡”的过滤条件：表侧表示且属于「鬼计」系列。
function c46895036.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 定义这张卡的攻击力上升数值的计算函数：统计自己场上表侧表示的「鬼计」卡数量并乘以200。
function c46895036.atkval(e,c)
	-- 返回这张卡的控制者场上表侧表示且属于「鬼计」系列的卡的数量乘以200，作为攻击力的上升值。
	return Duel.GetMatchingGroupCount(c46895036.atkfilter,c:GetControler(),LOCATION_ONFIELD,0,nil)*200
end
-- 定义②效果的发动代价：取除这张卡的1个超量素材（作为发动代价）。
function c46895036.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义②效果的取对象处理：选择场上1只表侧表示怪兽作为对象。
function c46895036.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) end
	-- 效果发动合法条件检查：场上是否存在至少1只表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只表侧表示怪兽作为效果对象，并将该卡设定为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 定义②效果的处理：将作为对象的表侧表示怪兽的攻击力变为当前攻击力的一半，直到回合结束。
function c46895036.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该效果选择的第1个对象怪兽（即之前选择的表侧表示怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- ②：那只怪兽的攻击力直到回合结束时变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		tc:RegisterEffect(e1)
	end
end
-- 定义③效果可选的墓地「鬼计」卡过滤条件：属于「鬼计」系列且可以加入手卡。
function c46895036.filter(c)
	return c:IsSetCard(0x8d) and c:IsAbleToHand()
end
-- 定义③效果的取对象处理：选择这张卡以外的自己墓地1张「鬼计」卡作为对象。
function c46895036.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46895036.filter(chkc) end
	-- 效果发动合法条件检查：自己墓地是否存在这张卡以外、能被加入手卡的「鬼计」卡。
	if chk==0 then return Duel.IsExistingTarget(c46895036.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 给玩家显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的「鬼计」卡作为效果对象，并设定为连锁对象。
	local g=Duel.SelectTarget(tp,c46895036.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置操作信息，声明本效果将把对象卡加入手卡（CATEGORY_TOHAND），用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义③效果的处理：将对象「鬼计」卡加入手卡，并向对方玩家展示该卡。
function c46895036.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该效果选择的第1个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示这张被加入手卡的卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
