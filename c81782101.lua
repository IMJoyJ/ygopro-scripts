--レプティア・エッグ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡不会被战斗破坏。
-- ②：这张卡召唤成功的场合，下次的自己回合的准备阶段，把这张卡解放才能发动。从手卡·卡组把最多3只4星以下的爬虫类族·岩石族怪兽特殊召唤（2只以上特殊召唤的场合必须全部是同名怪兽）。这个效果特殊召唤的怪兽在结束阶段除外。
function c81782101.initial_effect(c)
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤成功的场合，下次的自己回合的准备阶段，把这张卡解放才能发动。从手卡·卡组把最多3只4星以下的爬虫类族·岩石族怪兽特殊召唤（2只以上特殊召唤的场合必须全部是同名怪兽）。这个效果特殊召唤的怪兽在结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c81782101.regop)
	c:RegisterEffect(e2)
end
-- 召唤成功时，注册一个在下次自己回合准备阶段可以发动的效果
function c81782101.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 下次的自己回合的准备阶段，把这张卡解放才能发动。从手卡·卡组把最多3只4星以下的爬虫类族·岩石族怪兽特殊召唤（2只以上特殊召唤的场合必须全部是同名怪兽）。这个效果特殊召唤的怪兽在结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81782101,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,81782101)
	e1:SetCondition(c81782101.spcon)
	e1:SetCost(c81782101.spcost)
	e1:SetTarget(c81782101.sptg)
	e1:SetOperation(c81782101.spop)
	-- 将当前回合数作为标签记录，用于后续判断是否为‘下次的自己回合’
	e1:SetLabel(Duel.GetTurnCount())
	-- 判断当前是否为自己的回合
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
	end
	c:RegisterEffect(e1)
end
-- 判断是否为自己回合的准备阶段，且不是召唤成功的那一个回合
function c81782101.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 必须是自己的回合，且回合数不等于召唤成功时的回合数（即必须是下次以后的自己回合）
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetLabel()
end
-- 发动代价：解放这张卡
function c81782101.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：手卡·卡组中4星以下的爬虫类族·岩石族怪兽
function c81782101.filter(c,e,tp)
	return c:IsRace(RACE_REPTILE+RACE_ROCK) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与合法性检测
function c81782101.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在解放自身后，检测自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 且手卡·卡组中存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c81782101.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡·卡组特殊召唤至少1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 检测选中的怪兽组是否全部为同名怪兽（用于2只以上特殊召唤的限制）
function c81782101.spcheck(g)
	return g:GetClassCount(Card.GetCode)==1
end
-- 特殊召唤效果的实际处理，并注册结束阶段除外的效果
function c81782101.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>3 then ft=3 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取手卡·卡组中所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(c81782101.filter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local hg=g:SelectSubGroup(tp,c81782101.spcheck,false,1,ft)
		local fid=e:GetHandler():GetFieldID()
		local tc=hg:GetFirst()
		while tc do
			-- 将选中的怪兽以表侧表示逐一进行特殊召唤的准备步骤
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(81782101,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tc=hg:GetNext()
		end
		-- 完成所有怪兽的特殊召唤
		Duel.SpecialSummonComplete()
		hg:KeepAlive()
		-- 这个效果特殊召唤的怪兽在结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(hg)
		e1:SetCondition(c81782101.rmcon)
		e1:SetOperation(c81782101.rmop)
		-- 注册在结束阶段将特殊召唤的怪兽除外的全局效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤出带有本次特殊召唤标记（fid）的怪兽
function c81782101.rmfilter(c,fid)
	return c:GetFlagEffectLabel(81782101)==fid
end
-- 除外效果的发动条件：检查场上是否还存在带有本次特殊召唤标记的怪兽，若不存在则清理并重置效果
function c81782101.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c81782101.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 除外效果的实际处理：将带有标记的怪兽全部表侧表示除外
function c81782101.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c81782101.rmfilter,nil,e:GetLabel())
	-- 因效果将目标怪兽表侧表示除外
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
