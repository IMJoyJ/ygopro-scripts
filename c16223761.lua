--サンダー・ハンド
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，原本攻击力或者原本守备力是1600的自己场上的表侧表示怪兽被战斗或者对方的效果破坏送去墓地的场合才能发动。这张卡特殊召唤，选对方场上1张卡破坏。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c16223761.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，原本攻击力或者原本守备力是1600的自己场上的表侧表示怪兽被战斗或者对方的效果破坏送去墓地的场合才能发动。这张卡特殊召唤，选对方场上1张卡破坏。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16223761,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,16223761)
	e1:SetCondition(c16223761.spcon)
	e1:SetTarget(c16223761.sptg)
	e1:SetOperation(c16223761.spop)
	c:RegisterEffect(e1)
end
-- 过滤这次送去墓地的怪兽：必须此前是表侧表示、此前由自己控制、此前位于自己的主要怪兽区，并且原本攻击力或原本守备力为1600，同时破坏原因满足“战斗破坏”或“对方的效果破坏”。
function c16223761.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:GetBaseAttack()==1600 or c:GetBaseDefense()==1600)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()==1-tp)
end
-- 判断发动条件：这次送去墓地的怪兽中存在满足cfilter条件的卡；同时这张雷电子若在手牌则无需额外限制，若在墓地则要求它自身不是这次被送去墓地的怪兽之一。
function c16223761.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(c16223761.cfilter,1,nil,tp) and (c:IsLocation(LOCATION_HAND) or not eg:IsContains(c))
end
-- 效果发动时进行合法性检查：自己场上是否有空余怪兽区、这张卡是否能够特殊召唤、对方场上是否存在至少1张可以破坏的卡；满足条件才能进入发动流程。
function c16223761.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可以特殊召唤这张卡的空余怪兽区，并且这张卡本身是否满足特殊召唤条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查对方场上是否存在至少1张任意卡（用于后续效果处理时选择破坏的目标）。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡，作为后续可能被破坏的目标集合，用于登记破坏效果的操作信息。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 登记本连锁的特殊召唤操作信息，声明将特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 登记本连锁的破坏操作信息，声明将破坏对方场上1张卡，目标集合为之前获取的对方场上所有卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：先确认这张卡仍与效果关联并尝试特殊召唤；特殊召唤成功后赋予其离场时除外的效果，然后让对方选择并破坏对方场上1张卡。
function c16223761.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断效果发动时的这张卡是否仍与当前效果关联，且能够成功特殊召唤；若特殊召唤成功则继续执行后续的破坏与除外处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 选对方场上1张卡破坏。这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		-- 向发动玩家显示选择提示，提示内容为“请选择要破坏的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让发动玩家从对方场上选择1张卡（不取对象，效果处理时选择）作为破坏目标。
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 展示被选中的卡并记录其为本次效果选择的卡。
			Duel.HintSelection(g)
			-- 将选择的卡以效果原因破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
