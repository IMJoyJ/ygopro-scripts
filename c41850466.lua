--ヌメロン・カオス・リチューアル
-- 效果：
-- ①：自己场上的表侧表示的「混沌No.1 混沌源数门-空」被怪兽的效果破坏的回合，从自己墓地的卡以及除外的自己的卡之中以1张「源数网络」和4只「No.」超量怪兽为对象才能发动。从额外卡组把1只「混沌No.1000 梦幻虚神 原数天灵」变成攻击力10000/守备力1000特殊召唤，把作为对象的5张卡作为那超量素材。这个效果的发动后，直到回合结束时自己只能有1次把怪兽召唤·特殊召唤。
function c41850466.initial_effect(c)
	-- 将本卡记载的相关卡名（混沌No.1 混沌源数门-空、源数网络、混沌No.1000 梦幻虚神 原数天灵）登记到本卡的代码列表，用于判定效果关联。
	aux.AddCodeList(c,79747096,41418852,89477759)
	-- ①：自己场上的表侧表示的「混沌No.1 混沌源数门-空」被怪兽的效果破坏的回合，从自己墓地的卡以及除外的自己的卡之中以1张「源数网络」和4只「No.」超量怪兽为对象才能发动。从额外卡组把1只「混沌No.1000 梦幻虚神 原数天灵」变成攻击力10000/守备力1000特殊召唤，把作为对象的5张卡作为那超量素材。这个效果的发动后，直到回合结束时自己只能有1次把怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c41850466.xyzcon)
	e1:SetTarget(c41850466.xyztg)
	e1:SetOperation(c41850466.xyzop)
	c:RegisterEffect(e1)
	if not c41850466.global_check then
		c41850466.global_check=true
		-- 自己场上的表侧表示的「混沌No.1 混沌源数门-空」被怪兽的效果破坏的回合，从自己墓地的卡以及除外的自己的卡之中以1张「源数网络」和4只「No.」超量怪兽为对象才能发动。从额外卡组把1只「混沌No.1000 梦幻虚神 原数天灵」变成攻击力10000/守备力1000特殊召唤，把作为对象的5张卡作为那超量素材。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(c41850466.checkop)
		-- 将全局事件监听效果注册到场上，持续检测怪兽被破坏的事件，用于记录满足条件的破坏。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤条件：被破坏的卡此前在场上表侧表示，且卡名为「混沌No.1 混沌源数门-空」（79747096），破坏原因是效果且该效果来自怪兽效果。
function c41850466.cfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==79747096
		and c:IsReason(REASON_EFFECT) and c:GetReasonEffect():IsActiveType(TYPE_MONSTER)
