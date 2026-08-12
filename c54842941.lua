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
-- 初始化效果：赋予灵摆怪兽属性并允许在灵摆区域放置纠罪指示物，注册反转放置指示物的永续效果、战斗阶段结束时的破坏效果、手卡的特殊召唤效果、场上的效果无效化效果以及反转时的盖放效果，并设置特殊召唤操作计数器
function s.initial_effect(c)
	-- 赋予这张卡灵摆怪兽属性（可以进行灵摆卡的发动与灵摆召唤）
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
	-- 注册特殊召唤操作的自定义计数器：本回合若以里侧守备表示以外的方式特殊召唤过怪兽（由counterfilter过滤），则计数增加，用于cost的回合限制判定
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.mentioned_counter={
	[0x71]=true,
}
-- 计数器过滤函数：特殊召唤的卡为里侧表示时不计数（即里侧守备表示的特殊召唤不受回合限制约束）
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 效果处理：每次有怪兽反转时，给这张卡放置1个纠罪指示物（0x71）
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 过滤函数：判断卡是否属于「纠罪巧」字段（系列码0x1d4）
function s.cfilter(c)
	return c:IsSetCard(0x1d4)
end
-- 发动条件：另一边的自己的灵摆区域存在这张卡以外的「纠罪巧」卡
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否存在这张卡以外的「纠罪巧」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 对象过滤函数：表侧表示且攻击力比这张卡的攻击力低的怪兽
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 目标选择函数：取得这张卡的原本攻击力；连锁处理中若指定了候选卡，则检查其是否在对方怪兽区域且满足攻击力条件
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetBaseAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and s.desfilter(chkc,atk) end
	-- 发动可行性检查：对方场上是否存在能成为对象的、攻击力比这张卡低的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1只攻击力比这张卡低的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置操作信息：本连锁将破坏1张作为对象的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得对象卡，若其仍与当前连锁相关且为怪兽，则以效果破坏那只怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 以效果破坏那只对象怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- cost检查：手卡的这张卡未被公开（即还未给对方观看），且本回合没有以非里侧表示特殊召唤过怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 本回合自己没有进行过表侧表示的特殊召唤（用于「不用里侧守备表示不能把怪兽特殊召唤」的回合限制判定）
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 把特殊召唤表示形式限制的誓约效果注册给当前回合玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制过滤：以表侧表示特殊召唤的怪兽即为限制对象（即不能用表侧表示特殊召唤）
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 过滤函数：判断卡是否可以以里侧守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 目标函数：若玩家受神圣之光效果影响则无法发动；检查自己怪兽区域有空位且手卡存在可以里侧守备表示特殊召唤的怪兽，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若玩家受到神圣之光（不能里侧守备表示召唤/特殊召唤）的效果影响
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 自己的主要怪兽区域存在可用的空格
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 手卡存在至少1只可以以里侧守备表示特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：怪兽区域无空位则中断；选择手卡1只可以里侧守备表示特殊召唤的怪兽，洗切手卡后将其里侧守备表示特殊召唤，若该卡原本处于公开状态则给对方确认
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 自己的主要怪兽区域没有可用空格时中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只可以以里侧守备表示特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 洗切自己的手卡（隐藏被特殊召唤的卡的位置信息）
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 把选择的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 若特殊召唤的怪兽原本处于公开状态，则给对方确认该卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 过滤函数：位于场上且控制者为指定玩家的卡
function s.ccfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp)
end
-- 发动条件：这张卡未被战斗破坏，连锁的效果由对方在场上发动，且这张卡为里侧表示并处于自己的回合
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 取得连锁发动的卡的位置信息
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep~=tp and (LOCATION_ONFIELD)&loc~=0
		-- 这张卡为里侧表示，且当前是自己的回合
		and e:GetHandler():IsFacedown() and Duel.GetTurnPlayer()==tp
end
-- cost处理：把里侧表示的这张卡变成表侧守备表示
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把里侧表示的这张卡变成表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 目标函数：设置使那次发动无效的操作信息；若发动效果的卡可以被破坏且仍与效果相关，再设置破坏的操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使连锁的那次发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏发动效果的那张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使那次发动无效，若发动的卡仍与该连锁相关，则将其以效果破坏
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使那次发动无效成功，且发动效果的卡仍与当前连锁相关
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 以效果破坏发动那次效果的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤函数：表侧表示且可以变成里侧守备表示的怪兽
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 目标函数：检索对方场上全部可以变成里侧守备表示的表侧表示怪兽，并设置表示形式变更的操作信息
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检索对方场上全部表侧表示且可以变成里侧守备表示的怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：将这些怪兽的表示形式全部变更
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：把对方场上的表侧表示怪兽全部变成里侧守备表示，对被实际变成里侧表示的怪兽逐个注册不能把表示形式变更的效果
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索对方场上全部表侧表示且可以变成里侧守备表示的怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 存在可处理怪兽，并把这些怪兽全部变成里侧守备表示且实际变更数量不为0
	if g:GetCount()>0 and Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 then
		-- 取得刚才表示形式变更操作实际处理的怪兽组
		local og=Duel.GetOperatedGroup()
		-- 遍历每一个被实际变成里侧表示的怪兽
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
