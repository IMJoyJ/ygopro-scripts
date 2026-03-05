--サンダー・ハンド
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，原本攻击力或者原本守备力是1600的自己场上的表侧表示怪兽被战斗或者对方的效果破坏送去墓地的场合才能发动。这张卡特殊召唤，选对方场上1张卡破坏。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c16223761.initial_effect(c)
	-- 创建效果1，用于处理雷电手的诱发效果，该效果为场地区域触发的选发效果，触发事件是怪兽送去墓地时
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
-- 过滤函数，用于判断被破坏的怪兽是否满足条件：原本攻击力或守备力为1600，且是由战斗或对方效果破坏并送去墓地
function c16223761.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:GetBaseAttack()==1600 or c:GetBaseDefense()==1600)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()==1-tp)
end
-- 效果发动条件函数，判断是否有满足条件的怪兽被破坏，且雷电手本身在手牌或不在被破坏的怪兽组中
function c16223761.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(c16223761.cfilter,1,nil,tp) and (c:IsLocation(LOCATION_HAND) or not eg:IsContains(c))
end
-- 效果处理的准备阶段，检查是否满足特殊召唤和破坏对方场上卡的条件
function c16223761.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否至少存在一张对方场上的卡可以被破坏
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡作为可能的破坏对象
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果处理信息，表示将特殊召唤雷电手
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置效果处理信息，表示将破坏对方场上的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，执行雷电手的特殊召唤和后续破坏操作
function c16223761.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查雷电手是否仍然存在于游戏中，然后将其特殊召唤到场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 为特殊召唤的雷电手设置效果，使其离开场上时被除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的一张卡作为破坏目标
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 显示所选卡被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将所选的卡破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
