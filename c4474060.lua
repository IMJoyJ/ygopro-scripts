--SPYRAL GEAR－ドローン
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从对方卡组上面把3张卡确认，用喜欢的顺序回到卡组上面。
-- ②：把这张卡解放，以自己场上1只「秘旋谍」怪兽为对象才能发动。那只怪兽的攻击力上升对方场上的卡数量×500。这个效果在对方回合也能发动。
-- ③：从自己墓地把这张卡和1张「秘旋谍」卡除外，以自己墓地1只「秘旋谍-花公子」为对象才能发动。那张卡加入手卡。
function c4474060.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从对方卡组上面把3张卡确认，用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4474060,0))  --"确认对方卡组上方3张卡"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c4474060.sttg)
	e1:SetOperation(c4474060.stop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把这张卡解放，以自己场上1只「秘旋谍」怪兽为对象才能发动。那只怪兽的攻击力上升对方场上的卡数量×500。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4474060,1))  --"攻击力上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e3:SetCondition(aux.dscon)
	e3:SetCost(c4474060.atkcost)
	e3:SetTarget(c4474060.atktg)
	e3:SetOperation(c4474060.atkop)
	c:RegisterEffect(e3)
	-- ③：从自己墓地把这张卡和1张「秘旋谍」卡除外，以自己墓地1只「秘旋谍-花公子」为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4474060,2))  --"墓地回收"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(c4474060.thcost)
	e4:SetTarget(c4474060.thtg)
	e4:SetOperation(c4474060.thop)
	c:RegisterEffect(e4)
end
-- 检查对方卡组上方是否有至少3张卡
function c4474060.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 对方卡组上方卡数量大于2
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>2 end
end
-- 对对方卡组最上方3张卡进行排序
function c4474060.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方卡组最上方3张卡按选择顺序放回卡组顶部
	Duel.SortDecktop(tp,1-tp,3)
end
-- 支付效果代价，解放自身
function c4474060.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从游戏中除外作为效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 判断目标是否为表侧表示的「秘旋谍」怪兽
function c4474060.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xee)
end
-- 选择一只自己场上的「秘旋谍」怪兽作为效果对象
function c4474060.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c4474060.atkfilter(chkc) end
	-- 检查自己场上是否有怪兽存在
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 and
		-- 确认自己场上是否存在「秘旋谍」怪兽作为效果对象
		Duel.IsExistingTarget(c4474060.atkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一只自己场上的「秘旋谍」怪兽作为效果对象
	Duel.SelectTarget(tp,c4474060.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将效果对象怪兽的攻击力上升对方场上的卡数量×500
function c4474060.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 计算对方场上的卡数量并乘以500作为攻击力提升值
		local atk=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)*500
		-- 将攻击力提升效果应用到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断墓地中的卡是否为「秘旋谍」卡且可被除外
function c4474060.cfilter(c,tp)
	return c:IsSetCard(0xee) and c:IsAbleToRemoveAsCost()
		-- 确认墓地是否存在「秘旋谍-花公子」怪兽作为效果对象
		and Duel.IsExistingTarget(c4474060.thfilter,tp,LOCATION_GRAVE,0,1,c)
end
-- 判断目标是否为「秘旋谍-花公子」怪兽
function c4474060.thfilter(c)
	return c:IsCode(41091257) and c:IsAbleToHand()
end
-- 支付效果代价，除外自身和一张「秘旋谍」卡
function c4474060.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 确认墓地是否存在满足条件的「秘旋谍」卡
		and Duel.IsExistingMatchingCard(c4474060.cfilter,tp,LOCATION_GRAVE,0,1,c,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张满足条件的「秘旋谍」卡和自身作为除外对象
	local g=Duel.SelectMatchingCard(tp,c4474060.cfilter,tp,LOCATION_GRAVE,0,1,1,c,tp)
	g:AddCard(c)
	-- 将选择的卡除外作为效果的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 选择一张「秘旋谍-花公子」怪兽加入手牌
function c4474060.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4474060.thfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张「秘旋谍-花公子」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c4474060.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，指定将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 将效果对象怪兽加入手牌
function c4474060.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
