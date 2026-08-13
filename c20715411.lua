--DDD零死王ゼロ・マキナ
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：这张卡发动的回合的自己主要阶段才能发动。从卡组把1张「契约书」永续魔法·永续陷阱卡在自己场上表侧表示放置。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡在额外卡组表侧存在的状态，「DDD 零死王 零·机降神」以外的自己场上的表侧表示的「DDD」卡或「契约书」卡被破坏的场合才能发动（伤害步骤也能发动）。这张卡特殊召唤。那之后，可以把场上1张卡破坏。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 初始化函数：为该卡注册全部效果，包括手牌发动的誓约标记、灵摆区起动放置「契约书」、额外卡组表侧时特殊召唤并可选破坏、怪兽区被破坏时放置灵摆区。
function s.initial_effect(c)
	-- 为该卡附加灵摆怪兽属性（可进行灵摆召唤、可在灵摆区放置），但不注册通常的灵摆卡“发动”效果（由后续e0手动实现并附加誓约限制）。
	aux.EnablePendulumAttribute(c,false)
	-- 这个卡名的灵摆效果1回合只能使用1次。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(1160)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetRange(LOCATION_HAND)
	e0:SetCost(s.reg)
	c:RegisterEffect(e0)
	-- ①：这张卡发动的回合的自己主要阶段才能发动。从卡组把1张「契约书」永续魔法·永续陷阱卡在自己场上表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置「契约书」卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ①：这张卡在额外卡组表侧存在的状态，「DDD 零死王 零·机降神」以外的自己场上的表侧表示的「DDD」卡或「契约书」卡被破坏的场合才能发动（伤害步骤也能发动）。这张卡特殊召唤。那之后，可以把场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"放置到灵摆区域"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
end
-- 作为手牌发动的COST：发动这张卡时，将1个誓约标记赋予此卡并持续到结束阶段，记录本回合已发动过该卡，用于限制灵摆效果的使用条件。
function s.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 灵摆效果①的发动条件：此卡本回合已通过e0发动过（带有誓约标记），满足“这张卡发动的回合”的前提。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
-- 筛选符合条件的「契约书」卡：必须是永续魔法·永续陷阱卡、具有0xae字段、不属于禁止卡，且自己场上不能有同名卡。
function s.pfilter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0xae)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 灵摆效果①的目标判定：确认魔陷区有空位，且卡组中存在符合条件的「契约书」卡；如果满足则允许发动并设置相关处理信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否有可用空格，用于能否放置永续魔法·陷阱。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在至少1张满足s.pfilter条件的「契约书」永续魔法·永续陷阱卡。
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 执行灵摆效果①：若魔陷区仍有空格，则从卡组选择一张符合条件的「契约书」卡，以表侧表示放置到自己魔陷区。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认魔陷区仍有空格，若已无空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向玩家显示“请选择要放置到场上的卡”的提示，用于从卡组选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择1张满足s.pfilter条件的「契约书」卡，并获取该卡对象。
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	-- 若选到了符合条件的卡，则将其以表侧表示移动到自己的魔陷区（即放置上场）。
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
-- 判断被破坏的卡是否属于诱发条件：破坏前是自己场上的表侧表示「DDD」卡或「契约书」卡，且不是本卡（零·机降神）自身。
function s.cfilter(c,tp)
	return c:IsPreviousSetCard(0x10af,0xae) and c:GetPreviousCodeOnField()~=id
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- 怪兽效果①的发动条件：本次破坏事件中存在满足s.cfilter的卡，且该卡在额外卡组表侧表示，且被破坏的卡中不包含此卡自身。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler(),tp) and e:GetHandler():IsFaceup() and not eg:IsContains(e:GetHandler())
end
-- 怪兽效果①的目标判定：确认此卡可以被特殊召唤（根据所在位置检查额外或主怪兽区空位），并设置操作信息为特殊召唤此卡。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:IsLocation(LOCATION_EXTRA) then
			-- 当此卡位于额外卡组时，检查从额外卡组特殊召唤所需的空格是否足够，且此卡能够被特殊召唤（不检查苏生限制）。
			return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		else
			-- 当此卡不位于额外卡组时，检查主要怪兽区是否有空格且此卡能够被特殊召唤。
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end
	end
	-- 设置本次效果的操作信息为“特殊召唤该卡”，供其他卡/效果进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行怪兽效果①：先特殊召唤此卡；若成功且场上存在可选择卡，则询问玩家是否破坏场上1张卡；若选择是，则从场上选1张卡破坏。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍与当前连锁相关，并尝试将其以表侧表示特殊召唤；只有特殊召唤成功才继续后续处理。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 特殊召唤成功后，若场上（双方）存在可作为破坏对象的卡，则询问玩家是否要发动破坏场上1张卡的追加处理。
		and Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否破坏？"
		-- 从双方场上选择1张卡作为破坏对象。
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
		if #g>0 then
			-- 中断当前效果链，使后续破坏处理与特殊召唤处理视为不同时进行，避免错失时点。
			Duel.BreakEffect()
			-- 手动展示被选为破坏对象的卡，并记录其被选为对象（广义）。
			Duel.HintSelection(g)
			-- 以效果原因破坏选中的卡，将其送去墓地。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 怪兽效果②的发动条件：此卡在怪兽区域被破坏，且破坏前是表侧表示。
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果②的目标判定：确认自己的灵摆区域有空格；若此卡在墓地则设置“离开墓地”的操作信息。
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域左右两个位置中是否有至少一个空位可供这张卡放置。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) then
		-- 若此卡当前位于墓地，则设置操作信息为“此卡将离开墓地”，用于相关效果检测。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- 执行怪兽效果②：若此卡仍与连锁相关且不受王家长眠之谷等效果影响，则将其以表侧表示放置到自己的灵摆区域。
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍与当前连锁相关，并确认其可以移动（尤其不能被王家长眠之谷等效果阻止）。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡移动到自己的灵摆区域，以表侧表示放置，成为灵摆卡。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
