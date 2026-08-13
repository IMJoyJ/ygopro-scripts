--蒼穹を睨めるダーク
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的状态，对方发动的怪兽的效果从卡组或额外卡组让怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
-- ②：包含把怪兽特殊召唤效果的怪兽的效果发动时，从自己的手卡·场上把1张卡除外才能发动。那个效果无效并破坏。
-- ③：这张卡被除外的回合的结束阶段才能发动。自己的除外状态的1只其他怪兽回到墓地。
local s,id,o=GetID()
-- 定义该卡的初始化函数，创建并注册①～③效果及③的辅助效果（①特殊召唤自身、②无效并破坏怪兽效果、③回收除外怪兽、以及被除外时打标记的辅助效果）。
function s.initial_effect(c)
	-- 这个卡名的①②③的效果1回合各能使用1次。①：这张卡在墓地存在的状态，对方发动的怪兽的效果从卡组或额外卡组让怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：包含把怪兽特殊召唤效果的怪兽的效果发动时，从自己的手卡·场上把1张卡除外才能发动。那个效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的回合的结束阶段才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_REMOVE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	-- ③：这张卡被除外的回合的结束阶段才能发动。自己的除外状态的1只其他怪兽回到墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"回收除外"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.tgcon)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
-- 判定特殊召唤成功的怪兽是否为对方发动的怪兽效果从卡组/额外卡组特殊召唤的怪兽。
function s.cfilter(c,tp)
	local typ,se,sp=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_REASON_EFFECT,SUMMON_INFO_REASON_PLAYER)
	return se and typ&TYPE_MONSTER~=0 and se:IsActivated() and sp==1-tp
		and c:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- ①效果的发动条件：存在对方发动的怪兽效果从卡组/额外卡组特殊召唤怪兽成功的场合。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 检查自己场上是否有空余怪兽区域，以及这张卡自身是否能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次处理将进行的特殊召唤操作信息（特殊召唤这张卡，数量1），供连锁响应判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理①效果：若该卡仍与连锁相关且不受王家长眠之谷影响，则将其表侧攻击表示特殊召唤到自己的主要怪兽区域。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡还在处理连锁中且不受王家长眠之谷等效果影响，才能进行特殊召唤处理。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡表侧攻击表示特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：当前发动的效果是带有特殊召唤怪兽效果且为怪兽效果，并且该连锁可以被无效。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动中的效果是否拥有特殊召唤分类，且该连锁是否可被无效。
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and Duel.IsChainDisablable(ev)
		and re:IsActiveType(TYPE_MONSTER)
end
-- ②效果的发动代价：从自己的手卡·场上选择1张卡除外。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己手卡或场地上是否存在1张可以作为代价除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 显示选择提示，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 由玩家从手卡·场上选择1张可作为代价除外的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的卡表侧表示除外，作为发动②的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果发动时无需选择对象；登记使该效果无效的信息，并视情况登记破坏发动效果怪兽的信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记要无效的对象是当前连锁的这个效果，用于处理时使该效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记要破坏的对象是发动该效果的怪兽，在该怪兽可被破坏且与效果相关时处理。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 处理②效果：先将该连锁效果无效，若发动效果的怪兽仍与连锁相关，则将其破坏。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的效果无效，并确认发动效果的怪兽是否仍与该连锁相关。
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 将发动效果的怪兽破坏（由该②效果视为效果破坏）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 辅助处理：当这张卡被除外时，给自身设置一个持续到结束阶段的标记，用于③的发动条件。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ③效果的发动条件：这张卡在本回合内被除外过（带有对应标记）。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- ③效果的目标筛选：除外状态、表侧表示、且为怪兽的卡。
function s.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- ③效果发动时：选择自己除外区1只除自身以外的表侧表示怪兽作为对象。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己除外区存在符合条件的其他表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_REMOVED,0,1,e:GetHandler()) end
end
-- 处理③效果：让玩家选择1只其他除外怪兽送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 由玩家从自己除外区的表侧表示怪兽中选择1只除这张卡以外的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_REMOVED,0,1,1,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 将选择的怪兽送去墓地（原因包含效果和返回）。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
	end
end
