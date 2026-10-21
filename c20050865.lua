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
-- 效果①的发动条件：对方主要阶段或战斗阶段且自身不在连锁串中
function c20050865.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前所处的回合阶段
	local ph=Duel.GetCurrentPhase()
	-- 检查自身不在连锁串中且当前为对方回合
	return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetTurnPlayer()~=tp
		and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end
-- 墓地目标怪兽过滤条件：非调整、能特殊召唤且能与自身同调召唤额外卡组的机械族怪兽
function c20050865.scfilter1(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认额外卡组存在以选取的两只怪兽为素材可同调召唤的机械族同调怪兽
		and Duel.IsExistingMatchingCard(c20050865.scfilter2,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 额外卡组同调怪兽过滤条件：机械族且能以指定素材进行同调召唤
function c20050865.scfilter2(c,mg)
	return c:IsRace(RACE_MACHINE) and c:IsSynchroSummonable(nil,mg)
end
-- 效果①的发动目标选择与合法性检测
function c20050865.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20050865.scfilter1(chkc,e,tp,e:GetHandler()) end
	-- 检查发动玩家本回合是否还能进行至少2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在可作为对象的合法怪兽
		and Duel.IsExistingTarget(c20050865.scfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler()) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只非调整怪兽作为对象
	local g=Duel.SelectTarget(tp,c20050865.scfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetHandler())
	-- 设置操作信息：特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理：特殊召唤目标怪兽并效果无效，以自身和目标怪兽为素材进行机械族同调召唤，素材除外
function c20050865.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取选中的墓地目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍在墓地则将其表侧表示特殊召唤
	if not tc:IsRelateToEffect(e) or not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then return end
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
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 刷新场地信息
	Duel.AdjustAll()
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取额外卡组中可由这两只怪兽同调召唤的机械族怪兽组
	local g=Duel.GetMatchingGroup(c20050865.scfilter2,tp,LOCATION_EXTRA,0,nil,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
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
		-- 以自身和目标怪兽为素材进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
