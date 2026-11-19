--孤高除獣
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤时，从手卡把1只怪兽除外才能发动。种族和除外的怪兽相同的1只怪兽从卡组除外。
-- ②：这张卡被战斗或者对方的效果破坏的场合，以自己的除外状态的1只怪兽为对象才能发动。那只怪兽加入手卡。
function c92998610.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤时，从手卡把1只怪兽除外才能发动。种族和除外的怪兽相同的1只怪兽从卡组除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92998610,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,92998610)
	e1:SetCost(c92998610.cost)
	e1:SetTarget(c92998610.target)
	e1:SetOperation(c92998610.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡被战斗或者对方的效果破坏的场合，以自己的除外状态的1只怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,92998611)
	e2:SetCondition(c92998610.thcon)
	e2:SetTarget(c92998610.thtg)
	e2:SetOperation(c92998610.thop)
	c:RegisterEffect(e2)
end
-- ①效果的代价预处理函数：设置Label为100以标记已通过代价流程，实际除外代价将在target函数中配合合法性检查一并支付
function c92998610.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤条件函数：筛选手卡中可作为代价除外的怪兽，且卡组存在与其同种族的可除外怪兽
function c92998610.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查自己卡组是否存在至少1只与该手卡怪兽种族相同且可被除外的怪兽
		and Duel.IsExistingMatchingCard(c92998610.tgfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 过滤条件函数：筛选与指定怪兽种族相同且可以被除外的怪兽
function c92998610.tgfilter(c,rc)
	return c:IsAbleToRemove() and c:IsRace(rc:GetRace())
end
-- ①效果的合法性检查与代价支付函数：检查手卡是否有可除外且卡组有同种族怪兽的卡，选择手卡1只怪兽表侧除外作为代价并记录至LabelObject，同时登记从卡组除外1张卡的操作信息
function c92998610.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己手卡中是否存在至少1只符合代价与后续检索除外条件的怪兽
		return Duel.IsExistingMatchingCard(c92998610.cfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	-- 向玩家发送选择提示：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己手卡选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c92998610.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	-- 将选择的手卡怪兽以表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 向系统登记操作信息：将会从自己卡组除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理函数：获取作为代价除外的怪兽，从自己卡组选择1只与其种族相同的怪兽以表侧表示除外
function c92998610.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rc=e:GetLabelObject()
	-- 让玩家从自己卡组选择1只与代价除外怪兽种族相同且可除外的怪兽
	local g=Duel.SelectMatchingCard(tp,c92998610.tgfilter,tp,LOCATION_DECK,0,1,1,nil,rc)
	if g:GetCount()>0 then
		-- 将选择的卡组怪兽以效果表侧除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的发动条件函数：判断这张卡是否因战斗破坏，或原本由自己控制时因对方效果破坏
function c92998610.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 过滤条件函数：筛选表侧表示、属于怪兽卡且能加入手卡的卡
function c92998610.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的目标选择与检查函数：检查自己除外区是否存在可加入手卡的怪兽，选择1只作为对象并登记回手卡操作信息
function c92998610.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c92998610.thfilter(chkc) end
	-- 发动条件检查：确认自己除外区存在至少1只符合条件的可成为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c92998610.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家发送选择提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己除外区选择1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c92998610.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 向系统登记操作信息：将会把所选对象的1只怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理函数：若作为对象的除外状态怪兽仍与效果关联，则将其加入手卡
function c92998610.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象选择的除外状态怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果将对象怪兽加入持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