end
-- 从被破坏的怪兽中筛选出符合条件的卡，为这些卡的原控制者注册本回合的发动标记。
function c41850466.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c41850466.cfilter,nil)
	-- 遍历筛选出的所有符合条件的卡片。
	for tc in aux.Next(g) do
		-- 为该怪兽的原控制者注册标记41850466，持续到结束阶段，作为本卡发动条件的判定依据。
		Duel.RegisterFlagEffect(tc:GetPreviousControler(),41850466,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 本卡发动条件判定：当前玩家必须拥有标记41850466，即本回合发生过「混沌No.1 混沌源数门-空」被怪兽效果破坏。
function c41850466.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家身上是否存在标记41850466，存在则发动条件成立。
	return Duel.GetFlagEffect(tp,41850466)>0
end
-- 对象过滤：卡是「No.」超量怪兽，可以作为超量素材，且位于墓地或表侧表示（除外区表侧可选的卡）。
function c41850466.xyzfilter1(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x48) and c:IsCanOverlay() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 对象过滤：卡是「源数网络」（41418852），可以作为超量素材，且位于墓地或表侧表示（除外区表侧可选的卡）。
function c41850466.xyzfilter2(c)
	return c:IsCode(41418852) and c:IsCanOverlay() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 特召对象过滤：卡是「混沌No.1000 梦幻虚神 原数天灵」（89477759），能够被特殊召唤，且有额外卡组怪兽区域空位。
function c41850466.xyzfilter3(c,e,tp)
	-- 判定该卡是否满足特召条件且额外卡组怪兽区可腾出空位。
	return c:IsCode(89477759) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动的目标阶段：检查能否选择1张「源数网络」和4只「No.」超量怪兽，以及额外卡组存在可特召的「混沌No.1000 梦幻虚神 原数天灵」，随后进行选择并设置操作信息。
function c41850466.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果发动时，检查是否存在至少1张可作为对象的「源数网络」。
	if chk==0 then return Duel.IsExistingTarget(c41850466.xyzfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		-- 同时检查是否存在至少4只可作为对象的「No.」超量怪兽。
		and Duel.IsExistingTarget(c41850466.xyzfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,4,nil)
		-- 同时检查额外卡组是否存在1只可特殊召唤的「混沌No.1000 梦幻虚神 原数天灵」。
		and Duel.IsExistingMatchingCard(c41850466.xyzfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 提示玩家选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从墓地/除外选择1张「源数网络」作为对象，并登记为该连锁的对象。
	local sg1=Duel.SelectTarget(tp,c41850466.xyzfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 提示玩家选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从墓地/除外选择4只「No.」超量怪兽作为对象，并登记为该连锁的对象。
	local sg2=Duel.SelectTarget(tp,c41850466.xyzfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,4,4,nil)
	sg1:Merge(sg2)
	local g=sg1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #g>0 then
		-- 设置操作信息：若有对象卡从墓地移动，则登记这些卡离开墓地的信息。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
	end
	-- 设置操作信息：本次效果将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤条件：用于确认之前选择的对象卡仍与本效果关联，且不会免疫本效果。
function c41850466.mtfilter(c,e)
	return c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end
-- 效果处理：选择额外卡组的「混沌No.1000 梦幻虚神 原数天灵」特殊召唤，设置其攻击力/守备力，将仍有效的对象卡作为超量素材叠放，最后附加本回合的召唤·特殊召唤次数限制。
function c41850466.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的「混沌No.1000 梦幻虚神 原数天灵」。
	local sg=Duel.SelectMatchingCard(tp,c41850466.xyzfilter3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local sc=sg:GetFirst()
	-- 若选择成功，则将该卡以表侧攻击表示进行特殊召唤（作为特殊召唤流程的一个步骤）。
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		-- 变成攻击力10000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(10000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetValue(1000)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		sc:RegisterEffect(e2)
		-- 获取当前连锁记录的目标卡组（发动时选择的1张「源数网络」和4只「No.」超量怪兽）。
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local g=tg:Filter(c41850466.mtfilter,nil,e)
		if #g==5 then
			-- 将仍有效的对象卡作为超量素材叠放到特殊召唤出的「混沌No.1000 梦幻虚神 原数天灵」下面。
			Duel.Overlay(sc,g)
		end
	end
	-- 结束特殊召唤流程，完成特殊召唤。
	Duel.SpecialSummonComplete()
	-- 这个效果的发动后，直到回合结束时自己只能有1次把怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetLabel(c41850466.getsummoncount(tp))
	e1:SetTarget(c41850466.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向当前玩家注册禁止通常召唤的限制效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 向当前玩家注册禁止特殊召唤的限制效果。
	Duel.RegisterEffect(e2,tp)
	-- 这个效果的发动后，直到回合结束时自己只能有1次把怪兽召唤·特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetLabel(c41850466.getsummoncount(tp))
	e3:SetValue(c41850466.countval)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 向当前玩家注册剩余可特殊召唤次数为1的效果，配合限制效果实现本回合只能进行1次召唤·特殊召唤。
	Duel.RegisterEffect(e3,tp)
end
-- 统计玩家本回合已经进行的通常召唤和特殊召唤的次数总和。
function c41850466.getsummoncount(tp)
	-- 返回当前回合召唤（含通常召唤）和特殊召唤的总次数。
	return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)+Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
end
-- 召唤/特殊召唤的限制条件：当已进行的召唤次数超过记录的上限时，禁止新的召唤/特殊召唤。
function c41850466.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c41850466.getsummoncount(sump)>e:GetLabel()
end
-- 用于计算剩余可特殊召唤次数：若已超过上限则剩余0次，否则为1次。
function c41850466.countval(e,re,tp)
	if c41850466.getsummoncount(tp)>e:GetLabel() then return 0 else return 1 end
end
