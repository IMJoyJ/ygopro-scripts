--相愛のアンブレカム
-- 效果：
-- ①：这张卡召唤成功时，丢弃1张手卡，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
function c73979030.initial_effect(c)
	-- ①：这张卡召唤成功时，丢弃1张手卡，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73979030,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(c73979030.spcost)
	e1:SetTarget(c73979030.sptg)
	e1:SetOperation(c73979030.spop)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理函数：丢弃1张手卡
function c73979030.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手卡中是否存在除这张卡以外的、可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 作为发动代价，选择并丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：自己墓地4星以下且可以守备表示特殊召唤的怪兽
function c73979030.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果的目标（Target）处理函数：检查怪兽区域空位，并选择自己墓地1只满足条件的怪兽作为对象
function c73979030.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c73979030.filter(chkc,e,tp) end
	-- 在发动阶段，检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingTarget(c73979030.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c73979030.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该连锁包含特殊召唤该目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果的运行（Operation）处理函数：将对象怪兽守备表示特殊召唤并无效其效果，之后施加“直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤”的限制
function c73979030.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 如果该对象怪兽仍符合条件，则将其以表侧守备表示特殊召唤（分步处理）
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
	end
	-- 这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c73979030.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能从额外卡组特殊召唤同调怪兽以外怪兽的限制效果注册给玩家
	Duel.RegisterEffect(e3,tp)
end
-- 特殊召唤限制的过滤函数：限制从额外卡组特殊召唤非同调怪兽
function c73979030.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
