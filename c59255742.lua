--ゴヨウ・エンペラー
-- 效果：
-- 战士族·地属性的同调怪兽×2
-- ①：这张卡或者原本持有者是对方的自己怪兽战斗破坏对方怪兽送去墓地时才能发动。破坏的那只怪兽在自己场上特殊召唤。
-- ②：对方把怪兽特殊召唤时，把自己场上1只战士族·地属性的同调怪兽解放才能发动。得到那些怪兽的控制权。
-- ③：表侧表示的这张卡从场上离开的场合发动。自己场上的全部怪兽的控制权回归原本持有者。
function c59255742.initial_effect(c)
	-- 开启全局洗脑解除标记检测（用于处理控制权回归原本持有者的效果）。
	Duel.EnableGlobalFlag(GLOBALFLAG_BRAINWASHING_CHECK)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，需要2个满足过滤条件ffilter的怪兽作为素材。
	aux.AddFusionProcFunRep(c,c59255742.ffilter,2,true)
	-- ①：这张卡或者原本持有者是对方的自己怪兽战斗破坏对方怪兽送去墓地时才能发动。破坏的那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCondition(c59255742.spcon)
	e1:SetTarget(c59255742.sptg)
	e1:SetOperation(c59255742.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡或者原本持有者是对方的自己怪兽战斗破坏对方怪兽送去墓地时才能发动。破坏的那只怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c59255742.spcon2)
	e2:SetTarget(c59255742.sptg2)
	e2:SetOperation(c59255742.spop)
	c:RegisterEffect(e2)
	-- ②：对方把怪兽特殊召唤时，把自己场上1只战士族·地属性的同调怪兽解放才能发动。得到那些怪兽的控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c59255742.cost)
	e3:SetTarget(c59255742.target)
	e3:SetOperation(c59255742.operation)
	c:RegisterEffect(e3)
	-- ③：表侧表示的这张卡从场上离开的场合发动。自己场上的全部怪兽的控制权回归原本持有者。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c59255742.ctcon)
	e4:SetTarget(c59255742.cttg)
	e4:SetOperation(c59255742.ctop)
	c:RegisterEffect(e4)
end
c59255742.material_type=TYPE_SYNCHRO
-- 融合素材过滤条件：地属性、战士族且是同调怪兽。
function c59255742.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsFusionType(TYPE_SYNCHRO)
end
-- 效果①（自身战破）的发动条件：自身在战斗中，且被破坏的对方怪兽被送去墓地。
function c59255742.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	return bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 效果①（原本持有者是对方的自己怪兽战破）的发动条件：战斗破坏对方怪兽的怪兽由自己控制但原本持有者是对方，且被破坏的怪兽送去墓地。
function c59255742.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local rc=tc:GetReasonCard()
	return eg:GetCount()==1 and rc:IsControler(tp) and rc:GetOwner()~=tp
		and tc:IsType(TYPE_MONSTER) and tc:IsReason(REASON_BATTLE) and tc:IsLocation(LOCATION_GRAVE)
end
-- 效果①（自身战破）的靶向/发动检查：检查自己场上是否有空怪兽位，且被破坏的怪兽是否可以特殊召唤。
function c59255742.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将战斗破坏的怪兽设为效果处理的对象。
	Duel.SetTargetCard(bc)
	-- 设置特殊召唤的操作信息，包含对象怪兽和数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 效果①（原本持有者是对方的自己怪兽战破）的靶向/发动检查：检查自己场上是否有空怪兽位，且被破坏的怪兽是否可以特殊召唤。
function c59255742.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	local rc=tc:GetReasonCard()
	local bc=rc:GetBattleTarget()
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将战斗破坏的怪兽设为效果处理的对象。
	Duel.SetTargetCard(bc)
	-- 设置特殊召唤的操作信息，包含对象怪兽 and 数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 效果①的特殊召唤效果处理。
function c59255742.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果处理的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的解放Cost过滤条件：自己场上的地属性·战士族同调怪兽，且解放后仍有足够的怪兽区域容纳夺取控制权的怪兽。
function c59255742.costfilter(c,tp,g)
	-- 检查怪兽是否为地属性战士族同调怪兽，且解放该怪兽后自己场上有足够的格子容纳夺取控制权的怪兽（排除自身）。
	return c59255742.ffilter(c) and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0 and g:IsExists(aux.TRUE,1,c)
