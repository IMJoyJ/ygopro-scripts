--烙印の獣
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，自己·对方的主要阶段，自己场上有「深渊之兽」怪兽存在的场合，把自己场上1只龙族怪兽解放，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：自己·对方的结束阶段，以自己墓地1张「烙印」永续魔法·永续陷阱卡为对象才能发动。那张卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 定义卡的初始化函数：为「烙印之兽」注册永续魔陷/场地卡通用的发动许可效果e0，以及①效果的破坏效果e1和②效果的墓地永续魔陷放置效果e2，其中e1是主要阶段可发动的取对象快速效果，e2是结束阶段发动的取对象效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：1回合1次，自己·对方的主要阶段，自己场上有「深渊之兽」怪兽存在的场合，把自己场上1只龙族怪兽解放，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"对方卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetLabel(0)
	e1:SetCondition(s.descon)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方的结束阶段，以自己墓地1张「烙印」永续魔法·永续陷阱卡为对象才能发动。那张卡在自己场上表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收墓地永续魔陷"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 定义①效果的发动条件：当前阶段为自己或对方的主要阶段，且自己场上有表侧表示的「深渊之兽」怪兽存在。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段并存入ph变量，用于判断是否为主要阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		-- 检查自己场上是否存在至少1张表侧表示且属于「深渊之兽」字段（0x188）的怪兽，作为①效果的发动条件之一。
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x188)
end
-- 定义选择解放龙族怪兽的过滤函数：候选怪兽须为龙族，且控制者为自己或是表侧表示，同时对方场上存在至少1张除此候选卡以外能够成为破坏对象的卡。
function s.cfilter(c,tp)
	return c:IsRace(RACE_DRAGON) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查对方场上是否存在至少1张除候选卡c以外、能够成为效果对象的卡，以保证发动时可以选择破坏目标。
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,c)
end
-- 定义①效果的代价函数：由于需要先选择解放的龙族怪兽再进行破坏取对象，此函数仅设置内部标记（e:SetLabel(1)）并返回true，实质解放操作推迟到target阶段处理。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 定义①效果的target函数：进行发动合法性检查，确认存在可解放的龙族怪兽且对方场上有可取对象后，在发动时处理解放cost，并选择对方场上1张卡作为破坏对象，同时设置破坏的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	local l=e:GetLabel()==1
	if chk==0 then
		e:SetLabel(0)
		-- 在效果发动合法性检查中，确认代价函数已设置标记（l为真）且存在至少1只满足过滤条件的可解放龙族怪兽。
		return l and Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp)
	end
	if l then
		e:SetLabel(0)
		-- 向玩家显示“请选择要解放的卡”的提示，用于引导选择解放cost。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 让玩家从自己场上选择1只满足s.cfilter的龙族怪兽作为解放cost。
		local sg=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
		-- 将选中的龙族怪兽作为①效果的代价解放（REASON_COST）。
		Duel.Release(sg,REASON_COST)
	end
	-- 向玩家显示“请选择要破坏的卡”的提示，用于引导选择破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡作为①效果的破坏对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，声明本次连锁处理会破坏1张卡（对象为g），以便其他卡牌或时点进行响应检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义①效果处理时的操作：取得连锁对象，若对象仍与效果相关，则将其以效果破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果当前连锁处理的对象（对方场上被选择的那张卡）。
	local tc=Duel.GetFirstTarget()
	-- 如果目标卡仍与该效果存在关联（未离场、未被无效等），则将其以卡片效果（REASON_EFFECT）破坏。
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 定义②效果的发动条件：当前阶段为结束阶段，即自己或对方的结束阶段均可发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前游戏阶段是否为结束阶段（PHASE_END）。
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 定义墓地目标过滤函数：选择「烙印」字段（0x15d）的永续魔法·永续陷阱卡，且该卡不是禁止卡，并满足场上同名卡放置限制（CheckUniqueOnField）。
function s.filter(c,tp)
	return c:IsSetCard(0x15d) and c:IsType(TYPE_CONTINUOUS)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 定义②效果的target函数：确认自己魔陷区有空位且墓地存在符合条件的「烙印」永续魔陷后，选择其中1张作为对象，并设置卡片从墓地离开的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	-- 在②效果发动合法性检查中，确认自己魔陷区存在至少1个可用区域，用于放置目标卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认自己墓地存在至少1张满足s.filter条件的「烙印」永续魔法·永续陷阱卡可以作为效果对象。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 向玩家显示“请选择要放置到场上的卡”的提示，用于引导选择墓地目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从自己墓地选择1张满足s.filter条件的「烙印」永续魔法·永续陷阱卡作为②效果的对象，并登记到连锁。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息，声明本次连锁处理会将1张卡从墓地移出（放置到场上），以便触发相关时点。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 定义②效果处理时的操作：取得目标卡，若仍与效果相关，则将其表侧表示放置到自己魔陷区。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果当前连锁处理的对象（墓地中被选择的「烙印」永续魔陷）。
	local tc=Duel.GetFirstTarget()
	-- 若目标卡仍与该效果存在关联，则将其表侧表示移动到自己魔陷区（LOCATION_SZONE），并立即适用该卡的效果。
	if tc:IsRelateToEffect(e) then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
