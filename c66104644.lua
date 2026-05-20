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
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动等基本属性。
	aux.EnablePendulumAttribute(c)
	c:SetSPSummonOnce(66104644)
	-- ①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	-- 在连锁发生时，标记这张卡在场上存在。
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	-- ①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetOperation(c66104644.counterop)
	c:RegisterEffect(e2)
	-- ②：把这张卡3个魔力指示物取除才能发动。自己的额外卡组1只表侧表示的可以放置魔力指示物的怪兽和灵摆区域的这张卡特殊召唤，给那2只各放置1个魔力指示物。
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
	-- ②：对方回合1次，把自己场上3个魔力指示物取除才能发动。可以放置魔力指示物的1只怪兽从卡组特殊召唤。
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
	-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。那之后，这张卡放置过的数量的魔力指示物给这张卡放置。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_LEAVE_FIELD_P)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetOperation(c66104644.regop)
	e7:SetLabelObject(e6)
	c:RegisterEffect(e7)
end
-- 魔法卡发动连锁处理完毕时，给这张卡放置1个魔力指示物。
function c66104644.counterop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 灵摆效果②的COST：取除这张卡的3个魔力指示物。
function c66104644.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 过滤额外卡组中表侧表示、可以放置魔力指示物、且可以特殊召唤的怪兽。
function c66104644.spfilter(c,e,tp)
	-- 检查卡片是否表侧表示存在，且可以放置至少1个魔力指示物。
	return c:IsFaceup() and c:IsCanHaveCounter(0x1) and Duel.IsCanAddCounter(tp,0x1,1,c)
		-- 检查卡片是否可以特殊召唤，且额外怪兽区域或有连接端指向的怪兽区域有空位。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 灵摆效果②的靶向/发动条件检查：检查怪兽区空位、精灵龙限制，以及额外卡组是否存在可特召的合法怪兽。
function c66104644.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查己方主要怪兽区域是否有至少1个空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and Duel.GetUsableMZoneCount(tp)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自身（灵摆区域的此卡）是否可以特殊召唤，且可以放置至少1个魔力指示物。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsCanAddCounter(tp,0x1,1,c)
		-- 检查额外卡组是否存在至少1只满足条件的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c66104644.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，包含自身和额外卡组的怪兽共2张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_EXTRA)
end
-- 灵摆效果②的效果处理：将自身和额外卡组的1只怪兽特殊召唤，并给它们各放置1个魔力指示物。
function c66104644.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查己方主要怪兽区域是否已无空位，若无则无法处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.GetUsableMZoneCount(tp)<1 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的表侧表示怪兽。
	local g=Duel.SelectMatchingCard(tp,c66104644.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 准备将选择的额外卡组怪兽以表侧表示特殊召唤。
		Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
		-- 准备将自身（灵摆区域的此卡）以表侧表示特殊召唤。
		Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
		-- 完成上述两张怪兽的特殊召唤。
		Duel.SpecialSummonComplete()
		g:AddCard(c)
		-- 遍历特殊召唤成功的怪兽组（包含自身和额外卡组怪兽）。
		for tc in aux.Next(g) do
			tc:AddCounter(0x1,1)
		end
	end
end
-- 怪兽效果①的靶向/发动条件检查：检查自身是否能放置魔力指示物。
function c66104644.countertg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x1,1) end
	-- 设置放置指示物的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 怪兽效果①的效果处理：给这张卡放置1个魔力指示物。
function c66104644.counterop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1,1)
end
-- 怪兽效果②的发动条件：必须在对方回合。
function c66104644.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方。
	return Duel.GetTurnPlayer()==1-tp
end
-- 怪兽效果②的COST：取除自己场上的3个魔力指示物。
function c66104644.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否能取除3个魔力指示物。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,3,REASON_COST) end
	-- 取除己方场上的3个魔力指示物。
	Duel.RemoveCounter(tp,1,0,0x1,3,REASON_COST)
end
-- 过滤卡组中可以放置魔力指示物且可以特殊召唤的怪兽。
function c66104644.spfilter2(c,e,tp)
	return c:IsCanHaveCounter(0x1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果②的靶向/发动条件检查：检查怪兽区空位以及卡组中是否存在可特召的合法怪兽。
function c66104644.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c66104644.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，包含卡组中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果②的效果处理：从卡组特殊召唤1只可以放置魔力指示物的怪兽。
function c66104644.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽。
	local tc=Duel.SelectMatchingCard(tp,c66104644.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 怪兽效果③的发动条件：此卡在怪兽区域被破坏。
function c66104644.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果③的靶向/发动条件检查：检查己方灵摆区域是否有空位。
function c66104644.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方的左灵摆区或右灵摆区是否可用。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果③的效果处理：将此卡放置在自己的灵摆区域，并放置其被破坏前所持有的相同数量的魔力指示物。
function c66104644.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	-- 检查此卡是否与效果相关，并将其移动到己方的灵摆区域表侧表示放置。
	if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		and ct>0 then
		c:AddCounter(0x1,ct)
	end
end
-- 离场时预先记录此卡在场上时持有的魔力指示物数量。
function c66104644.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetHandler():GetCounter(0x1))
end
