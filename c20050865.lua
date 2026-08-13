--水晶機巧－シトリィ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：对方的主要阶段以及战斗阶段，以调整以外的自己墓地1只怪兽为对象才能发动。那只怪兽效果无效特殊召唤，只用那只怪兽和这张卡为素材把1只机械族同调怪兽同调召唤。那个时候的同调素材怪兽不去墓地而除外。
function c20050865.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：对方的主要阶段以及战斗阶段，以调整以外的自己墓地1只怪兽为对象才能发动。那只怪兽效果无效特殊召唤，只用那只怪兽和这张卡为素材把1只机械族同调怪兽同调召唤。那个时候的同调素材怪兽不去墓地而除外。
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
-- 效果发动条件判定：仅在对方回合的主要阶段（M1/M2）或战斗阶段，且此卡不在连锁处理中时才允许发动。
function c20050865.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 确认此卡不在连锁串中，且当前是对方回合。
	return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetTurnPlayer()~=tp
		and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end
-- 选择对象怪兽的过滤条件：该怪兽不是调整，能够被本效果特殊召唤，并且以该怪兽和这张卡为素材能够同调召唤机械族同调怪兽。
function c20050865.scfilter1(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在至少1只可以用该怪兽和这张卡作为素材进行同调召唤的机械族同调怪兽。
		and Duel.IsExistingMatchingCard(c20050865.scfilter2,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 额外卡组怪兽过滤：必须是机械族，且能用指定素材组进行同调召唤。
function c20050865.scfilter2(c,mg)
	return c:IsRace(RACE_MACHINE) and c:IsSynchroSummonable(nil,mg)
end
-- 目标选择函数：检查可发动性，并让玩家从自己墓地选择1只调整以外且满足条件的目标怪兽，同时设置特殊召唤的操作信息。
function c20050865.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20050865.scfilter1(chkc,e,tp,e:GetHandler()) end
	-- 检查玩家本回合剩余可特殊召唤次数是否足够（本效果需要特殊召唤对象怪兽和同调怪兽，共2次）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查自己场上是否还有可用的主要怪兽区域空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足选择条件的目标怪兽。
		and Duel.IsExistingTarget(c20050865.scfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler()) end
	-- 向玩家发送“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的怪兽作为效果对象，并将其设为该连锁的对象。
	local g=Duel.SelectTarget(tp,c20050865.scfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetHandler())
	-- 设置效果处理信息：本次操作将进行特殊召唤，目标为已选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：先特殊召唤对象怪兽并使其效果无效，若本卡和对象怪兽仍在场上，则从额外卡组选择1只机械族同调怪兽，以二者为素材进行同调召唤，且这些素材不去墓地而是除外。
function c20050865.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区有空位，否则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与本效果关联且可特殊召唤，若可则执行特殊召唤步骤（以表侧表示特殊召唤）。
	if not tc:IsRelateToEffect(e) or not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then return end
	-- 那只怪兽效果无效特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	tc:RegisterEffect(e2)
	-- 完成特殊召唤步骤，正式处理所有已进行的特殊召唤。
	Duel.SpecialSummonComplete()
	if not c:IsRelateToEffect(e) then return end
	-- 刷新场地信息，确保后续的素材检查和同调召唤判定基于最新状态。
	Duel.AdjustAll()
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取额外卡组中所有以这张卡和对象怪兽为素材可同调召唤的机械族同调怪兽。
	local g=Duel.GetMatchingGroup(c20050865.scfilter2,tp,LOCATION_EXTRA,0,nil,mg)
	if g:GetCount()>0 then
		-- 向玩家发送“请选择要特殊召唤的卡”的提示消息（选择同调召唤的额外怪兽）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 只用那只怪兽和这张卡为素材把1只机械族同调怪兽同调召唤。那个时候的同调素材怪兽不去墓地而除外。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
		local e2=e1:Clone()
		tc:RegisterEffect(e2,true)
		-- 以这张卡和对象怪兽为素材，执行机械族同调怪兽的同调召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
