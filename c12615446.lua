--電子光虫－スカラジエータ
-- 效果：
-- 昆虫族·光属性3星怪兽×2只以上
-- ①：1回合1次，把这张卡2个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽的表示形式变更，那个效果直到回合结束时无效。这个效果在对方回合也能发动。
-- ②：1回合1次，这张卡战斗破坏对方怪兽送去墓地时才能发动。破坏的那只怪兽在这张卡下面重叠作为超量素材。
function c12615446.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，要求满足条件的怪兽等级为3，数量为2只以上
	aux.AddXyzProcedure(c,c12615446.matfilter,3,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡2个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽的表示形式变更，那个效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12615446,0))  --"效果无效"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DISABLE)
	e1:SetCountLimit(1)
	e1:SetCost(c12615446.poscost)
	e1:SetTarget(c12615446.postg)
	e1:SetOperation(c12615446.posop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡战斗破坏对方怪兽送去墓地时才能发动。破坏的那只怪兽在这张卡下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12615446,1))  --"增加素材"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1)
	e2:SetCondition(c12615446.xyzcon)
	e2:SetTarget(c12615446.xyztg)
	e2:SetOperation(c12615446.xyzop)
	c:RegisterEffect(e2)
end
-- 判断怪兽是否为昆虫族且光属性
function c12615446.matfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 支付效果代价，从自身取除2个超量素材
function c12615446.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 选择对方场上的1只可以变更表示形式的怪兽作为效果对象
function c12615446.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
	-- 检查是否存在可以变更表示形式的对方怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择对方场上的1只可以变更表示形式的怪兽
	Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 处理效果的发动和处理过程
function c12615446.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否有效且成功变更表示形式，并满足被无效化的条件
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0 and (tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e)) then
		-- 使对象卡相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使对象卡的效果在回合结束时无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使对象卡的效果在回合结束时无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 判断是否满足效果发动条件
function c12615446.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if not c:IsRelateToBattle() then return false end
	e:SetLabelObject(tc)
	return tc:IsLocation(LOCATION_GRAVE) and tc:IsType(TYPE_MONSTER) and tc:IsReason(REASON_BATTLE) and tc:IsCanOverlay()
end
-- 设置效果处理时的目标卡
function c12615446.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
	local tc=e:GetLabelObject()
	-- 设置效果处理时的目标卡
	Duel.SetTargetCard(tc)
	-- 设置效果处理时的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
-- 处理效果的发动和处理过程
function c12615446.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanOverlay() then
		-- 将目标卡作为超量素材叠放至自身
		Duel.Overlay(c,tc)
	end
end
