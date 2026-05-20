--破壊剣士の宿命
-- 效果：
-- 「破坏剑士的宿命」的①②的效果1回合各能使用1次。
-- ①：以对方墓地最多3只相同种族的怪兽为对象才能发动。那些怪兽除外，选自己场上1只「破坏之剑士」怪兽或者「破坏剑」怪兽，直到回合结束时那个攻击力·守备力上升除外的怪兽数量×500。
-- ②：这张卡在墓地存在的场合，从手卡丢弃1张「破坏剑」卡才能发动。墓地的这张卡加入手卡。
function c78348934.initial_effect(c)
	-- ①：以对方墓地最多3只相同种族的怪兽为对象才能发动。那些怪兽除外，选自己场上1只「破坏之剑士」怪兽或者「破坏剑」怪兽，直到回合结束时那个攻击力·守备力上升除外的怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,78348934)
	-- 设置效果的发动条件，限制该效果不能在伤害计算后发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c78348934.target)
	e1:SetOperation(c78348934.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从手卡丢弃1张「破坏剑」卡才能发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,78348935)
	e2:SetCost(c78348934.thcost)
	e2:SetTarget(c78348934.thtg)
	e2:SetOperation(c78348934.thop)
	c:RegisterEffect(e2)
end
-- 过滤对方墓地中可以作为效果对象且可以除外的怪兽
function c78348934.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
end
-- 检查卡片组中的怪兽是否为相同种族
function c78348934.fselect(g)
	-- 检查卡片组中的所有怪兽是否具有相同的种族
	return aux.SameValueCheck(g,Card.GetRace)
end
-- 过滤自己场上表侧表示的「破坏之剑士」怪兽或「破坏剑」怪兽
function c78348934.filter3(c)
	return c:IsFaceup() and c:IsSetCard(0xd6,0xd7)
end
-- ①号效果的发动准备与对象选择
function c78348934.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c78348934.filter1(chkc,e) end
	-- 检查对方墓地是否存在至少1只可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c78348934.filter1,tp,0,LOCATION_GRAVE,1,nil,e)
		-- 检查自己场上是否存在至少1只表侧表示的「破坏之剑士」或「破坏剑」怪兽
		and Duel.IsExistingMatchingCard(c78348934.filter3,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取对方墓地中所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(c78348934.filter1,tp,0,LOCATION_GRAVE,nil,e)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c78348934.fselect,false,1,3)
	-- 将选取的怪兽设为当前效果的对象
	Duel.SetTargetCard(sg)
	-- 设置连锁信息，表明此效果包含除外操作，并记录除外数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
-- ①号效果的实际处理函数
function c78348934.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象怪兽表侧表示除外，并记录实际除外的数量
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if ct==0 then return end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只表侧表示的「破坏之剑士」或「破坏剑」怪兽
	local sg=Duel.SelectMatchingCard(tp,c78348934.filter3,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=sg:GetFirst()
	if tc then
		-- 在场上显示选中该怪兽的动画效果
		Duel.HintSelection(sg)
		-- 直到回合结束时那个攻击力·守备力上升除外的怪兽数量×500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*500)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 过滤手卡中可以丢弃的「破坏剑」卡片
function c78348934.cfilter(c)
	return c:IsSetCard(0xd6) and c:IsDiscardable()
end
-- ②号效果的发动代价处理函数
function c78348934.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的「破坏剑」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c78348934.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择手卡中1张「破坏剑」卡片丢弃送去墓地
	Duel.DiscardHand(tp,c78348934.cfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- ②号效果的发动准备与效果对象确认
function c78348934.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁信息，表明此效果的操作为将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②号效果的实际处理函数
function c78348934.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将墓地的这张卡加入手卡
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
