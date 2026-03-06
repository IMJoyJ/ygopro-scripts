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
-- 初始化卡片效果，启用灵摆属性并允许在灵摆区域放置指示物
function s.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x71,LOCATION_PZONE)
	-- 创建一个在灵摆区域触发的持续效果，用于在每次怪兽反转时放置1个纠罪指示物
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_FLIP)
	e0:SetRange(LOCATION_PZONE)
	e0:SetOperation(s.ctop)
	c:RegisterEffect(e0)
	-- 创建一个在战斗阶段结束时触发的效果，当对方灵摆区域有「纠罪巧」卡存在时，可以破坏对方场上攻击力低于自身攻击力的怪兽
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
	-- 创建一个可以在手卡发动的效果，将手卡的这张卡给对方观看后，可以特殊召唤1只怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 创建一个可以在怪兽区域发动的效果，当对方发动以自己场上的卡为对象的效果时，可以无效该效果并除外对方手卡1张卡
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
	-- 创建一个在反转时触发的效果，用于记录该卡已反转过
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_FLIP)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.flipop)
	c:RegisterEffect(e4)
	-- 创建一个当该卡反转后生效的效果，使对方不能把场上或墓地的卡作为效果的对象
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_IMMEDIATELY_APPLY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE)
	e5:SetCondition(s.effcon)
	-- 设置效果值为辅助函数aux.tgoval，用于判断是否能成为对方效果的对象
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
	-- 添加一个自定义活动计数器，用于限制特殊召唤次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，只对里侧表示的卡进行计数
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 反转指示物放置函数，每次怪兽反转时给该卡放置1个纠罪指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 过滤函数，用于判断是否为「纠罪巧」卡
function s.cfilter(c)
	return c:IsSetCard(0x1d4)
end
-- 破坏效果的发动条件，检查自己灵摆区域是否存在「纠罪巧」卡
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己灵摆区域是否存在「纠罪巧」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 破坏目标过滤函数，用于判断目标怪兽是否满足攻击力条件
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 设置破坏效果的目标选择函数，用于选择攻击力低于自身攻击力的对方怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetBaseAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and s.desfilter(chkc,atk) end
	-- 判断是否满足破坏效果的发动条件，检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择符合条件的对方怪兽作为破坏目标
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理函数，对目标怪兽进行破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 对目标怪兽进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 特殊召唤效果的费用函数，检查是否已公开且未发动过特殊召唤
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查是否未发动过特殊召唤
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建一个限制特殊召唤位置的效果，只能表侧表示召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 将限制特殊召唤位置的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤位置的过滤函数，只允许表侧表示召唤
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 特殊召唤目标过滤函数，用于判断是否可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 特殊召唤效果的目标选择函数，检查是否有满足条件的怪兽可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否受到「神圣之光」效果影响
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查玩家场上是否有足够的召唤位置
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的处理函数，从手卡特殊召唤1只怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将玩家手卡洗牌
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 向对方确认特殊召唤的怪兽
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 过滤函数，用于判断是否为己方场上的卡
function s.ccfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp)
end
-- 无效效果的发动条件，检查是否满足无效效果的条件
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的目标卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断是否满足无效效果的条件
	return Duel.IsChainDisablable(ev) and tg and tg:IsExists(s.ccfilter,1,nil,tp) and ep~=tp and e:GetHandler():IsFacedown()
end
-- 无效效果的费用函数，将该卡变为表侧守备表示
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将该卡变为表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 无效效果的目标选择函数，设置无效效果的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 无效效果的处理函数，无效对方效果并可能除外对方手卡
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效对方效果
	if Duel.NegateEffect(ev)
		-- 检查对方手卡是否存在可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,POS_FACEDOWN)
		-- 询问玩家是否除外对方手卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否除外？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 获取对方手卡中可除外的卡组
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil,POS_FACEDOWN)
		if g:GetCount()>0 then
			local sg=g:RandomSelect(tp,1)
			-- 将选择的卡除外
			Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
-- 反转效果的处理函数，记录该卡已反转过
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))  --"已反转过"
end
-- 判断该卡是否已反转过
function s.effcon(e)
	local c=e:GetHandler()
	return c:GetFlagEffect(id)>0
end
