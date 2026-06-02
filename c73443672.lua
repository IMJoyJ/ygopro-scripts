--黄泉天輪
-- 效果：
-- 这个卡名的卡在决斗中只能发动1张。
-- ①：双方墓地的怪兽各自是5只以上的场合才能把这张卡发动。场上的怪兽全部破坏。那之后，双方把自身卡组的怪兽全部里侧除外。并且再让自己可以从自身墓地把1只通常怪兽特殊召唤。
-- ②：自己·对方的准备阶段发动。双方各自可以从自身墓地把1只怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化卡片效果：注册效果①（卡片发动时的破坏、除外与特召效果）与效果②（准备阶段双方特召效果）
function s.initial_effect(c)
	-- 这个卡名的卡在决斗中只能发动1张。①：双方墓地的怪兽各自是5只以上的场合才能把这张卡发动。场上的怪兽全部破坏。那之后，双方把自身卡组的怪兽全部里侧除外。并且再让自己可以从自身墓地把1只通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己·对方的准备阶段发动。双方各自可以从自身墓地把1只怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①发动的条件：双方墓地的怪兽各自在5只以上
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己和对方的墓地是否均存在5只以上的怪兽
	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)>=5 and Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_GRAVE,nil,TYPE_MONSTER)>=5
end
-- 过滤条件：可以里侧表示除外的怪兽
function s.rmfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN) and c:IsType(TYPE_MONSTER)
end
-- 效果①发动的阻抗/可行性检查及操作信息注册
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组是否存在可以被里侧除外的怪兽卡
	local rm1=Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil,tp)
	-- 检查对方是否可以被除外卡片，且对方卡组中存在卡片
	local rm2=Duel.IsPlayerCanRemove(1-tp) and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
	-- 效果发动时的可行性检查：场上是否存在怪兽，且双方卡组有可以被除外的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and (rm1 or rm2) end
	-- 获取场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：破坏场上的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	-- 设置操作信息：将双方卡组的卡片除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,PLAYER_ALL,LOCATION_DECK)
