--驀進装甲ライノセイバー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡任意数量丢弃才能发动。这张卡的攻击力上升丢弃数量×700。
-- ②：这张卡进行战斗的战斗阶段结束时，把这张卡送去墓地才能发动。等级合计直到变成7星为止，从自己墓地选「蓦进装甲 剑角犀牛」以外的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c82197831.initial_effect(c)
	-- 为这张卡添加同调召唤手续（调整＋调整以外的怪兽1只以上）
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：把手卡任意数量丢弃才能发动。这张卡的攻击力上升丢弃数量×700。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82197831,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,82197831)
	e1:SetCost(c82197831.atkcost)
	e1:SetOperation(c82197831.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的战斗阶段结束时，把这张卡送去墓地才能发动。等级合计直到变成7星为止，从自己墓地选「蓦进装甲 剑角犀牛」以外的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82197831,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,82197832)
	e2:SetCondition(c82197831.spcon)
	e2:SetCost(c82197831.spcost)
	e2:SetTarget(c82197831.sptg)
	e2:SetOperation(c82197831.spop)
	c:RegisterEffect(e2)
end
-- ①号效果的Cost（丢弃手卡）判定与执行函数
function c82197831.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃任意数量的手卡，并返回实际丢弃的数量
	local ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,60,REASON_COST+REASON_DISCARD)
	e:SetLabel(ct)
end
-- ①号效果的处理函数（增加攻击力）
function c82197831.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=e:GetLabel()*700
		-- 这张卡的攻击力上升丢弃数量×700。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ②号效果的发动条件判定（这张卡进行了战斗）
function c82197831.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- ②号效果的Cost（送去墓地）判定与执行函数
function c82197831.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将这张卡作为发动代价送去墓地
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤墓地中可以特殊召唤、等级在1星以上且卡名非「蓦进装甲 剑角犀牛」的怪兽
function c82197831.spfilter(c,e,tp)
	return not c:IsCode(82197831) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelAbove(1)
end
-- 辅助选择函数：检查选中的怪兽等级合计是否不超过7
function c82197831.gcheck(sg)
	return sg:GetSum(Card.GetLevel)<=7
end
-- 辅助选择函数：检查选中的怪兽等级合计是否刚好等于7，且数量不超过可用怪兽区域数
function c82197831.fselect(g,tp,c)
	-- 检查选中的怪兽等级合计是否刚好等于7，且数量不超过可用怪兽区域数
	return g:CheckWithSumEqual(Card.GetLevel,7,g:GetCount(),g:GetCount()) and Duel.GetMZoneCount(tp,c)>=g:GetCount()
end
-- ②号效果的发动准备与合法性检测（Target函数）
function c82197831.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中满足特殊召唤条件的怪兽组
	local g=Duel.GetMatchingGroup(c82197831.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 计算当前可用于特殊召唤的最大怪兽区域数量
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),g:GetCount())
	if chk==0 then
		if ft<=0 then return false end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 设置附加的组检查函数，限制选择的怪兽等级合计不超过7
		aux.GCheckAdditional=c82197831.gcheck
		local res=g:CheckSubGroup(c82197831.fselect,1,ft,tp,e:GetHandler())
		-- 重置附加的组检查函数
		aux.GCheckAdditional=nil
		return res
	end
	-- 设置连锁信息，表明此效果包含从墓地特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②号效果的处理函数（特殊召唤并无效化效果）
function c82197831.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中满足特殊召唤条件且不受「王家之谷」影响的怪兽组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c82197831.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 计算当前可用于特殊召唤的最大怪兽区域数量
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),g:GetCount())
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 设置附加的组检查函数，限制选择的怪兽等级合计不超过7
	aux.GCheckAdditional=c82197831.gcheck
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c82197831.fselect,false,1,ft,tp,nil)
	-- 重置附加的组检查函数
	aux.GCheckAdditional=nil
	if sg then
		local tc=sg:GetFirst()
		while tc do
			-- 逐步将选中的怪兽以表侧表示特殊召唤
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
			tc=sg:GetNext()
		end
		-- 完成所有怪兽的特殊召唤处理
		Duel.SpecialSummonComplete()
	end
end
