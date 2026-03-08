--ゼンマイバット
-- 效果：
-- 自己的主要阶段时才能发动。把自己场上表侧攻击表示存在的这张卡变更为表侧守备表示，选择自己墓地存在的1只名字带有「发条」的怪兽加入手卡。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c42328171.initial_effect(c)
	-- 创建效果，设置效果描述为检索，效果分类为回手牌效果，效果属性为取对象且此效果在场上表侧表示存在时只能使用1次，效果类型为起动效果，效果适用区域为场上主要怪兽区，效果使用次数限制为1次，效果发动条件为自身在场上有表侧攻击表示存在，效果对象为墓地的1只名字带有「发条」的怪兽，效果处理为将自身变更为表侧守备表示并选择墓地的1只名字带有「发条」的怪兽加入手牌
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42328171,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c42328171.thcon)
	e1:SetTarget(c42328171.thtg)
	e1:SetOperation(c42328171.thop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：自身必须处于表侧攻击表示
function c42328171.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 过滤函数：筛选名字带有「发条」的怪兽卡且能加入手牌
function c42328171.filter(c)
	return c:IsSetCard(0x58) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理的目标选择阶段：判断是否为对象选择阶段，若为对象选择阶段则筛选墓地的1只名字带有「发条」的怪兽作为目标，若非对象选择阶段则判断是否存在满足条件的墓地怪兽，若存在则提示玩家选择目标怪兽并设置操作信息
function c42328171.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c42328171.filter(chkc) end
	-- 判断是否满足发动条件：是否存在满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c42328171.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c42328171.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息：将选择的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理阶段：判断自身和目标怪兽是否仍然存在于效果处理中，若满足条件则将自身变更为表侧守备表示，将目标怪兽加入手牌并确认对方看到该怪兽
function c42328171.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) and c:IsControler(tp) and tc:IsRelateToEffect(e) then
		-- 将自身变更为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 确认对方看到目标怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
