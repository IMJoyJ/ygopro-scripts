--糾罪巧－Astaγ.PIXIEA
-- 效果：
-- ←0 【灵摆】 0→
-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
-- ②：自己·对方的战斗阶段结束时，另一边的自己的灵摆区域有「纠罪巧」卡存在的场合，以比这张卡攻击力低的对方场上1只怪兽为对象才能发动。那只怪兽破坏。
-- 【怪兽效果】
-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
-- ②：自己场上的卡为对象的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。那个效果无效。那之后，可以把对方手卡随机1张里侧除外。
-- ③：只要反转过的这张卡在怪兽区域存在，对方不能把场上·墓地的卡作为效果的对象。
local s,id,o=GetID()
-- 初始化效果：注册灵摆效果、怪兽效果及特殊的活动计数器
function s.initial_effect(c)
	-- 为这张卡添加灵摆怪兽的属性与规则效果（灵摆召唤与灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x71,LOCATION_PZONE)
	-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_FLIP)
	e0:SetRange(LOCATION_PZONE)
	e0:SetOperation(s.ctop)
	c:RegisterEffect(e0)
	-- ②：自己·对方的战斗阶段结束时，另一边的自己的灵摆区域有「纠罪巧」卡存在的场合，以比这张卡攻击力低的对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：自己场上的卡为对象的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。那个效果无效。那之后，可以把对方手卡随机1张里侧除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"除外"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- ③：只要反转过的这张卡在怪兽区域存在，对方不能把场上·墓地的卡作为效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_FLIP)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.flipop)
	c:RegisterEffect(e4)
	-- ③：只要反转过的这张卡在怪兽区域存在，对方不能把场上·墓地的卡作为效果的对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IMMEDIATELY_APPLY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE)
	e5:SetCondition(s.effcon)
	-- 设定不受对方卡片效果作为对象的影响
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
	-- 添加自定义活动计数器，用于检测本回合内是否进行过里侧表示以外的特殊召唤
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤条件：只允许里侧表示特殊召唤的怪兽
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 放置纠罪指示物的具体操作（每次怪兽反转时放置1个）
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 过滤条件：是否属于「纠罪巧」卡片
function s.cfilter(c)
	return c:IsSetCard(0x1d4)
end
-- 灵摆区破坏效果的发动条件：另一边的自己的灵摆区域有「纠罪巧」卡存在
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查另一边的自己的灵摆区域是否存在「纠罪巧」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤条件：对方场上表侧表示且攻击力低于本卡攻击力的怪兽
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 灵摆区破坏效果的靶向/发动检查与目标选择
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetBaseAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and s.desfilter(chkc,atk) end
	-- 检查对方场上是否存在符合破坏条件的对象
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只符合条件的攻击力较低的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置操作信息：将选中的对象怪兽破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆区破坏效果的处理
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁被选为对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 以效果原因为由破坏该目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 手牌特殊召唤效果的Cost处理与自誓限制（展示手牌本卡，且本回合没有以里侧以外特殊召唤过）
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查本回合是否进行过里侧表示以外的特殊召唤
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 【怪兽效果】①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。②：自己场上的卡为对象的效果由对方发动时，把里侧表示的这张卡变成表侧守备表示才能发动。那个效果无效。那之后，可以把对方手卡随机1张里侧除外。③：只要反转过的这张卡在怪兽区域存在，对方不能把场上·墓地的卡作为效果的对象。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册全局玩家效果：限制特殊召唤的形式
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：限制特殊召唤的表示形式不能是表侧表示
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 过滤条件：可以里侧守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 手牌特殊召唤效果的靶向/发动检查与目标选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否受到「神圣之光」效果影响而无法进行里侧表示特殊召唤
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查自己场上是否有可用的怪兽格
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌是否存在可以里侧守备表示特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 手牌特殊召唤效果的实际处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前已无可用的怪兽格，则效果处理终止
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手牌中1只符合条件的怪兽以里侧守备表示特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将手牌洗牌
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 将选中的手牌怪兽以里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 向对方玩家确认刚刚在展示状态下特殊召唤的那张怪兽
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 过滤条件：位于自己场上的卡
function s.ccfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp)
end
-- 无效效果的发动条件判定（自己场上的卡为对象的效果由对方发动，且此卡为里侧表示）
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取该连锁中被选为对象的所有卡片
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断该连锁是否能被无效、是否以自己场上的卡为对象、发动玩家是否为对方，且本卡为里侧表示
	return Duel.IsChainDisablable(ev) and tg and tg:IsExists(s.ccfilter,1,nil,tp) and ep~=tp and e:GetHandler():IsFacedown()
end
-- 无效效果的Cost处理：里侧表示的这张卡变成表侧守备表示
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将里侧表示的这张卡变为表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 无效效果的靶向/发动检查与操作信息设置
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将该连锁的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 无效效果处理以及后续的除外处理
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功将该对方连锁效果无效
	if Duel.NegateEffect(ev)
		-- 检查对方手牌是否有卡可以里侧除外
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,POS_FACEDOWN)
		-- 询问自己玩家是否选择把对方手牌除外
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否除外？"
		-- 中断前后的效果处理，使后续的除外不与无效同时处理
		Duel.BreakEffect()
		-- 获取对方手牌中所有可以被里侧除外的卡片
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil,POS_FACEDOWN)
		if g:GetCount()>0 then
			local sg=g:RandomSelect(tp,1)
			-- 将随机选中的对方手牌里侧除外
			Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
-- 反转时放置标记：记录该卡已在怪兽区域反转过
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))  --"已反转过"
end
-- 判断该卡是否在怪兽区域反转过，作为效果启用的条件
function s.effcon(e)
	local c=e:GetHandler()
	return c:GetFlagEffect(id)>0
end
