--プチトマボー
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把最多2只名字带有「番茄小子」的怪兽特殊召唤。这个效果特殊召唤的怪兽这个回合不能作为同调素材。
function c525110.initial_effect(c)
	-- 诱发选发效果，当此卡被战斗破坏送去墓地时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(525110,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c525110.condition)
	e1:SetTarget(c525110.target)
	e1:SetOperation(c525110.operation)
	c:RegisterEffect(e1)
end
-- 满足此卡在墓地且因战斗破坏的条件
function c525110.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤名字带有「番茄小子」且可以特殊召唤的怪兽
function c525110.filter(c,e,tp)
	return c:IsSetCard(0x5b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的条件
function c525110.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c525110.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理特殊召唤效果
function c525110.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>=2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c525110.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		local t1=g:GetFirst()
		local t2=g:GetNext()
		-- 将第一只选中的怪兽特殊召唤
		Duel.SpecialSummonStep(t1,0,tp,tp,false,false,POS_FACEUP)
		-- 效果原文：这个效果特殊召唤的怪兽这个回合不能作为同调素材
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		t1:RegisterEffect(e1)
		if t2 then
			-- 将第二只选中的怪兽特殊召唤
			Duel.SpecialSummonStep(t2,0,tp,tp,false,false,POS_FACEUP)
			local e2=e1:Clone()
			t2:RegisterEffect(e2)
		end
		-- 完成所有特殊召唤步骤
		Duel.SpecialSummonComplete()
	end
end
