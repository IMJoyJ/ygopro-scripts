--超こいこい
-- 效果：
-- 「超来来」在1回合只能发动1张。
-- ①：从自己卡组上面把3张卡翻开，那之中的「花札卫」怪兽尽可能无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的等级变成2星，效果无效化。剩下的卡全部里侧表示除外，自己失去除外的卡数量×1000基本分。
-- ②：把墓地的这张卡除外，把自己场上1只怪兽解放才能发动。从手卡把1只「花札卫」怪兽无视召唤条件特殊召唤。
function c66171432.initial_effect(c)
	-- 「超来来」在1回合只能发动1张。 ①：从自己卡组上面把3张卡翻开，那之中的「花札卫」怪兽尽可能无视召唤条件特殊召唤。剩下的卡全部里侧表示除外，自己失去除外的卡数量×1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66171432,0))  --"卡组特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,66171432+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c66171432.target)
	e1:SetOperation(c66171432.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，把自己场上1只怪兽解放才能发动。从手卡把1只「花札卫」怪兽无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66171432,1))  --"手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c66171432.spcost)
	e2:SetTarget(c66171432.sptg)
	e2:SetOperation(c66171432.spop)
	c:RegisterEffect(e2)
end
-- 筛选条件：检查卡片是否为可无视召唤条件特殊召唤的「花札卫」怪兽
function c66171432.filter(c,e,tp)
	return c:IsSetCard(0xe6) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ①效果的发动检测：确认己方可执行除外与特殊召唤、怪兽区有空位、未受特定限制效果影响且卡组至少有3张卡
function c66171432.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认己方玩家可以执行除外卡片的操作
	if chk==0 then return Duel.IsPlayerCanRemove(tp)
		-- 确认己方玩家可以执行特殊召唤操作
		and Duel.IsPlayerCanSpecialSummon(tp)
		-- 确认己方主要怪兽区存在可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方玩家未受到卡号63060238（引用表为元素英雄 烈焰侠，此处作为特殊召唤限制标识）的效果影响
		and not Duel.IsPlayerAffectedByEffect(tp,63060238)
		-- 确认己方卡组剩余卡片不少于3张
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
-- ①效果的处理流程：翻开己方卡组顶3张卡，尽可能无视召唤条件特召其中的「花札卫」怪兽并使其变为2星且效果无效，将余卡里侧除外并按除外张数×1000失去基本分
function c66171432.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认己方可执行除外操作，否则终止处理
	if not Duel.IsPlayerCanRemove(tp) then return end
	-- 从己方卡组最上方翻开3张卡并向双方公开确认
	Duel.ConfirmDecktop(tp,3)
	-- 获取己方卡组最上方被翻开的3张卡片组
	local g=Duel.GetDecktopGroup(tp,3)
	local sg=g:Filter(c66171432.filter,nil,e,tp)
	-- 获取己方主要怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if g:GetCount()>0 then
		-- 禁用下一次操作后的卡组洗切检测，避免中途触发洗卡
		Duel.DisableShuffleCheck()
		if sg:GetCount()>0 and ft>0 then
			if sg:GetCount()>ft then
				-- 当可特召怪兽数多于空位时，向己方提示选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				sg=sg:Select(tp,ft,ft,nil)
			end
			g:Sub(sg)
			local tc=sg:GetFirst()
			while tc do
				-- 执行分步特殊召唤，将当前「花札卫」怪兽以表侧表示、无视召唤条件特殊召唤到己方场上
				if Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
					if tc:GetLevel()>0 then
						-- 这个效果特殊召唤的怪兽的等级变成2星，
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_CHANGE_LEVEL)
						e1:SetValue(2)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e1)
					end
					-- 效果无效化。
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_DISABLE)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e2)
					-- 效果无效化。
					local e3=Effect.CreateEffect(c)
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetCode(EFFECT_DISABLE_EFFECT)
					e3:SetValue(RESET_TURN_SET)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e3)
				end
				tc=sg:GetNext()
			end
			-- 完成所有分步特殊召唤并统一触发召唤相关时点
			Duel.SpecialSummonComplete()
		end
		-- 将翻开后剩余的卡全部以效果里侧表示除外
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		-- 获取刚才除外操作中实际被处理的卡片组
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
		if ct>0 then
			-- 使己方基本分减少实际进入除外区的卡片数量×1000的数值
			Duel.SetLP(tp,Duel.GetLP(tp)-ct*1000)
		end
	end
end
-- ②效果的发动代价检查：确认墓地的这张卡可作为代价除外，且己方场上存在至少1只可解放的怪兽
function c66171432.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 确认己方场上存在至少1只可作为解放代价的怪兽
		and Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 作为发动代价把墓地的这张卡表侧除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 让己方从己方场上选择1只怪兽作为解放代价
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 作为发动代价将所选怪兽解放
	Duel.Release(g,REASON_COST)
end
-- ②效果的发动检测：确认解放1只怪兽后己方怪兽区有空位，且手卡存在可特召的「花札卫」怪兽
function c66171432.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查（前半）：确认怪兽区空位数大于-1，即解放己方1只怪兽后至少有1个怪兽区空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 发动条件检查（后半）：确认己方手卡存在可无视召唤条件特殊召唤的「花札卫」怪兽
		and Duel.IsExistingMatchingCard(c66171432.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记连锁的特殊召唤操作信息，预计从己方手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的处理流程：确认己方怪兽区有空位后，从手卡选1只「花札卫」怪兽无视召唤条件特殊召唤
function c66171432.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区是否有空位，若无空位则终止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向己方提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方从己方手卡选择1只「花札卫」怪兽
	local g=Duel.SelectMatchingCard(tp,c66171432.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将所选「花札卫」怪兽以表侧表示、无视召唤条件特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
