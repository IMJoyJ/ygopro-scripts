--水晶機巧－リオン
-- 效果：
-- 「水晶机巧-胶子黑晶」的效果1回合只能使用1次。
-- ①：对方的主要阶段以及战斗阶段，以调整以外的除外的1只自己怪兽为对象才能发动。那只怪兽效果无效特殊召唤，只用那只怪兽和这张卡为素材把1只机械族同调怪兽同调召唤。那个时候的同调素材怪兽不去墓地回到持有者卡组。
function c66938505.initial_effect(c)
	-- ①：对方的主要阶段以及战斗阶段，以调整以外的除外的1只自己怪兽为对象才能发动。那只怪兽效果无效特殊召唤，只用那只怪兽和这张卡为素材把1只机械族同调怪兽同调召唤。那个时候的同调素材怪兽不去墓地回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66938505,0))  --"除外特殊召唤并加速同调"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,66938505)
	e1:SetCondition(c66938505.sccon)
	e1:SetTarget(c66938505.sctg)
	e1:SetOperation(c66938505.scop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：对方的主要阶段以及战斗阶段，且自身不在连锁中
function c66938505.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 检查自身不在连锁中，且当前不是自己的回合
	return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetTurnPlayer()~=tp
		and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end
-- 过滤条件1：除外的非调整怪兽，且能特殊召唤，并且能与自身作为素材同调召唤额外卡组的机械族同调怪兽
function c66938505.scfilter1(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在可以使用这些素材进行同调召唤的怪兽
		and Duel.IsExistingMatchingCard(c66938505.scfilter2,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 过滤条件2：额外卡组的机械族怪兽，且可以使用指定的素材进行同调召唤
function c66938505.scfilter2(c,mg)
	return c:IsRace(RACE_MACHINE) and c:IsSynchroSummonable(nil,mg)
end
-- 效果发动阶段的目标选择与合法性检查
function c66938505.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c66938505.scfilter1(chkc,e,tp,e:GetHandler()) end
	-- 检查玩家是否能进行至少2次特殊召唤（特殊召唤素材怪兽 + 同调召唤）
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在满足条件的自己怪兽作为对象
		and Duel.IsExistingTarget(c66938505.scfilter1,tp,LOCATION_REMOVED,0,1,nil,e,tp,e:GetHandler()) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外的1只自己怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c66938505.scfilter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,e:GetHandler())
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤对象怪兽并进行同调召唤
function c66938505.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果对象怪兽仍符合条件，则将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽效果无效特殊召唤
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的处理，若没有怪兽被成功特殊召唤则结束处理
	if Duel.SpecialSummonComplete()==0 then return end
	if not c:IsRelateToEffect(e) then return end
	-- 立即刷新场上卡片状态信息
	Duel.AdjustAll()
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取额外卡组中可以使用当前素材进行同调召唤的机械族怪兽
	local g=Duel.GetMatchingGroup(c66938505.scfilter2,tp,LOCATION_EXTRA,0,nil,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要同调召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 只用那只怪兽和这张卡为素材把1只机械族同调怪兽同调召唤。那个时候的同调素材怪兽不去墓地回到持有者卡组。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_DECKSHF)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
		local e2=e1:Clone()
		tc:RegisterEffect(e2,true)
		-- 使用指定的素材进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
