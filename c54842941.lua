--糾罪巧－Atoriϝ.MAR
-- 效果：
-- ←0 【灵摆】 0→
-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
-- ②：自己·对方的战斗阶段结束时，另一边的自己的灵摆区域有「纠罪巧」卡存在的场合，以比这张卡攻击力低的对方场上1只怪兽为对象才能发动。那只怪兽破坏。
-- 【怪兽效果】
-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
-- ②：自己回合对方在场上把卡的效果发动时，把里侧表示的这张卡变成表侧守备表示才能发动。那个发动无效并破坏。
-- ③：这张卡反转的场合发动。对方场上的怪兽全部变成里侧守备表示。这个效果变成里侧守备表示的怪兽不能把表示形式变更。
local s,id,o=GetID()
-- 初始化函数：注册灵摆怪兽属性、指示物放置效果、灵摆效果、手卡特召效果、场上无效效果、反转效果，并添加特殊召唤限制计数器
function s.initial_effect(c)
	-- 启用怪兽的灵摆属性，使其可以作为灵摆卡发动和进行灵摆召唤
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
	-- ②：自己回合对方在场上把卡的效果发动时，把里侧表示的这张卡变成表侧守备表示才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"无效"
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	-- ③：这张卡反转的场合发动。对方场上的怪兽全部变成里侧守备表示。这个效果变成里侧守备表示的怪兽不能把表示形式变更。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"盖放"
	e4:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e4:SetTarget(s.postg)
	e4:SetOperation(s.posop)
	c:RegisterEffect(e4)
	-- 添加自定义活动计数器，用于检测本回合玩家是否特殊召唤过非里侧表示的怪兽
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数：判定特殊召唤的怪兽是否为里侧表示
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 放置纠罪指示物效果的操作空间：给自身放置1个纠罪指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 过滤函数：筛选属于「纠罪巧」系列的卡片
function s.cfilter(c)
	return c:IsSetCard(0x1d4)
end
-- 破坏效果的发动条件：检查另一边的灵摆区域是否存在「纠罪巧」卡片
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否存在除自身以外的「纠罪巧」卡片
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤函数：筛选对方场上表侧表示且攻击力比本卡原始攻击力低的怪兽
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 破坏效果的靶向/目标选择函数：处理效果发动时的对象选择和合法性检测
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetBaseAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and s.desfilter(chkc,atk) end
	-- 效果发动时的合法性检测：检查对方场上是否存在可作为对象的、攻击力低于本卡原始攻击力的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 在客户端向发动效果的玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置连锁操作信息：表明该效果的处理包含破坏选定卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行函数：将选中的对象怪兽破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 因效果将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 特殊召唤效果的消耗/发动代价函数：检查手卡的这张卡是否未公开，且本回合是否未进行过非里侧表示的特殊召唤
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查本回合玩家是否未进行过非里侧表示的特殊召唤
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤。从手卡把1只怪兽里侧守备表示特殊召唤。自己回合对方在场上把卡的效果发动时，把里侧表示的这张卡变成表侧守备表示才能发动。那个发动无效并破坏。这张卡反转的场合发动。对方场上的怪兽全部变成里侧守备表示。这个效果变成里侧守备表示的怪兽不能把表示形式变更。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册特殊召唤限制的全局效果，限制玩家本回合只能以里侧守备表示特殊召唤怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤表示形式的过滤函数：禁止以表侧表示进行特殊召唤
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 过滤函数：筛选手卡中可以里侧守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 特殊召唤效果的靶向/目标选择函数：检查特殊召唤的合法性并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否受到「神圣之光」等不能以里侧守备表示特殊召唤的效果影响
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查自己场上是否有可用的怪兽区域空格
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在可以里侧守备表示特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：表明该效果的处理包含从手卡特殊召唤1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的执行函数：将手卡1只怪兽里侧守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的怪兽区域空格，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 在客户端向发动效果的玩家提示“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择手卡中1只可以里侧守备表示特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗切玩家的手卡
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 将选中的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 如果被特殊召唤的怪兽原本是公开状态，则让对方玩家确认该卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 过滤函数：筛选场上属于指定玩家控制的卡片
function s.ccfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp)
end
-- 无效效果的发动条件：检查是否在自己回合、对方在场上发动卡的效果，且本卡处于里侧表示
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 获取当前触发连锁的效果的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep~=tp and (LOCATION_ONFIELD)&loc~=0
		-- 检查本卡是否处于里侧表示，且当前回合玩家为自己
		and e:GetHandler():IsFacedown() and Duel.GetTurnPlayer()==tp
end
-- 无效效果的消耗/发动代价函数：将里侧表示的本卡变成表侧守备表示
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本卡改变为表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 无效效果的靶向/目标选择函数：设置无效与破坏的操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：表明该效果的处理包含使发动无效的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁操作信息：表明该效果的处理包含破坏该发动卡片的操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效效果的执行函数：使对方的效果发动无效并破坏该卡
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使该效果的发动无效，并检查该卡是否仍与该连锁关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 因效果将发动无效的卡片破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤函数：筛选对方场上表侧表示且可以变成里侧表示的怪兽
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 反转效果的靶向/目标选择函数：获取对方场上所有表侧表示怪兽并设置改变表示形式的操作信息
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有符合条件的表侧表示怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：表明该效果的处理包含改变这些怪兽表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 反转效果的执行函数：将对方场上的怪兽全部变成里侧守备表示，并施加不能变更表示形式的限制
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次获取对方场上所有符合条件的表侧表示怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 若存在符合条件的怪兽，则将它们全部改变为里侧守备表示
	if g:GetCount()>0 and Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 then
		-- 获取实际成功改变表示形式的怪兽卡片组
		local og=Duel.GetOperatedGroup()
		-- 遍历所有成功变成里侧守备表示的怪兽
		for tc in aux.Next(og) do
			-- 这个效果变成里侧守备表示的怪兽不能把表示形式变更。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
