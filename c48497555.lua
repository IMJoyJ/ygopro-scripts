--くず鉄の像
-- 效果：
-- 「废铁像」的①②的效果1回合各能使用1次。
-- ①：对方场上的已是表侧表示存在的魔法·陷阱卡把那个效果发动时才能发动。那张卡破坏。发动后这张卡不送去墓地，直接盖放。
-- ②：这张卡被送去墓地的场合，以自己墓地1只「废品」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c48497555.initial_effect(c)
	-- ①：对方场上的已是表侧表示存在的魔法·陷阱卡把那个效果发动时才能发动。那张卡破坏。发动后这张卡不送去墓地，直接盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,48497555)
	e1:SetCondition(c48497555.condition)
	e1:SetTarget(c48497555.target)
	e1:SetOperation(c48497555.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以自己墓地1只「废品」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,48497556)
	e2:SetTarget(c48497555.sptg)
	e2:SetOperation(c48497555.spop)
	c:RegisterEffect(e2)
end
-- 判断发动的效果是否为对方场上的魔法·陷阱卡的效果，并且该卡未被发动过（非激活效果）
function c48497555.condition(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsOnField() and rc:IsControler(1-tp) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 设置效果处理时要破坏的卡片为目标
function c48497555.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 设置当前连锁操作信息，包含破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 执行效果处理：若效果有效则破坏目标卡片，然后将自身盖放
function c48497555.activate(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 将目标卡片从场上破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsCanTurnSet() then
		-- 中断当前效果处理流程
		Duel.BreakEffect()
		c:CancelToGrave()
		-- 改变自身表示形式为里侧表示
		Duel.ChangePosition(c,POS_FACEDOWN)
		-- 触发放置魔陷时的时点事件
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
-- 筛选墓地中的「废品」怪兽作为特殊召唤对象
function c48497555.spfilter(c,e,tp)
	return c:IsSetCard(0x43) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断是否可以发动特殊召唤效果
function c48497555.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48497555.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在符合条件的「废品」怪兽
		and Duel.IsExistingTarget(c48497555.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡片作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c48497555.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁操作信息，包含特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤效果：将选中的墓地怪兽守备表示特殊召唤到场上
function c48497555.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
