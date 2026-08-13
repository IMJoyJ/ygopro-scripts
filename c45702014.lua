--エレメントセイバー・モーレフ
-- 效果：
-- ①：1回合1次，从手卡把1只「元素灵剑士」怪兽送去墓地，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
function c45702014.initial_effect(c)
	-- ①：1回合1次，从手卡把1只「元素灵剑士」怪兽送去墓地，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45702014,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c45702014.setcost)
	e1:SetTarget(c45702014.settg)
	e1:SetOperation(c45702014.setop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45702014,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(c45702014.atttg)
	e2:SetOperation(c45702014.attop)
	c:RegisterEffect(e2)
end
-- costfilter是支付cost时的筛选条件：要求该卡是「元素灵剑士」怪兽、类型为怪兽，并且可以作为cost送入墓地。
function c45702014.costfilter(c)
	return c:IsSetCard(0x400d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- setcost为①效果的cost支付处理：先根据是否适用「灵神的圣殿」的效果来确定可选区域（仅手卡或手卡+卡组），然后让玩家选择1张符合条件的「元素灵剑士」怪兽，若从卡组选择则消耗「灵神的圣殿」的次数并展示其卡图，最后将选择的卡作为cost送去墓地。
function c45702014.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家tp是否被「灵神的圣殿」（61557074）的效果影响，以决定cost是否可以从卡组代替手卡将「元素灵剑士」怪兽送去墓地。
	local fe=Duel.IsPlayerAffectedByEffect(tp,61557074)
	local loc=LOCATION_HAND
	if fe then loc=LOCATION_HAND+LOCATION_DECK end
	-- 在cost检测阶段（chk==0）判断：玩家tp在可选区域（手卡或手卡+卡组）是否存在至少1张满足costfilter条件的「元素灵剑士」怪兽，作为该效果能否发动的前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c45702014.costfilter,tp,loc,0,1,nil) end
	-- 向玩家tp显示选择提示“请选择要送去墓地的卡”，用于后续SelectMatchingCard的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家tp从可选区域（手卡或手卡+卡组）中选择1张满足costfilter条件的卡，并取出选中的这张卡作为cost素材。
	local tc=Duel.SelectMatchingCard(tp,c45702014.costfilter,tp,loc,0,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_DECK) then
		-- 当选中的卡来自卡组时，通过HINT_CARD展示「灵神的圣殿」（61557074）的卡片动画，提示玩家正在适用「灵神的圣殿」的代替送墓效果。
		Duel.Hint(HINT_CARD,0,61557074)
		fe:UseCountLimit(tp)
	end
	-- 将选中的「元素灵剑士」怪兽以cost原因（REASON_COST）送去墓地，完成cost支付。
	Duel.SendtoGrave(tc,REASON_COST)
end
-- setfilter是①效果取对象时的目标筛选条件：必须是表侧表示且可以被变成里侧守备表示（即可以被盖放）的怪兽。
function c45702014.setfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- settg是①效果的发动时处理：验证是否存在合法对象，若存在则让玩家选择场上1只表侧且可盖放的怪兽作为对象，并设置操作信息为改变该对象表示形式。
function c45702014.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c45702014.setfilter(chkc) end
	-- 在目标检测阶段（chk==0）检查场上是否存在至少1只表侧表示且可被盖放的怪兽，作为该效果能够选取对象的条件。
	if chk==0 then return Duel.IsExistingTarget(c45702014.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家tp显示选择提示“请选择要改变表示形式的怪兽”，用于后续SelectTarget的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家tp从场上双方怪兽区域选择1只满足setfilter条件的表侧怪兽作为效果对象（取对象），同时将该对象与当前连锁效果建立联系。
	local g=Duel.SelectTarget(tp,c45702014.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：将对象怪兽g的表示形式变更（CATEGORY_POSITION）作为效果处理内容，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- setop是①效果的实际处理函数：取得效果对象，若对象仍然表侧表示且与效果e保持联系，则将其变为里侧守备表示。
function c45702014.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中第一个（也是唯一的）效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式变更为里侧守备表示（POS_FACEDOWN_DEFENSE）。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- atttg是②效果的发动与处理前操作：由于发动无额外条件，先让玩家宣言1个属性，将宣言结果记录到effect的label中，并设置操作信息表示该卡将从墓地离开（用于触发王家长眠之谷等干扰检测）。
function c45702014.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家tp显示选择提示“请选择要宣言的属性”，用于后续AnnounceAttribute的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家tp从所有属性中排除这张卡当前属性后的属性里宣言1个属性，并将该属性值作为效果标签保存。
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
	e:SetLabel(att)
	-- 设置操作信息：将这张墓地的卡（e:GetHandler()）作为从墓地移动/使用的对象，数量为1，操作方为tp，位置为墓地，以便相关效果（如王家长眠之谷）进行检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- attop是②效果的实际处理函数：若这张卡仍与效果e保持联系，则创建一个改变属性的效果，使这张卡在回合结束前属性变成宣言的属性。
function c45702014.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 墓地的这张卡直到回合结束时变成宣言的属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
