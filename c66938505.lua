--水晶機巧－リオン
-- 效果：
-- 「水晶机巧-胶子黑晶」的效果1回合只能使用1次。
-- ①：对方的主要阶段以及战斗阶段，以调整以外的除外的1只自己怪兽为对象才能发动。那只怪兽效果无效特殊召唤，只用那只怪兽和这张卡为素材把1只机械族同调怪兽同调召唤。那个时候的同调素材怪兽不去墓地回到持有者卡组。
function c66938505.initial_effect(c)
	-- 「水晶机巧-胶子黑晶」的效果1回合只能使用1次。①：对方的主要阶段以及战斗阶段，以调整以外的除外的1只自己怪兽为对象才能发动。那只怪兽效果无效特殊召唤，只用那只怪兽和这张卡为素材把1只机械族同调怪兽同调召唤。那个时候的同调素材怪兽不去墓地回到持有者卡组。
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
-- 效果①发动条件：对方的主要阶段或战斗阶段中自身不在连锁串中
function c66938505.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断自身是否不在连锁串中且当前回合玩家为对方
	return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetTurnPlayer()~=tp
		and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end
-- 过滤条件：表侧表示且非调整、能被特殊召唤且能与这张卡作为同调素材的怪兽
function c66938505.scfilter1(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return c:IsFaceup() and not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在可以以这两张卡为素材同调召唤的机械族同调怪兽
		and Duel.IsExistingMatchingCard(c66938505.scfilter2,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 过滤条件：机械族且能以指定卡片组为素材同调召唤的怪兽
function c66938505.scfilter2(c,mg)
	return c:IsRace(RACE_MACHINE) and c:IsSynchroSummonable(nil,mg)
end
-- 效果①目标选择及发动条件：以调整以外的除外的1只自己怪兽为对象
function c66938505.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c66938505.scfilter1(chkc,e,tp,e:GetHandler()) end
	-- 判断自己是否能进行至少2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 判断自己场上是否有可用的主要怪兽区空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己除外区是否存在满足条件的怪兽作为对象
		and Duel.IsExistingTarget(c66938505.scfilter1,tp,LOCATION_REMOVED,0,1,nil,e,tp,e:GetHandler()) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己除外的1只调整以外的怪兽作为对象
	local g=Duel.SelectTarget(tp,c66938505.scfilter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,e:GetHandler())
	-- 设置操作信息：将选中的对象怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①处理：特殊召唤对象怪兽并进行机械族同调召唤，素材回到持有者卡组
function c66938505.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否与效果有联系，并执行特殊召唤的第一步
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
	-- 完成特殊召唤流程，若无卡片特殊召唤成功则中断处理
	if Duel.SpecialSummonComplete()==0 then return end
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 立刻刷新场地信息
	Duel.AdjustAll()
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取额外卡组中能以这两只怪兽为素材同调召唤的机械族同调怪兽
	local g=Duel.GetMatchingGroup(c66938505.scfilter2,tp,LOCATION_EXTRA,0,nil,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的同调怪兽
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
		-- 以这2只怪兽为素材进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
