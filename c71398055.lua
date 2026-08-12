--DDDD偉次元王アーク・クライシス
-- 效果：
-- ←13 【灵摆】 13→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以自己场上的「契约书」卡任意数量为对象才能发动。那些卡破坏。那之后，可以把最多有破坏数量的「死伟王」灵摆怪兽从卡组·额外卡组特殊召唤。
-- 【怪兽效果】
-- 恶魔族的融合·同调·超量·灵摆怪兽各1只合计4只
-- 「DDDD 伟次元王 弧线危机神」1回合1次用融合召唤以及以下方法才能特殊召唤。
-- ●把自己的场上·墓地的上记的卡除外的场合可以从额外卡组（里侧）特殊召唤。
-- ①：这张卡特殊召唤的场合才能发动。对方场上的全部表侧表示怪兽的效果无效化。
-- ②：这张卡可以向对方怪兽全部各作1次攻击。
-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤手续、接触融合手续、灵摆属性启用、特殊召唤限制、灵摆效果、怪兽效果（特殊召唤时无效对方怪兽、全体攻击、被破坏时置于灵摆区）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，需要恶魔族的融合、同调、超量、灵摆怪兽各1只作为素材，不能使用融合代替素材。
	aux.AddFusionProcMix(c,false,true,s.fusfilter1,s.fusfilter2,s.fusfilter3,s.fusfilter4)
	-- 添加接触融合特殊召唤规则，通过将自己场上·墓地的素材表侧表示除外来从额外卡组特殊召唤。
	aux.AddContactFusionProcedure(c,s.fsmfiler(c),LOCATION_MZONE+LOCATION_GRAVE,0,Duel.Remove,POS_FACEUP,REASON_SPSUMMON)
	-- 启用灵摆怪兽属性，但不注册默认的灵摆卡发动效果。
	aux.EnablePendulumAttribute(c,false)
	-- 「DDDD 伟次元王 弧线危机神」1回合1次用融合召唤以及以下方法才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- 「DDDD 伟次元王 弧线危机神」1回合1次用融合召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- ①：以自己场上的「契约书」卡任意数量为对象才能发动。那些卡破坏。那之后，可以把最多有破坏数量的「死伟王」灵摆怪兽从卡组·额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤的场合才能发动。对方场上的全部表侧表示怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- ②：这张卡可以向对方怪兽全部各作1次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"放置灵摆区域"
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(s.pencon)
	e5:SetTarget(s.pentg)
	e5:SetOperation(s.penop)
	c:RegisterEffect(e5)
end
s.material_type=TYPE_SYNCHRO
-- 接触融合素材的过滤条件函数，要求素材可以被除外，且本回合该玩家尚未特殊召唤过此卡。
function s.fsmfiler(ec)
	return	function(c)
				-- 过滤条件：卡片可以作为Cost除外，且当前玩家本回合未注册过该卡特殊召唤的Flag（即1回合只能特殊召唤1次）。
				return c:IsAbleToRemoveAsCost() and Duel.GetFlagEffect(ec:GetControler(),id)==0
			end
end
-- 融合素材1过滤：恶魔族的融合怪兽。
function s.fusfilter1(c)
	return c:IsRace(RACE_FIEND) and c:IsFusionType(TYPE_FUSION)
end
-- 融合素材2过滤：恶魔族的同调怪兽。
function s.fusfilter2(c)
	return c:IsRace(RACE_FIEND) and c:IsFusionType(TYPE_SYNCHRO)
end
-- 融合素材3过滤：恶魔族的超量怪兽。
function s.fusfilter3(c)
	return c:IsRace(RACE_FIEND) and c:IsFusionType(TYPE_XYZ)
end
-- 融合素材4过滤：恶魔族的灵摆怪兽。
function s.fusfilter4(c)
	return c:IsRace(RACE_FIEND) and c:IsFusionType(TYPE_PENDULUM)
end
-- 注册特殊召唤Flag的触发条件：此卡是通过融合召唤特殊召唤，或者是通过自身接触融合效果特殊召唤。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or re:GetHandler()==c
end
-- 注册特殊召唤Flag的执行操作：为玩家注册本回合已特殊召唤过此卡的Flag。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家注册一个持续到回合结束的Flag，用于限制同名卡一回合只能特殊召唤一次。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤限制条件函数：在额外卡组里侧表示时，必须是融合召唤（或满足接触融合手续），且本回合未特殊召唤过此卡。
function s.splimit(e,se,sp,st)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then
		-- 限制条件：必须是融合召唤（或接触融合），且本回合该玩家未特殊召唤过此卡。
		return st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
	end
	return false
end
-- 灵摆效果破坏目标的过滤条件：自己场上表侧表示的「契约书」卡。
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xae)
end
-- 灵摆效果的发动准备（Target）：检查并选择自己场上任意数量的「契约书」卡作为对象，设置破坏和特殊召唤的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查自己场上是否存在至少1张可以作为对象的表侧表示「契约书」卡。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1到99张（任意数量）满足条件的「契约书」卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,99,nil)
	-- 设置连锁信息：预计破坏选中的卡片组。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 特殊召唤怪兽的过滤条件：卡组·额外卡组的「死伟王」灵摆怪兽，且在对应区域有可用的怪兽区域。
