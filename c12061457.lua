--ソウル・シザー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的状态，场上的怪兽被战斗·效果破坏送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡从墓地的特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 初始化效果函数：给这张卡注册①②两个效果，并分别设置1回合各能使用1次的次数限制；①为墓地中因场上怪兽被战斗/效果破坏而特殊召唤自身的效果，②为从墓地特殊召唤成功后破坏对方怪兽的效果。
function s.initial_effect(c)
	-- 为这张卡注册一个“已在墓地”的标记检测效果并返回该效果，用于记录卡片已在墓地存在的状态，防止同一连锁中的重复判定。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：这张卡在墓地存在的状态，场上的怪兽被战斗·效果破坏送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	-- ②：这张卡从墓地的特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选出因破坏而被送去墓地、且破坏原因为战斗或效果、破坏前位于主要怪兽区的怪兽；若传入效果se，则进一步排除由该效果导致的破坏，避免产生自循环触发。
function s.cfilter(c,se)
	return c:IsReason(REASON_DESTROY)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ①效果的发动条件：本次送去墓地的怪兽组eg中存在至少1只满足上述过滤条件的怪兽，且eg中不包含这张卡自身，以保证发动时这张卡已在墓地，而非本次被破坏送去墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,se) and not eg:IsContains(e:GetHandler())
end
-- ①效果的发动时点检查与操作信息设置：在发动前确认自己怪兽区有空位且这张卡能够被特殊召唤；满足条件后设置本次连锁为特殊召唤这张卡的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区空格，作为特殊召唤的前提条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息：将这张卡（e:GetHandler()）以数量1进行特殊召唤类别登记，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其表侧攻击表示特殊召唤到自己场上；若特殊召唤成功，再给它注册一个离场时改为除外的不入连锁效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍然与当前效果相关联且特殊召唤成功（返回大于0），只有满足条件才执行后续的离场除外附加效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外；②：这张卡从墓地的特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- ②效果的发动条件：这张卡特殊召唤成功且其特殊召唤前的所在位置是墓地（即是从墓地特殊召唤成功）。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- ②效果的发动时点处理：满足条件后，选择对方场上1只怪兽作为对象，并设置破坏该对象的操作信息；同时在发动前检查是否存在可选对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 在发动条件检查时，确认对方场上存在至少1只可被作为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示选择破坏对象的提示信息（“请选择要破坏的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作玩家从对方场上选择1只怪兽作为对象，并将该对象注册到当前连锁中。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：将选择的对象g以数量1纳入破坏类别，供后续处理与效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得对象怪兽；若对象仍与当前效果相关联，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象（即之前选择的对方场上怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果破坏为原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
