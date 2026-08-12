--ティーチャーマドルチェ・グラスフレ
-- 效果：
-- 4星「魔偶甜点」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡1个超量素材取除，以场上1只「魔偶甜点」怪兽为对象才能发动。这个回合，那只表侧表示怪兽不受自身以外的怪兽的效果影响。
-- ②：这张卡在怪兽区域存在的状态，「魔偶甜点」卡被送去自己墓地的场合才能发动。自己·对方的墓地的卡合计最多2张回到卡组。
function c20343502.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，需要满足种族为魔偶甜点且等级为4的怪兽2只作为素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x71),4,2)
	c:EnableReviveLimit()
	-- ①：自己·对方回合，把这张卡1个超量素材取除，以场上1只「魔偶甜点」怪兽为对象才能发动。这个回合，那只表侧表示怪兽不受自身以外的怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20343502,0))  --"效果抗性"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,20343502)
	e1:SetCost(c20343502.cost)
	e1:SetTarget(c20343502.target)
	e1:SetOperation(c20343502.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，「魔偶甜点」卡被送去自己墓地的场合才能发动。自己·对方的墓地的卡合计最多2张回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20343502,1))  --"墓地回收"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,20343503)
	e2:SetCondition(c20343502.tdcon)
	e2:SetTarget(c20343502.tdtg)
	e2:SetOperation(c20343502.tdop)
	c:RegisterEffect(e2)
end
-- 支付效果的代价，将自身1个超量素材移除
function c20343502.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足条件的怪兽：表侧表示且种族为魔偶甜点
function c20343502.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x71)
end
-- 设置效果的目标，选择场上1只满足条件的怪兽作为对象
function c20343502.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c20343502.filter(chkc) end
	-- 检查是否存在满足条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c20343502.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只满足条件的怪兽作为对象
	Duel.SelectTarget(tp,c20343502.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理效果的发动，使目标怪兽获得免疫效果
function c20343502.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽获得免疫效果，使其不受除自身外的怪兽效果影响
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c20343502.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断效果是否生效：目标怪兽不等于效果拥有者且效果为怪兽类型
function c20343502.efilter(e,re)
	return e:GetHandler()~=re:GetOwner() and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤满足条件的卡：控制者为指定玩家且种族为魔偶甜点
function c20343502.tgfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x71)
end
-- 判断效果是否满足发动条件：确认是否有魔偶甜点卡被送去墓地
function c20343502.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c20343502.tgfilter,1,nil,tp)
end
-- 设置效果的处理信息，准备将墓地的卡送回卡组
function c20343502.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡可以送回卡组
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 设置效果处理信息，指定将墓地的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_GRAVE)
end
-- 处理效果的发动，选择墓地的卡送回卡组
function c20343502.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1~2张可送回卡组的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,2,nil)
	if #g>0 then
		-- 显示所选卡作为对象的动画效果
		Duel.HintSelection(g)
		-- 将所选卡送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
