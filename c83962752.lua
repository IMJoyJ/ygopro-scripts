--シンクロ・パニック
-- 效果：
-- 这张卡发动后，第3次的自己准备阶段破坏。
-- ①：自己场上的表侧表示的同调怪兽被战斗或者对方的效果破坏的场合，以那之内的1只为对象才能把这张卡发动。等级合计直到变成和那只怪兽相同为止，从自己墓地把调整1只和调整以外的怪兽任意数量特殊召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗·效果破坏。
-- ②：只要这张卡在魔法与陷阱区域存在，双方不能同调召唤。
function c83962752.initial_effect(c)
	-- ①：自己场上的表侧表示的同调怪兽被战斗或者对方的效果破坏的场合，以那之内的1只为对象才能把这张卡发动。等级合计直到变成和那只怪兽相同为止，从自己墓地把调整1只和调整以外的怪兽任意数量特殊召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83962752,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c83962752.condition)
	e1:SetTarget(c83962752.target)
	e1:SetOperation(c83962752.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，双方不能同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c83962752.splimit)
	c:RegisterEffect(e2)
end
-- 过滤墓地中可以特殊召唤且等级在1以上的怪兽
function c83962752.spcfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelAbove(1)
end
-- 过滤自己场上因战斗或对方效果被破坏的表侧表示同调怪兽
function c83962752.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_SYNCHRO)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 检查选取的怪兽组中是否仅有1只调整怪兽，且等级合计等于被破坏的同调怪兽的等级
function c83962752.gcheck(g,tp,ec)
	return g:FilterCount(Card.IsType,nil,TYPE_TUNER)==1 and g:GetSum(Card.GetLevel)==ec:GetLevel()
end
-- 过滤可以作为效果对象、且墓地存在满足特殊召唤条件的怪兽组合的被破坏同调怪兽
function c83962752.tgfilter(c,e,tp,ct)
	-- 获取自己墓地中所有满足特殊召唤条件的怪兽
	local g=Duel.GetMatchingGroup(c83962752.spcfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsLevelAbove(1) and g:CheckSubGroup(c83962752.gcheck,2,ct,tp,c)
end
-- 检查被破坏的卡中是否存在满足条件的自己场上的同调怪兽
function c83962752.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c83962752.cfilter,1,nil,tp)
end
-- 效果发动的对象选择与准备阶段自毁效果的注册
function c83962752.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己场上可用的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local mg=eg:Filter(c83962752.cfilter,nil,tp):Filter(c83962752.tgfilter,nil,e,tp,ct)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return mg:GetCount()>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	local g=mg
	if mg:GetCount()>1 then
		-- 提示玩家选择作为效果对象的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=mg:Select(tp,1,1,nil)
	end
	-- 将选择的卡片设置为当前连锁的效果对象
	Duel.SetTargetCard(g)
	-- 设置特殊召唤的操作信息（预计从墓地特殊召唤至少2只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
	-- 这张卡发动后，第3次的自己准备阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c83962752.descon)
	e1:SetOperation(c83962752.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,3)
	c:SetTurnCounter(0)
	c:RegisterEffect(e1)
end
-- 效果处理：从墓地特殊召唤调整和非调整怪兽，并赋予它们在这个回合不会被战斗·效果破坏的抗性
function c83962752.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象（被破坏的同调怪兽）
	local tc=Duel.GetFirstTarget()
	-- 获取自己场上可用的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取自己墓地中所有满足特殊召唤条件的怪兽
	local g=Duel.GetMatchingGroup(c83962752.spcfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 如果自己场上的可用怪兽区域少于2个，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if tc:IsRelateToEffect(e) and g:CheckSubGroup(c83962752.gcheck,2,ct,tp,tc) then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroup(tp,c83962752.gcheck,false,2,ct,tp,tc)
		local sc=sg:GetFirst()
		while sc do
			-- 将选中的怪兽以表侧表示逐步特殊召唤到场上
			Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
			-- 这个效果特殊召唤的怪兽在这个回合不会被战斗·效果破坏。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(83962752,1))  --"「同调恐慌」的效果特殊召唤"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			sc:RegisterEffect(e2)
			sc=sg:GetNext()
		end
		-- 完成所有怪兽的特殊召唤处理
		Duel.SpecialSummonComplete()
	end
end
-- 检查当前是否为自己的回合
function c83962752.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 累加回合计数器，并在第3次自己准备阶段时将这张卡破坏
function c83962752.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		-- 因规则（效果要求）破坏这张卡
		Duel.Destroy(c,REASON_RULE)
	end
end
-- 限制双方不能进行同调召唤
function c83962752.splimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO
end