function s.spfilter(c,e,tp)
	if not (c:IsSetCard(0x1d0) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 检查额外卡组的怪兽特殊召唤到场上时，是否有可用的额外怪兽区域或连接端。
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 检查主怪兽区域是否有空位。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end
-- 过滤额外卡组里侧表示的融合、同调、超量怪兽。
function s.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 过滤额外卡组的连接怪兽，或表侧表示的灵摆怪兽。
function s.exfilter3(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
-- 检查选择特殊召唤的怪兽组合是否符合各个区域（卡组、额外卡组里侧/表侧）的可用格子限制。
function s.gcheck(g,ft1,ft2,ft3,ect,ft)
	return #g<=ft
		and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=ft1
		and g:FilterCount(s.exfilter2,nil)<=ft2
		and g:FilterCount(s.exfilter3,nil)<=ft3
		and g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect
end
-- 灵摆效果的处理（Operation）：破坏作为对象的卡，若成功破坏，则根据破坏数量，从卡组·额外卡组选择最多该数量的「死伟王」灵摆怪兽特殊召唤。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果关联的对象卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToChain,nil)
	-- 破坏选中的卡片，若一张都没有破坏则结束效果处理。
	if Duel.Destroy(g,REASON_EFFECT)==0 then return end
	-- 获取实际被破坏的卡片组。
	local og=Duel.GetOperatedGroup()
	-- 检查玩家是否受到额外卡组特殊召唤限制效果的影响（如某些特定卡片限制）。
	local ect1=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	-- 检查玩家是否受到额外卡组特殊召唤次数限制效果的影响。
	local ect2=aux.ExtraDeckSummonCountLimit and Duel.IsPlayerAffectedByEffect(tp,92345028)
	-- 如果有卡片被成功破坏，且卡组·额外卡组存在可特殊召唤的「死伟王」灵摆怪兽。
	if og:GetCount()>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) then
		local ct=og:GetCount()
		-- 获取主怪兽区域的可用空格数。
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取额外卡组里侧怪兽特殊召唤所需的可用空格数。
		local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
		-- 获取额外卡组表侧怪兽特殊召唤所需的可用空格数。
		local ft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
		-- 获取玩家可用的怪兽区域总数。
		local ft=Duel.GetUsableMZoneCount(tp)
		if ect1 and ect1>ft2 then ft2=ect1 end
		if ect1 and ect1>ft3 then ft3=ect1 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then
			if ft1>0 then ft1=1 end
			if ft2>0 then ft2=1 end
			if ft3>0 then ft3=1 end
			ft=1
		end
		if ect2 and ect2<1 then
			if ft2>0 then ft2=0 end
			if ft3>0 then ft3=0 end
		end
		local loc=0
		if ft1>0 then loc=loc+LOCATION_DECK end
		if (not ect1 or ect1>0) and ft>0 and (ft2>0 or ft3>0) then loc=loc+LOCATION_EXTRA end
		if loc==0 then return end
		-- 获取卡组·额外卡组中所有满足特殊召唤条件的「死伟王」灵摆怪兽。
		local sg=Duel.GetMatchingGroup(s.spfilter,tp,loc,0,nil,e,tp)
		if not ect1 then ect1=ft end
		if sg:GetCount()==0 or not sg:CheckSubGroup(s.gcheck,1,ct,ft1,ft2,ft3,ect1,ft)
			-- 询问玩家是否进行特殊召唤，若玩家选择“否”则结束效果。
			or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end  --"是否特殊召唤？"
		-- 划分效果处理时点，使后续的特殊召唤处理与破坏处理不视为同时进行。
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local rg=sg:SelectSubGroup(tp,s.gcheck,false,1,ct,ft1,ft2,ft3,ect1,ft)
		-- 将选中的怪兽以表侧表示特殊召唤到场上。
		Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 怪兽效果①的发动准备（Target）：检查对方场上是否存在可无效的表侧表示怪兽，并设置无效的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示且未被无效的效果怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示且未被无效的效果怪兽。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁信息：预计无效这些怪兽的效果。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 怪兽效果①的效果处理（Operation）：将对方场上全部表侧表示怪兽的效果无效化。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取对方场上所有表侧表示且未被无效的效果怪兽。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	-- 遍历获取到的怪兽卡片组。
	for tc in aux.Next(g) do
		-- 无效与该怪兽相关的连锁效果。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- ①：这张卡特殊召唤的场合才能发动。对方场上的全部表侧表示怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- ①：这张卡特殊召唤的场合才能发动。对方场上的全部表侧表示怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 怪兽效果③的发动条件：此卡在怪兽区域被破坏，且被破坏时是表侧表示。
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果③的发动准备（Target）：检查自己的灵摆区域是否有空位，若此卡在墓地则设置离开墓地的操作信息。
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的左侧或右侧灵摆区域是否有空位。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) then
		-- 若此卡被破坏后送入墓地，设置连锁信息：此卡将离开墓地。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- 怪兽效果③的效果处理（Operation）：将这张卡在自己的灵摆区域放置。
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与连锁关联，且不受王家长眠之谷的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡移动到自己的灵摆区域表侧表示放置，并适用其灵摆效果。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
