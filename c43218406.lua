--機巧辰－高闇御津羽靇
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：从额外卡组特殊召唤的怪兽在场上有2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：支付1500基本分才能发动。从额外卡组特殊召唤的场上的怪兽全部破坏。这个回合，自己只能用1只怪兽攻击。
-- ③：这张卡被对方送去墓地的场合才能发动。选对方墓地1只怪兽除外。那之后，自己基本分回复那个攻击力的数值。
function c43218406.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：从额外卡组特殊召唤的怪兽在场上有2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,43218406)
	e1:SetCondition(c43218406.spcon)
	e1:SetTarget(c43218406.sptg)
	e1:SetOperation(c43218406.spop)
	c:RegisterEffect(e1)
	-- ②：支付1500基本分才能发动。从额外卡组特殊召唤的场上的怪兽全部破坏。这个回合，自己只能用1只怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43218406,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c43218406.descost)
	e2:SetTarget(c43218406.destg)
	e2:SetOperation(c43218406.desop)
	c:RegisterEffect(e2)
	-- 这个卡名的①③的效果1回合各能使用1次。③：这张卡被对方送去墓地的场合才能发动。选对方墓地1只怪兽除外。那之后，自己基本分回复那个攻击力的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43218406,2))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,43218407)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c43218406.recon)
	e3:SetTarget(c43218406.retg)
	e3:SetOperation(c43218406.reop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断怪兽是否是从额外卡组特殊召唤（IsSummonLocation(LOCATION_EXTRA)），用于筛选场上从额外卡组特殊召唤的怪兽。
function c43218406.spfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- ①效果的发动条件：检查双方怪兽区是否存在至少2只从额外卡组特殊召唤的怪兽（通过spfilter过滤）。
function c43218406.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 用Duel.IsExistingMatchingCard检查双方怪兽区是否存在至少2只满足spfilter的怪兽，作为①效果的发动条件。
	return Duel.IsExistingMatchingCard(c43218406.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil)
end
-- ①效果的发动目标/合法性检查：确认自己场上有空余的主怪兽区，且手卡的这张卡可以进行特殊召唤；满足时返回true。
function c43218406.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查（chk==0）时，检查自己场上主怪兽区是否有可用空格，用于确认能否特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明效果处理时将把这张卡（e:GetHandler()）特殊召唤，数量为1，用于给系统记录CATEGORY_SPECIAL_SUMMON。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：从手卡将这张卡以表侧攻击表示特殊召唤到自己场上。
function c43218406.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 实际执行特殊召唤：将这张卡以表侧表示（POS_FACEUP）特殊召唤到自己场上，不无视召唤条件（nocheck=false）和苏生限制（nolimit=false）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动代价：检查并支付1500基本分（LP）作为发动代价。
function c43218406.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己能否支付1500基本分，若能则允许发动。
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	-- 实际支付1500基本分，扣除发动者LP。
	Duel.PayLPCost(tp,1500)
end
-- 过滤函数：判断怪兽是否是从额外卡组特殊召唤的，用于筛选②效果要破坏的怪兽。
function c43218406.desfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- ②效果的发动目标处理：检查场上是否至少存在1只从额外卡组特殊召唤的怪兽；若存在，则将所有此类怪兽作为破坏对象（不取对象），并设置破坏的操作信息。
function c43218406.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认场上存在至少1只从额外卡组特殊召唤的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c43218406.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取当前场上所有从额外卡组特殊召唤的怪兽，组成集合sg，用于设置破坏对象。
	local sg=Duel.GetMatchingGroup(c43218406.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：声明将破坏sg中的所有怪兽，数量为sg的卡数，用于系统记录CATEGORY_DESTROY。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ②效果的处理：破坏场上所有从额外卡组特殊召唤的怪兽；之后设置这个回合自己只能用1只怪兽攻击的限制效果。
function c43218406.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在处理时重新获取场上所有从额外卡组特殊召唤的怪兽集合sg（因为处理时场上可能发生变化）。
	local sg=Duel.GetMatchingGroup(c43218406.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因（REASON_EFFECT）破坏sg中的所有怪兽（送入墓地）。
	Duel.Destroy(sg,REASON_EFFECT)
	local c=e:GetHandler()
	-- 这个回合，自己只能用1只怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(c43218406.checkop)
	-- 将desop内创建的e1注册为场上的持续效果：监听攻击宣言事件，用于记录本回合首次攻击宣言的怪兽（配合攻击限制）。
	Duel.RegisterEffect(e1,tp)
	-- 这个回合，自己只能用1只怪兽攻击。③：这张卡被对方送去墓地的场合才能发动。选对方墓地1只怪兽除外。那之后，自己基本分回复那个攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(c43218406.atkcon)
	e2:SetTarget(c43218406.atktg)
	e1:SetLabelObject(e2)
	-- 将e2注册为场上的持续效果：给己方怪兽区附加“不能攻击宣言”的限制，但通过atkcon/atktg只限制非首次攻击的怪兽。
	Duel.RegisterEffect(e2,tp)
end
-- 攻击宣言监视效果：记录本回合第一次攻击宣言的怪兽的FieldID，并设置标识，使后续攻击限制效果生效。
function c43218406.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若已记录过本回合的首次攻击（flag>0），则不再重复记录，直接返回。
	if Duel.GetFlagEffect(tp,43218406)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	-- 为玩家注册一个阶段结束复位的标识，表示本回合已记录过首次攻击宣言，用于限制后续攻击行为。
	Duel.RegisterFlagEffect(tp,43218406,RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
-- 攻击限制效果的发动条件：本回合已经发生过一次攻击宣言（flag>0）时才适用。
function c43218406.atkcon(e)
	-- 检查玩家tp的flag数量是否大于0，用于判断本回合是否已有首次攻击宣言。
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),43218406)>0
end
-- 攻击限制的目标判定：若怪兽不是本回合首次攻击宣言的怪兽（FieldID与记录的Label不同），则禁止其攻击宣言。
function c43218406.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- ③效果的发动条件：这张卡被对方玩家（rp==1-tp）以效果等方式送去墓地，且该卡在被送去墓地前是自己控制。
function c43218406.recon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤函数：选择对方墓地的怪兽作为③效果除外的对象，要求是可除外且为怪兽。
function c43218406.filter(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_MONSTER)
end
-- ③效果的发动目标处理：检查对方墓地是否有1只可除外的怪兽；若有，则设置“除外”与“回复LP”的操作信息。
function c43218406.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查对方墓地是否存在至少1只满足filter的怪兽，作为③效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c43218406.filter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 设置操作信息：声明将把对方墓地的1只怪兽除外（位置为对方墓地，数量1），用于系统记录CATEGORY_REMOVE。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
	-- 设置操作信息：声明之后自己将回复LP（数值待处理时确定），用于系统记录CATEGORY_RECOVER。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
-- ③效果的处理：从对方墓地选择1只怪兽除外，若成功且其攻击力大于0，则自己回复该攻击力数值的LP。
function c43218406.reop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者发送选择提示（提示文本为“请选择要除外的卡”），用于选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让操作者从对方墓地选择1只满足filter的怪兽，取第一张作为要除外的卡；若无卡则tc为nil。
	local tc=Duel.SelectMatchingCard(tp,c43218406.filter,tp,0,LOCATION_GRAVE,1,1,nil):GetFirst()
	if not tc then return end
	local atk=tc:GetTextAttack()
	-- 执行除外，若除外成功（返回非0）且记录的原本攻击力atk大于0，则继续处理回复LP。
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and atk>0 then
		-- 中断当前效果链，使回复LP作为后续另行处理，避免与除外视为同时处理（防止错失时点）。
		Duel.BreakEffect()
		-- 以效果原因（REASON_EFFECT）回复自己atk数值的LP。
		Duel.Recover(tp,atk,REASON_EFFECT)
	end
end
