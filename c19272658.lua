--エクシーズ弁当
-- 效果：
-- ①：对方场上的怪兽被战斗破坏的场合或者被送去墓地的场合，以自己场上1只超量怪兽为对象才能发动。从对方墓地选1只怪兽在作为对象的怪兽下面重叠作为超量素材。
-- ②：把墓地的这张卡除外，以从额外卡组特殊召唤的场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
function c19272658.initial_effect(c)
	-- ①：对方场上的怪兽被战斗破坏的场合或者被送去墓地的场合，以自己场上1只超量怪兽为对象才能发动。从对方墓地选1只怪兽在作为对象的怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(c19272658.ovcon)
	e1:SetTarget(c19272658.ovtg)
	e1:SetOperation(c19272658.ovop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以从额外卡组特殊召唤的场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 将这张卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c19272658.postg)
	e3:SetOperation(c19272658.posop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断被破坏或送去墓地的怪兽是否为对方场上从前在怪兽区的怪兽
function c19272658.cfilter(c,tp)
	return c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果条件，判断是否有对方场上的怪兽被战斗破坏或送去墓地
function c19272658.ovcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19272658.cfilter,1,nil,tp)
end
-- 过滤函数，用于筛选自己场上的表侧表示的超量怪兽
function c19272658.ovfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- 过滤函数，用于筛选可以作为超量素材的怪兽
function c19272658.ovfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 效果的发动时点处理，判断是否满足发动条件
function c19272658.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19272658.ovfilter(chkc) end
	-- 判断自己场上是否存在满足条件的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c19272658.ovfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方墓地是否存在怪兽
		and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_GRAVE,1,nil,TYPE_MONSTER) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的超量怪兽作为效果对象
	Duel.SelectTarget(tp,c19272658.ovfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示将从对方墓地检索怪兽作为超量素材
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,1-tp,LOCATION_GRAVE)
end
-- 效果处理函数，执行将对方墓地的怪兽作为超量素材叠放至己方超量怪兽的操作
function c19272658.ovop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取对方墓地中满足条件的怪兽组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c19272658.ovfilter2),tp,0,LOCATION_GRAVE,nil)
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and g:GetCount()>0 then
		-- 提示玩家选择要作为超量素材的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽叠放至目标怪兽下方作为超量素材
		Duel.Overlay(tc,sg)
	end
end
-- 过滤函数，用于筛选从额外卡组特殊召唤的怪兽
function c19272658.posfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsCanChangePosition()
end
-- 效果的发动时点处理，判断是否满足发动条件
function c19272658.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c19272658.posfilter(chkc) end
	-- 判断场上是否存在满足条件的从额外卡组特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingTarget(c19272658.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的从额外卡组特殊召唤的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c19272658.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示将改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理函数，执行将目标怪兽的表示形式变更的操作
function c19272658.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为表侧守备表示或表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
