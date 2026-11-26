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
-- 初始化「DDDD 伟次元王 弧线危机神」(71398055)：设置苏生限制、融合与接触融合手续、灵摆属性，并注册特殊召唤次数限制、灵摆炸契约书特召、特召无效对方怪兽、全体攻击与被破坏置P区效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：需以恶魔族的融合·同调·超量·灵摆怪兽各1只合计4只为素材（不可使用融合替代素材）
	aux.AddFusionProcMix(c,false,true,s.fusfilter1,s.fusfilter2,s.fusfilter3,s.fusfilter4)
	-- 设置接触融合特殊召唤手续：从自己场上·墓地把4种恶魔族素材除外，在满足条件时从额外卡组（里侧）特殊召唤
	aux.AddContactFusionProcedure(c,s.fsmfiler(c),LOCATION_MZONE+LOCATION_GRAVE,0,Duel.Remove,POS_FACEUP,REASON_SPSUMMON)
	-- 为这张卡添加灵摆怪兽属性（不注册灵摆卡的魔法发动效果，仅支持灵摆召唤及灵摆区机制）
	aux.EnablePendulumAttribute(c,false)
	-- 「DDDD 伟次元王 弧线危机神」1回合1次用融合召唤以及以下方法才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- ●把自己的场上·墓地的上记的卡除外的场合可以从额外卡组（里侧）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- ←13 【灵摆】 13→ 这个卡名的灵摆效果1回合只能使用1次。①：以自己场上的「契约书」卡任意数量为对象才能发动。那些卡破坏。那之后，可以把最多有破坏数量的「死伟王」灵摆怪兽从卡组·额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- 【怪兽效果】①：这张卡特殊召唤的场合才能发动。对方场上的全部表侧表示怪兽的效果无效化。
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
-- 接触融合素材过滤闭包生成器：返回检查卡片是否可作为代价除外且该卡控制者本回合尚未特殊召唤过同名卡的过滤函数
function s.fsmfiler(ec)
	return	function(c)
				-- 检查素材卡片是否可作为代价除外，且控制者本回合记录的特殊召唤次数标记为0
				return c:IsAbleToRemoveAsCost() and Duel.GetFlagEffect(ec:GetControler(),id)==0
			end
end
-- 融合素材过滤函数1：筛选恶魔族的融合怪兽
function s.fusfilter1(c)
	return c:IsRace(RACE_FIEND) and c:IsFusionType(TYPE_FUSION)
end
-- 融合素材过滤函数2：筛选恶魔族的同调怪兽
function s.fusfilter2(c)
	return c:IsRace(RACE_FIEND) and c:IsFusionType(TYPE_SYNCHRO)
end
-- 融合素材过滤函数3：筛选恶魔族的超量怪兽
function s.fusfilter3(c)
	return c:IsRace(RACE_FIEND) and c:IsFusionType(TYPE_XYZ)
end
-- 融合素材过滤函数4：筛选恶魔族的灵摆怪兽
function s.fusfilter4(c)
	return c:IsRace(RACE_FIEND) and c:IsFusionType(TYPE_PENDULUM)
end
-- 召唤次数标记Condition函数：检查这张卡是否通过融合召唤或自身接触融合程序特殊召唤成功
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or re:GetHandler()==c
end
-- 召唤次数标记Operation函数：为玩家注册持续至回合结束的标记id，限制本回合不能再次特殊召唤「DDDD 伟次元王 弧线危机神」
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为己方玩家注册持续到回合结束的全局标识效果id
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤条件函数：仅当这张卡处于里侧额外卡组时，允许以融合召唤方式（包含接触融合）且本回合标记为0的情况下特殊召唤，其余位置禁止特殊召唤
function s.splimit(e,se,sp,st)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then
		-- 检查召唤方式是否包含融合召唤(SUMMON_TYPE_FUSION)且召唤玩家本回合未触发过同名卡特召限制标记
		return st&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
	end
	return false
end
-- 过滤函数：筛选场上表侧表示的「契约书」(0xae)卡片
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xae)
end
-- 灵摆效果①的Target函数：取自己场上任意数量（1至99张）表侧「契约书」卡为对象，并设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动检测时确认己方场上存在至少1张可作为对象的表侧「契约书」卡
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向己方玩家发送选择要破坏的「契约书」卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从己方场上选择1至99张表侧表示的「契约书」卡作为破坏对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,99,nil)
	-- 设置将所选「契约书」对象卡破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 过滤函数：筛选卡组或额外卡组中可特殊召唤的「死伟王」(0x1d0)灵摆怪兽，并按所在位置检查对应可用怪兽区空位
