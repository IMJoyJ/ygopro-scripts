--超こいこい
-- 效果：
-- 「超来来」在1回合只能发动1张。
-- ①：从自己卡组上面把3张卡翻开，那之中的「花札卫」怪兽尽可能无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的等级变成2星，效果无效化。剩下的卡全部里侧表示除外，自己失去除外的卡数量×1000基本分。
-- ②：把墓地的这张卡除外，把自己场上1只怪兽解放才能发动。从手卡把1只「花札卫」怪兽无视召唤条件特殊召唤。
function c66171432.initial_effect(c)
	-- ①：从自己卡组上面把3张卡翻开，那之中的「花札卫」怪兽尽可能无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的等级变成2星，效果无效化。剩下的卡全部里侧表示除外，自己失去除外的卡数量×1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66171432,0))  --"卡组特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
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
-- 过滤函数：过滤出属于「花札卫」且可以特殊召唤的怪兽
function c66171432.filter(c,e,tp)
	return c:IsSetCard(0xe6) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ①号效果的发动准备与合法性检测
function c66171432.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能除外卡片
	if chk==0 then return Duel.IsPlayerCanRemove(tp)
		-- 检查玩家是否能进行特殊召唤
		and Duel.IsPlayerCanSpecialSummon(tp)
		-- 检查玩家场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否受到无法里侧表示除外卡片的效果影响
		and not Duel.IsPlayerAffectedByEffect(tp,63060238)
		-- 检查自己卡组的卡片数量是否大于2张
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
-- ①号效果的执行处理
function c66171432.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若玩家此时无法除外卡片，则不处理效果
	if not Duel.IsPlayerCanRemove(tp) then return end
	-- 确认自己卡组最上方的3张卡
	Duel.ConfirmDecktop(tp,3)
	-- 获取自己卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	local sg=g:Filter(c66171432.filter,nil,e,tp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if g:GetCount()>0 then
		-- 使接下来的卡组操作不触发系统自动洗牌检测
		Duel.DisableShuffleCheck()
		if sg:GetCount()>0 and ft>0 then
			if sg:GetCount()>ft then
				-- 提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				sg=sg:Select(tp,ft,ft,nil)
			end
			g:Sub(sg)
			local tc=sg:GetFirst()
			while tc do
				-- 尝试无视召唤条件以表侧表示特殊召唤该怪兽
				if Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
					if tc:GetLevel()>0 then
						-- 这个效果特殊召唤的怪兽的等级变成2星
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_CHANGE_LEVEL)
						e1:SetValue(2)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e1)
					end
					-- 效果无效化
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_DISABLE)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e2)
					-- 效果无效化
					local e3=Effect.CreateEffect(c)
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetCode(EFFECT_DISABLE_EFFECT)
					e3:SetValue(RESET_TURN_SET)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e3)
				end
				tc=sg:GetNext()
			end
			-- 完成所有怪兽的特殊召唤处理
			Duel.SpecialSummonComplete()
		end
		-- 将剩下的卡全部里侧表示除外
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		-- 获取实际被操作（除外）的卡片组
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
		if ct>0 then
			-- 自己失去除外的卡数量×1000基本分
			Duel.SetLP(tp,Duel.GetLP(tp)-ct*1000)
		end
	end
end
-- ②号效果的发动代价（Cost）检测与处理
function c66171432.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自己场上是否存在至少1只可解放的怪兽
		and Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 将墓地的这张卡除外作为发动代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 选择自己场上1只怪兽
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 解放选择的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- ②号效果的发动准备与合法性检测
function c66171432.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查解放怪兽后，自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡中是否存在可特殊召唤的「花札卫」怪兽
		and Duel.IsExistingMatchingCard(c66171432.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤操作的连锁信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②号效果的执行处理
function c66171432.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足条件的「花札卫」怪兽
	local g=Duel.SelectMatchingCard(tp,c66171432.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 无视召唤条件将选择的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
