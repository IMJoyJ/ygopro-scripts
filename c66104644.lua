--マギステル・オブ・エンディミオン
-- 效果：
-- ←8 【灵摆】 8→
-- ①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：把这张卡3个魔力指示物取除才能发动。自己的额外卡组1只表侧表示的可以放置魔力指示物的怪兽和灵摆区域的这张卡特殊召唤，给那2只各放置1个魔力指示物。
-- 【怪兽效果】
-- 自己对「恩底弥翁的统领」1回合只能有1次特殊召唤。
-- ①：这张卡的攻击宣言时才能发动。给这张卡放置1个魔力指示物。
-- ②：对方回合1次，把自己场上3个魔力指示物取除才能发动。可以放置魔力指示物的1只怪兽从卡组特殊召唤。
-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。那之后，这张卡放置过的数量的魔力指示物给这张卡放置。
function c66104644.initial_effect(c)
	c:EnableCounterPermit(0x1,LOCATION_PZONE+LOCATION_MZONE)
	-- 启用灵摆卡的基本属性与发动画框
	aux.EnablePendulumAttribute(c)
	c:SetSPSummonOnce(66104644)
	-- 注册连锁注册效果：追踪本连锁中魔法卡的发动记录
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	-- 设置连锁注册处理函数
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	-- ①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetOperation(c66104644.counterop)
	c:RegisterEffect(e2)
	-- ②：把这张卡3个魔力指示物去除才能发动。自己的额外卡组1只表侧表示的可以放置魔力指示物的怪兽和灵摆区域的这张卡特殊召唤，给那2只各放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(66104644,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCost(c66104644.spcost)
	e3:SetTarget(c66104644.sptg)
	e3:SetOperation(c66104644.spop)
	c:RegisterEffect(e3)
	-- ①：这张卡的攻击宣言时才能发动。给这张卡放置1个魔力指示物。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(66104644,1))  --"放置指示物"
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetTarget(c66104644.countertg2)
	e4:SetOperation(c66104644.counterop2)
	c:RegisterEffect(e4)
	-- ②：对方回合1次，把自己场上3个魔力指示物去除才能发动。可以放置魔力指示物的1只怪兽从卡组特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(66104644,2))  --"取除指示物从卡组特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetHintTiming(0,TIMING_END_PHASE)
	e5:SetCondition(c66104644.spcon2)
	e5:SetCost(c66104644.spcost2)
	e5:SetTarget(c66104644.sptg2)
	e5:SetOperation(c66104644.spop2)
	c:RegisterEffect(e5)
	-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。那之后，这张卡放置过的数量的魔力指示物给这张卡放置。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(66104644,1))  --"放置指示物"
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(c66104644.pencon)
	e6:SetTarget(c66104644.pentg)
	e6:SetOperation(c66104644.penop)
	c:RegisterEffect(e6)
	-- 注册离场前指示物数量记录效果：保存离场前此卡上的魔力指示物数量
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_LEAVE_FIELD_P)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetOperation(c66104644.regop)
	e7:SetLabelObject(e6)
	c:RegisterEffect(e7)
end
c66104644.mentioned_counter={
	[0x1]=true,
}
-- 放置指示物处理：若当前连锁成功发动了魔法卡，给此卡放置1个魔力指示物
function c66104644.counterop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 灵摆区特召效果Cost：去除此卡上的3个魔力指示物
function c66104644.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 额外卡组特召过滤条件：表侧表示、可放置魔力指示物且可特殊召唤的怪兽
function c66104644.spfilter(c,e,tp)
	-- 检查卡片是否表侧表示且允许放置1个魔力指示物
	return c:IsFaceup() and c:IsCanHaveCounter(0x1) and Duel.IsCanAddCounter(tp,0x1,1,c)
		-- 检查卡片是否可以特殊召唤且额外怪兽区域有空位
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 灵摆区特召效果准备：检查怪兽区域空位与可用目标，设置特殊召唤操作信息
function c66104644.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：主要怪兽区域是否有至少1个空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and Duel.GetUsableMZoneCount(tp)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自身是否可特殊召唤且可放置魔力指示物
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsCanAddCounter(tp,0x1,1,c)
		-- 检查额外卡组是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c66104644.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息：特殊召唤2只怪兽（自身与额外卡组怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_EXTRA)
end
-- 灵摆区特召效果处理：将额外卡组1只怪兽与灵摆区的自身特殊召唤，并给那2只各放置1个魔力指示物
function c66104644.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 怪兽区域无空位或受到青眼精灵龙限制时终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.GetUsableMZoneCount(tp)<1 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的表侧表示怪兽
	local g=Duel.SelectMatchingCard(tp,c66104644.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行步骤：表侧表示特殊召唤选中的额外卡组怪兽
		Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
		-- 执行步骤：表侧表示特殊召唤灵摆区域的自身
		Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
		g:AddCard(c)
		-- 遍历特殊召唤的2只怪兽并各自放置1个魔力指示物
		for tc in aux.Next(g) do
			tc:AddCounter(0x1,1)
		end
	end
end
-- 攻击宣言放置指示物准备：设置放置指示物操作信息
function c66104644.countertg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x1,1) end
	-- 设置连锁操作信息：放置1个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 攻击宣言放置指示物处理：给此卡放置1个魔力指示物
function c66104644.counterop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1,1)
end
-- 卡组特召效果条件检查：必须在对方回合
function c66104644.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 卡组特召效果Cost：去除自己场上的3个魔力指示物
function c66104644.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：自己场上是否有至少3个魔力指示物可去除
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,3,REASON_COST) end
	-- 去除自己场上的3个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,3,REASON_COST)
end
-- 卡组特召过滤条件：可以放置魔力指示物且可特殊召唤的怪兽
function c66104644.spfilter2(c,e,tp)
	return c:IsCanHaveCounter(0x1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 卡组特召效果准备：设置从卡组特殊召唤怪兽的操作信息
function c66104644.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c66104644.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 卡组特召效果处理：从卡组把1只可以放置魔力指示物的怪兽特殊召唤
function c66104644.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,c66104644.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 被破坏放置灵摆区条件检查：先前必须在怪兽区域表侧表示
function c66104644.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 被破坏放置灵摆区准备：检查灵摆区域是否有空位
function c66104644.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己的灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 被破坏放置灵摆区处理：将自身放置到灵摆区域，并放置此前记录数量的魔力指示物
function c66104644.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	-- 将自身移动并放置到灵摆区域
	if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		and ct>0 then
		c:AddCounter(0x1,ct)
	end
end
-- 记录此卡从场上离开前所拥有的魔力指示物数量
function c66104644.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetHandler():GetCounter(0x1))
end
