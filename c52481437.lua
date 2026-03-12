--弾丸特急バレット・ライナー
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上的怪兽只有机械族·地属性怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的攻击宣言之际，自己必须把这张卡以外的自己场上2张卡送去墓地。
-- ③：这张卡被送去墓地的回合的结束阶段，以「弹丸特急 子弹快车」以外的自己墓地1只机械族怪兽为对象才能发动。那只怪兽加入手卡。
function c52481437.initial_effect(c)
	-- ①：自己场上的怪兽只有机械族·地属性怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52481437,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,52481437)
	e1:SetCondition(c52481437.spcon)
	e1:SetTarget(c52481437.sptg)
	e1:SetOperation(c52481437.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击宣言之际，自己必须把这张卡以外的自己场上2张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_COST)
	e2:SetCost(c52481437.atcost)
	e2:SetOperation(c52481437.atop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的回合的结束阶段，以「弹丸特急 子弹快车」以外的自己墓地1只机械族怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c52481437.regop)
	c:RegisterEffect(e3)
	-- 效果作用
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(52481437,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1,52481438)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(c52481437.thcon)
	e4:SetTarget(c52481437.thtg)
	e4:SetOperation(c52481437.thop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上是否为机械族地属性怪兽
function c52481437.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 判断场上是否只有机械族地属性怪兽
function c52481437.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g>0 and g:FilterCount(c52481437.cfilter,nil)==#g
end
-- 设置特殊召唤的处理信息
function c52481437.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤的操作
function c52481437.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 攻击时支付墓地费用的判断函数
function c52481437.atcost(e,c,tp)
	-- 检查是否满足支付2张场上的卡送去墓地的条件
	return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,2,e:GetHandler())
end
-- 执行攻击时支付墓地费用的操作
function c52481437.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择2张场上可送去墓地的卡
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,2,2,e:GetHandler())
	-- 将选中的卡送去墓地作为攻击代价
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 注册标记，用于记录此卡被送去墓地的回合
function c52481437.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(52481437,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数，用于筛选墓地中符合条件的机械族怪兽
function c52481437.thfilter(c)
	return c:IsRace(RACE_MACHINE) and not c:IsCode(52481437) and c:IsAbleToHand()
end
-- 判断是否为被送去墓地的回合
function c52481437.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(52481437)>0
end
-- 设置效果处理时的目标选择信息
function c52481437.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c52481437.thfilter(chkc) end
	-- 检查是否有满足条件的墓地目标
	if chk==0 then return Duel.IsExistingTarget(c52481437.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张符合条件的墓地怪兽
	local g=Duel.SelectTarget(tp,c52481437.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示将要将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
-- 执行将墓地怪兽加入手牌的操作
function c52481437.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
