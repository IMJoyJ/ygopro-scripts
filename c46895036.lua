--ゴーストリック・デュラハン
-- 效果：
-- 1星怪兽×2
-- ①：这张卡的攻击力上升自己场上的「鬼计」卡数量×200。
-- ②：1回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成一半。这个效果在对方回合也能发动。
-- ③：这张卡被送去墓地的场合，以这张卡以外的自己墓地1张「鬼计」卡为对象才能发动。那张卡加入手卡。
function c46895036.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，需要满足条件的1只怪兽叠放2次
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
	-- 限制效果只能在伤害计算前的时机发动或适用
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
-- 过滤满足条件的「鬼计」卡（表侧表示）
function c46895036.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 计算场上「鬼计」卡数量并乘以200作为攻击力加成
function c46895036.atkval(e,c)
	-- 检索满足条件的「鬼计」卡数量
	return Duel.GetMatchingGroupCount(c46895036.atkfilter,c:GetControler(),LOCATION_ONFIELD,0,nil)*200
end
-- 支付1个超量素材作为代价
function c46895036.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 选择目标怪兽（表侧表示）
function c46895036.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) end
	-- 判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上一只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 将目标怪兽攻击力减半的效果处理
function c46895036.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 设置目标怪兽的攻击力为原来的一半
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		tc:RegisterEffect(e1)
	end
end
-- 过滤满足条件的「鬼计」卡（可加入手牌）
function c46895036.filter(c)
	return c:IsSetCard(0x8d) and c:IsAbleToHand()
end
-- 选择目标墓地中的「鬼计」卡
function c46895036.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46895036.filter(chkc) end
	-- 判断是否存在满足条件的目标墓地卡片
	if chk==0 then return Duel.IsExistingTarget(c46895036.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张墓地中的「鬼计」卡作为对象
	local g=Duel.SelectTarget(tp,c46895036.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置效果操作信息为将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 将目标卡加入手牌并确认对方可见
function c46895036.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认该卡的加入手牌动作
		Duel.ConfirmCards(1-tp,tc)
	end
end
