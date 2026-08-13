--舞い戻った死神
-- 效果：
-- 这个卡名在规则上也当作「永火」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地的怪兽以及除外的自己怪兽之中选1只「永火」怪兽特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「永火」怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。这张卡在自己场上盖放。
function c4599182.initial_effect(c)
	-- ①：从自己的手卡·墓地的怪兽以及除外的自己怪兽之中选1只「永火」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,4599182)
	e1:SetTarget(c4599182.target)
	e1:SetOperation(c4599182.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「永火」怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,4599183)
	e2:SetCondition(c4599182.setcon)
	e2:SetTarget(c4599182.settg)
	e2:SetOperation(c4599182.setop)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤对象的筛选函数：检查候选怪兽是否满足「永火」字段、能否被特殊召唤，且所处位置为手牌·墓地或表侧除外。
function c4599182.filter(c,e,tp)
	return c:IsSetCard(0xb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) or c:IsFaceup())
end
-- 效果①的发动条件和目标选择：在发动时确认自己场上存在空位，且存在至少1只满足筛选条件的「永火」怪兽，并登记特殊召唤的操作信息。
function c4599182.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位，作为效果①发动的前提条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在至少1只符合条件的「永火」怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c4599182.filter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 登记本次连锁要进行特殊召唤的操作信息（不取对象，数量1，来源范围为手牌·墓地·除外区）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果①处理时：让玩家从手牌·墓地·表侧除外的自己怪兽中选择1只「永火」怪兽，并以表侧表示特殊召唤到场上。
function c4599182.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认怪兽区还有空位，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽（显示“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 使用过滤函数选择1张符合条件的「永火」怪兽（同时排除墓地受王家长眠之谷影响的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4599182.filter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果的触发过滤条件：离场怪兽必须是我方场上表侧表示的「永火」怪兽，且离场原因为战斗破坏或对方的效果。
function c4599182.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and bit.band(c:GetPreviousTypeOnField(),TYPE_MONSTER)~=0
		and c:IsPreviousSetCard(0xb) and (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
end
-- ②效果的发动条件：只要存在满足条件的我方「永火」怪兽离场，且离场怪兽不是本卡自身，即可发动。
function c4599182.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c4599182.cfilter,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end
-- ②效果发动时的合法性检查：确认本卡位于墓地且可以在魔法陷阱区盖放，并登记本卡将离开墓地的操作信息。
function c4599182.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 登记本卡将离开墓地的操作信息，使与墓地移动相关的卡片（如王家长眠之谷）可以进行连锁/干扰判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理时：若本卡仍在墓地且与效果关联，则将其盖放到自己的魔法陷阱区。
function c4599182.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将本卡以里侧表示设置到自己的魔法陷阱区。
		Duel.SSet(tp,c)
	end
end
