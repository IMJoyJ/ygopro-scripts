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
	-- ③：这张卡被送去墓地的回合的结束阶段，以「弹丸特急 子弹快车」以外的自己墓地1只机械族怪兽为对象才能发动。那只怪兽加入手卡。
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
-- 过滤条件：表侧表示的机械族·地属性怪兽
function c52481437.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 特殊召唤效果的发动条件：自己场上有怪兽存在，且全部是机械族·地属性怪兽
function c52481437.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g>0 and g:FilterCount(c52481437.cfilter,nil)==#g
end
-- 特殊召唤效果的靶向/发动检测：检查怪兽区域是否有空位且自身能否特殊召唤，并设置特殊召唤的操作信息
function c52481437.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在chk==0时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的执行：若自身仍存在于手卡，则将自身表侧表示特殊召唤
function c52481437.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到自己的场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 攻击宣言代价的检测：检查自己场上是否存在除自身以外的2张可以送去墓地的卡
function c52481437.atcost(e,c,tp)
	-- 检查自己场上是否存在至少2张除自身以外可以作为代价送去墓地的卡
	return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,2,e:GetHandler())
end
-- 攻击宣言代价的执行：选择自己场上除自身以外的2张卡送去墓地
function c52481437.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上除自身以外的2张可以作为代价送去墓地的卡
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,2,2,e:GetHandler())
	-- 将选择的卡作为代价送去墓地
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 送去墓地时的处理：给自身注册一个持续到回合结束的标记，用于记录本回合被送去墓地
function c52481437.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(52481437,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤条件：自己墓地中「弹丸特急 子弹快车」以外的可以加入手卡的机械族怪兽
function c52481437.thfilter(c)
	return c:IsRace(RACE_MACHINE) and not c:IsCode(52481437) and c:IsAbleToHand()
end
-- 回收效果的发动条件：自身在本回合被送去过墓地（检查是否存在对应的标记）
function c52481437.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(52481437)>0
end
-- 回收效果的靶向/发动检测：选择自己墓地1只满足条件的机械族怪兽作为对象，并设置加入手卡的操作信息
function c52481437.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c52481437.thfilter(chkc) end
	-- 在chk==0时，检查自己墓地是否存在至少1只满足条件的机械族怪兽
	if chk==0 then return Duel.IsExistingTarget(c52481437.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足条件的机械族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c52481437.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置加入手卡的操作信息，表示将墓地中选择的对象加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end
-- 回收效果的执行：将选择的墓地怪兽加入手卡
function c52481437.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽因效果加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