function s.spfilter(c,e,tp)
	if not (c:IsSetCard(0x1d0) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 若「死伟王」灵摆怪兽位于额外卡组，检查己方能从额外卡组特召该卡的可用空位是否大于0
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 若「死伟王」灵摆怪兽位于卡组，检查己方主要怪兽区的可用空位是否大于0
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end
-- 辅助过滤函数：筛选位于里侧额外卡组的融合·同调·超量怪兽（用于区分占用额外怪兽格的类型）
function s.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 辅助过滤函数：筛选位于额外卡组的连接怪兽或表侧额外卡组的灵摆怪兽
function s.exfilter3(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
-- 子组选择校验函数：确保所选特召怪兽组总数不超过可用格子ft，且来自卡组、里侧额外、表侧额外/连接的数量均符合各自格子与召唤次数上限
function s.gcheck(g,ft1,ft2,ft3,ect,ft)
	return #g<=ft
		and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=ft1
		and g:FilterCount(s.exfilter2,nil)<=ft2
		and g:FilterCount(s.exfilter3,nil)<=ft3
		and g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect
end
-- 灵摆效果①的Operation函数：破坏对象「契约书」卡后，综合计算召唤之门、炽焰狂怒、青眼精灵龙等场地限制与格子空位，允许从卡组·额外卡组特召最多等量「死伟王」灵摆怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡片组并过滤出仍与本次连锁保持关联的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToChain,nil)
	-- 以效果破坏对象「契约书」卡，若实际破坏数为0则终止后续处理
	if Duel.Destroy(g,REASON_EFFECT)==0 then return end
	-- 获取刚刚实际被破坏的卡片组
	local og=Duel.GetOperatedGroup()
	-- 检查玩家是否受到「召唤之门」(29724053)从额外卡组特召次数上限的影响
	local ect1=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	-- 检查玩家是否受到「炽焰狂怒」(92345028)本回合只能从额外卡组特召1次的影响
	local ect2=aux.ExtraDeckSummonCountLimit and Duel.IsPlayerAffectedByEffect(tp,92345028)
	-- 确认实际破坏了至少1张卡且卡组·额外卡组存在可特殊召唤的「死伟王」灵摆怪兽
	if og:GetCount()>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) then
		local ct=og:GetCount()
		-- 获取己方主要怪兽区可用空位数ft1（供从卡组特殊召唤使用）
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取己方从额外卡组特召里侧额外怪兽（融合·同调·超量）时的可用格子数ft2
		local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
		-- 获取己方从额外卡组特召表侧灵摆/连接怪兽时的可用格子数ft3
		local ft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
		-- 获取己方场上总可用怪兽区空位数ft
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
		-- 从可用的卡组/额外卡组范围loc中收集所有符合条件的「死伟王」灵摆怪兽
		local sg=Duel.GetMatchingGroup(s.spfilter,tp,loc,0,nil,e,tp)
		if not ect1 then ect1=ft end
		if sg:GetCount()==0 or not sg:CheckSubGroup(s.gcheck,1,ct,ft1,ft2,ft3,ect1,ft)
			-- 校验候选子组是否合法并询问己方玩家是否要特殊召唤，若不满足或玩家拒绝则直接返回
			or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end  --"是否特殊召唤？"
		-- 中断当前处理步骤，使后续「死伟王」灵摆怪兽的特殊召唤与前面的破坏处理视为不同时处理（“那之后”）
		Duel.BreakEffect()
		-- 向己方玩家发送选择要特殊召唤的「死伟王」灵摆怪兽提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local rg=sg:SelectSubGroup(tp,s.gcheck,false,1,ct,ft1,ft2,ft3,ect1,ft)
		-- 将选中的「死伟王」灵摆怪兽组以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 怪兽效果①的Target函数：检测对方怪兽区是否存在可被无效的表侧效果怪兽，并设置使其效果无效的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认对方怪兽区存在至少1只可被无效的表侧表示效果怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方怪兽区中所有可被无效的表侧表示效果怪兽
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	-- 设置使对方场上全部表侧效果怪兽效果无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 怪兽效果①的Operation函数：遍历对方怪兽区全部表侧效果怪兽，对其相关连锁及自身效果进行永久无效化处理
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方怪兽区中所有可被无效的表侧表示效果怪兽
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	-- 遍历对方场上需要无效化的每一只表侧效果怪兽
	for tc in aux.Next(g) do
		-- 使与当前遍历怪兽相关的正在处理中的连锁效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果无效化（针对怪兽本身的效果无效，且不会被无效）
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效化（针对怪兽发动及适用中的效果无效，且不会被无效）
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 怪兽效果③的Condition函数：检查被破坏的这张卡破坏前是否在怪兽区域且为表侧表示
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果③的Target函数：检测己方灵摆区至少有1个空位，若这张卡在墓地则设置离开墓地的操作信息
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方左侧或右侧灵摆区域存在至少1个可用空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) then
		-- 当这张卡位于墓地时，设置将这张卡离开墓地的操作信息
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- 怪兽效果③的Operation函数：确认这张卡仍与当前连锁关联且不受「王家长眠之谷」干扰后，将其表侧放置在己方灵摆区域
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与当前连锁关联且未受到「王家长眠之谷」效果的无效化干扰
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧表示移动到己方灵摆区域并启用其灵摆效果
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
