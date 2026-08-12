--水晶機巧－シトリィ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：对方的主要阶段以及战斗阶段，以调整以外的自己墓地1只怪兽为对象才能发动。那只怪兽效果无效特殊召唤，只用那只怪兽和这张卡为素材把1只机械族同调怪兽同调召唤。那个时候的同调素材怪兽不去墓地而除外。
function c20050865.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20050865,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,20050865)
	e1:SetCondition(c20050865.sccon)
	e1:SetTarget(c20050865.sctg)
	e1:SetOperation(c20050865.scop)
	c:RegisterEffect(e1)
end
-- 对方的主要阶段以及战斗阶段
function c20050865.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 效果发动时，当前不在连锁中且不是当前回合玩家
	return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetTurnPlayer()~=tp
		and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end
-- 过滤满足条件的墓地怪兽，排除调整，可以特殊召唤且能进行同调召唤
function c20050865.scfilter1(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否存在满足同调条件的机械族同调怪兽
		and Duel.IsExistingMatchingCard(c20050865.scfilter2,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 过滤满足同调条件的机械族同调怪兽
function c20050865.scfilter2(c,mg)
	return c:IsRace(RACE_MACHINE) and c:IsSynchroSummonable(nil,mg)
end
-- 设置效果发动时的条件检查
function c20050865.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20050865.scfilter1(chkc,e,tp,e:GetHandler()) end
	-- 检查玩家是否可以进行2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查玩家场上是否有足够的特殊召唤位置
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的墓地怪兽
		and Duel.IsExistingTarget(c20050865.scfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler()) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标墓地怪兽
	local g=Duel.SelectTarget(tp,c20050865.scfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetHandler())
	-- 设置效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果发动的执行流程
function c20050865.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的特殊召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功特殊召唤
	if not tc:IsRelateToEffect(e) or not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then return end
	-- 使目标怪兽效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	tc:RegisterEffect(e2)
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	if not c:IsRelateToEffect(e) then return end
	-- 刷新场地信息
	Duel.AdjustAll()
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取满足同调条件的机械族同调怪兽
	local g=Duel.GetMatchingGroup(c20050865.scfilter2,tp,LOCATION_EXTRA,0,nil,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将此卡和目标怪兽除外，进行同调召唤
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
		local e2=e1:Clone()
		tc:RegisterEffect(e2,true)
		-- 进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
