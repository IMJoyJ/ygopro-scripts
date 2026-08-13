--ピットナイト・アーリィ
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡所连接区的怪兽把效果发动时，以对方场上1只效果怪兽为对象才能发动。那只怪兽直到回合结束时攻击力变成0，效果无效化。
-- ②：这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 定义卡片的初始效果注册函数：赋予连接召唤限制，设定2只效果怪兽为连接素材的召唤手续，并注册①的诱发即时效果（无效怪兽）和②的墓地复活效果，以及用于记录破坏送墓的辅助连续效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：需要2只效果怪兽作为连接素材（素材必须是效果怪兽）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2)
	-- 对应①效果：“这张卡所连接区的怪兽把效果发动时，以对方场上1只效果怪兽为对象才能发动。那只怪兽直到回合结束时攻击力变成0，效果无效化。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- 对应②效果中“这张卡被战斗·效果破坏送去墓地的回合”这一前置条件；此连续效果用于记录卡片被战斗或效果破坏送墓的事实。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- 对应②效果：“这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。”
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判定：确认此卡未被战斗破坏确定状态、有怪兽在自己所连接区发动效果，且该效果是怪兽效果。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 获取当前连锁的发动位置、格子序号和发动者，用于判断发动效果的怪兽是否位于这张卡的连接区域内。
	local loc,seq,p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE,CHAININFO_TRIGGERING_CONTROLER)
	if p==1-tp then seq=seq+16 end
	return re:IsActiveType(TYPE_MONSTER) and loc&LOCATION_MZONE>0 and bit.extract(c:GetLinkedZone(),seq)~=0
end
-- 定义①效果可选择的对方怪兽条件：表侧表示、效果怪兽，且攻击力大于0或当前未被无效化。
function s.filter(c)
	-- 具体筛选条件：表侧表示、效果怪兽，并且攻击力大于0或尚未被无效化（这样无效和降攻才有意义）。
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and (c:GetAttack()>0 or aux.NegateEffectMonsterFilter(c))
end
-- ①效果的目标选择处理：在发动时确认存在合法目标，并让对方场上1只满足条件的表侧效果怪兽成为对象。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	-- 效果发动合法性检查：确认对方场上是否存在至少1只符合条件的效果怪兽可以成为对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要无效的卡”的选择提示，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只满足条件的表侧效果怪兽作为效果对象，并登记为当前连锁的取对象目标。
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ①效果处理时的操作：将对象怪兽的攻击力变成0，效果无效化，同时无效与该对象相关的正在发动的连锁。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁登记的唯一对象怪兽，即①效果选择无效的那只对方怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与对象怪兽有关的连锁效果无效化，即无效对方那只怪兽发动的效果（对应“效果无效化”中的连锁无效部分）。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对应效果原文“效果无效化”：给对象怪兽附加不能无效的无效化效果（EFFECT_DISABLE），使其场上效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 对应效果原文“效果无效化”：给对象怪兽附加无效其发动的效果的效果（EFFECT_DISABLE_EFFECT），同样用于无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 对应效果原文“攻击力变成0”：将对象怪兽的攻击力最终值固定为0。
		local e3=Effect.CreateEffect(c)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(0)
		tc:RegisterEffect(e3)
	end
end
-- ②效果的辅助触发条件：判断这张卡确实是被战斗或效果破坏并因此送去墓地。
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 满足破坏送墓条件时，给这张卡设置一个标志，用于在结束阶段判断本回合是否曾被破坏送墓。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ②效果的发动条件：确认这张卡带有被破坏送墓的标志，从而可以在结束阶段发动复活效果。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- ②效果的发动目标检查：确认自己场上有空位，且这张卡可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空余位置，用于满足特殊召唤条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：宣告将要把这张卡特殊召唤，供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的实际处理：将这张卡从墓地特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果存在关联后，将其以表侧攻击表示特殊召唤到自己场上。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