end
-- 过滤条件：可以特殊召唤的通常怪兽
function s.spfilter1(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的实际效果处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前回合的玩家
	local p1=Duel.GetTurnPlayer()
	-- 获取当前回合玩家的对手
	local p2=1-Duel.GetTurnPlayer()
	-- 获取场上的所有怪兽
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 如果成功破坏了场上的怪兽
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 中断效果处理，以便进行那之后的处理
		Duel.BreakEffect()
		-- 获取当前回合玩家卡组的全部怪兽
		local g1=Duel.GetMatchingGroup(Card.IsType,p1,LOCATION_DECK,0,nil,TYPE_MONSTER)
		-- 获取回合玩家对手卡组的全部怪兽
		local g2=Duel.GetMatchingGroup(Card.IsType,p2,LOCATION_DECK,0,nil,TYPE_MONSTER)
		-- 当前回合玩家将自身卡组的怪兽全部里侧除外，并判断是否除外成功
		local b1=#g1>0 and Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT,p1)>0
		-- 回合玩家的对手将自身卡组的怪兽全部里侧除外，并判断是否除外成功
		local b2=#g2>0 and Duel.Remove(g2,POS_FACEDOWN,REASON_EFFECT,p2)>0
		-- 如果至少有一方成功除外了卡片，且当前回合玩家场上有可用的怪兽区域
		if (b1 or b2) and Duel.GetLocationCount(p1,LOCATION_MZONE)>0
			-- 且当前回合玩家墓地存在不受「王家长眠之谷」影响且可特殊召唤的通常怪兽
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter1),p1,LOCATION_GRAVE,0,1,nil,e,p1)
			-- 并询问当前回合玩家是否特殊召唤
			and Duel.SelectYesNo(p1,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 提示回合玩家选择特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,p1,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 回合玩家选择自身墓地中不受「王家长眠之谷」影响且可特殊召唤的1只通常怪兽
			local sg1=Duel.SelectMatchingCard(p1,aux.NecroValleyFilter(s.spfilter1),p1,LOCATION_GRAVE,0,1,1,nil,e,p1)
			-- 对选中的怪兽显示被选择的效果动画
			Duel.HintSelection(sg1)
			local sc=sg1:GetFirst()
			-- 中断效果处理，以便进行特殊召唤
			Duel.BreakEffect()
			-- 将选中的通常怪兽表侧表示特殊召唤到回合玩家的场上
			Duel.SpecialSummon(sc,0,p1,p1,false,false,POS_FACEUP)
		end
	end
end
-- 过滤条件：可以无视召唤条件特殊召唤的怪兽
function s.spfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:IsType(TYPE_MONSTER)
end
-- 效果②发动的可行性检查与操作信息注册
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从双方墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果②的实际效果处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前回合的玩家
	local p1=Duel.GetTurnPlayer()
	-- 获取当前回合玩家的对手
	local p2=1-Duel.GetTurnPlayer()
	local tc1=nil
	local tc2=nil
	-- 如果当前回合玩家场上有可用的怪兽区域
	if Duel.GetLocationCount(p1,LOCATION_MZONE)>0
		-- 且当前回合玩家墓地存在不受「王家长眠之谷」影响且可无视召唤条件特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter2),p1,LOCATION_GRAVE,0,1,nil,e,p1)
		-- 并询问当前回合玩家是否从墓地无视召唤条件特殊召唤怪兽
		and Duel.SelectYesNo(p1,aux.Stringid(id,3)) then  --"是否无视召唤条件特殊召唤？"
		-- 提示当前回合玩家选择特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,p1,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 当前回合玩家选择自身墓地中不受「王家长眠之谷」影响且可无视召唤条件特殊召唤的1只怪兽
		local sg1=Duel.SelectMatchingCard(p1,aux.NecroValleyFilter(s.spfilter2),p1,LOCATION_GRAVE,0,1,1,nil,e,p1)
		-- 对回合玩家选中的怪兽显示被选择的效果动画
		Duel.HintSelection(sg1)
		tc1=sg1:GetFirst()
	end
	-- 如果回合玩家的对手场上有可用的怪兽区域
	if Duel.GetLocationCount(p2,LOCATION_MZONE)>0
		-- 且回合玩家对手的墓地存在不受「王家长眠之谷」影响且可无视召唤条件特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter2),p2,LOCATION_GRAVE,0,1,nil,e,p2)
		-- 并询问回合玩家的对手是否从墓地无视召唤条件特殊召唤怪兽
		and Duel.SelectYesNo(p2,aux.Stringid(id,3)) then  --"是否无视召唤条件特殊召唤？"
		-- 提示回合玩家的对手选择特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,p2,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 回合玩家的对手选择自身墓地中不受「王家长眠之谷」影响且可无视召唤条件特殊召唤的1只怪兽
		local sg2=Duel.SelectMatchingCard(p2,aux.NecroValleyFilter(s.spfilter2),p2,LOCATION_GRAVE,0,1,1,nil,e,p2)
		-- 对对手选中的怪兽显示被选择的效果动画
		Duel.HintSelection(sg2)
		tc2=sg2:GetFirst()
	end
	if tc1 then
		-- 如果成功将回合玩家选择的怪兽无视召唤条件表侧表示特殊召唤
		if Duel.SpecialSummonStep(tc1,0,p1,p1,true,false,POS_FACEUP) then
			tc1:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))  --"「黄泉天轮」的效果特殊召唤"
			-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			tc1:RegisterEffect(e1,true)
		end
	end
	if tc2 then
		-- 如果成功将回合玩家对手选择的怪兽无视召唤条件表侧表示特殊召唤
		if Duel.SpecialSummonStep(tc2,0,p2,p2,true,false,POS_FACEUP) then
			tc2:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))  --"「黄泉天轮」的效果特殊召唤"
			-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			tc2:RegisterEffect(e1,true)
		end
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
end