end
-- 效果②的发动Cost处理：解放自己场上1只战士族·地属性的同调怪兽。
function c59255742.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(c59255742.filter,nil,tp)
	-- 检查自己场上是否存在至少1只满足解放条件的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c59255742.costfilter,1,nil,tp,g) end
	-- 选出1只满足条件的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c59255742.costfilter,1,1,nil,tp,g)
	-- 将选中的怪兽作为Cost解放。
	Duel.Release(g,REASON_COST)
end
-- 效果②的控制权夺取对象过滤条件：对方特殊召唤的且可以改变控制权的怪兽。
function c59255742.filter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsControlerCanBeChanged(true)
end
-- 效果②的靶向/发动检查：检查是否有对方特殊召唤的怪兽，且自己场上有足够的格子容纳它们。
function c59255742.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(c59255742.filter,nil,tp)
	-- 检查是否有对方特殊召唤的怪兽，且自己场上的空位是否足够（因为Cost会解放1只，所以格子数需要大于等于召唤数量减1）。
	if chk==0 then return g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=g:GetCount()-1 end
	-- 将这些特殊召唤的怪兽设为效果处理的对象。
	Duel.SetTargetCard(g)
	-- 设置控制权转移的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果②的控制权夺取效果处理。
function c59255742.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 如果自己场上的空位不足以容纳这些怪兽，则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() then return end
	-- 夺取这些怪兽的控制权。
	Duel.GetControl(g,tp)
end
-- 效果③的发动条件：表侧表示的这张卡从场上离开。
function c59255742.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- 效果③的控制权回归对象过滤条件：当前控制者不等于原本持有者的怪兽。
function c59255742.ctfilter(c)
	return c:GetControler()~=c:GetOwner()
end
-- 效果③的靶向/发动检查：检查自己场上是否存在控制权被改变的怪兽。
function c59255742.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只控制权被改变的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c59255742.ctfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果③的控制权回归效果处理（通过注册洗脑解除效果实现）。
function c59255742.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的所有怪兽。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local tc=g:GetFirst()
	local tg=Group.CreateGroup()
	local tc=g:GetFirst()
	while tc do
		if not tc:IsImmuneToEffect(e) and tc:GetFlagEffect(59255742)==0 then
			tc:RegisterFlagEffect(59255742,RESET_EVENT+RESETS_STANDARD,0,1)
			tg:AddCard(tc)
		end
		tc=g:GetNext()
	end
	tg:KeepAlive()
	-- ③：表侧表示的这张卡从场上离开的场合发动。自己场上的全部怪兽的控制权回归原本持有者。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REMOVE_BRAINWASHING)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置洗脑解除效果的影响对象为带有特定Flag标记的怪兽。
	e1:SetTarget(aux.TargetEqualFunction(Card.GetFlagEffect,1,59255742))
	e1:SetLabelObject(tg)
	-- 在全局注册该洗脑解除效果。
	Duel.RegisterEffect(e1,tp)
	-- ③：表侧表示的这张卡从场上离开的场合发动.自己场上的全部怪兽的控制权回归原本持有者。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetLabelObject(e1)
	-- 在全局注册该连锁解决后的清理效果。
	Duel.RegisterEffect(e2,tp)
	-- ③：表侧表示的这张卡从场上离开的场合发动。自己场上的全部怪兽的控制权回归原本持有者。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetLabelObject(e2)
	-- 将当前连锁的ID保存到效果e3的Label中，以便在重置时进行匹配。
	e3:SetLabel(Duel.GetChainInfo(0,CHAININFO_CHAIN_ID))
	e3:SetOperation(c59255742.reset)
	-- 在全局注册用于重置Flag和临时效果的监听效果。
	Duel.RegisterEffect(e3,tp)
end
-- 重置函数：在当前连锁处理完毕后，清除所有临时注册的效果和怪兽身上的Flag标记。
function c59255742.reset(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前解决的连锁ID是否与保存的连锁ID一致。
	if Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)==e:GetLabel() then
		local e2=e:GetLabelObject()
		local e1=e2:GetLabelObject()
		local tg=e1:GetLabelObject()
		-- 遍历所有被施加了临时Flag标记的怪兽。
		for tc in aux.Next(tg) do
			tc:ResetFlagEffect(59255742)
		end
		tg:DeleteGroup()
		e1:Reset()
		e2:Reset()
		e:Reset()
	end
end
