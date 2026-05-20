--スピッド・バード
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以选择自己墓地存在的2只2星的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c86174055.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以选择自己墓地存在的2只2星的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86174055,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c86174055.condition)
	e1:SetTarget(c86174055.target)
	e1:SetOperation(c86174055.operation)
	c:RegisterEffect(e1)
end
-- 判定发动条件：此卡因战斗破坏并送去墓地。
function c86174055.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：自己墓地中等级为2且可以特殊召唤的怪兽。
function c86174055.filter(c,e,tp)
	return c:IsLevel(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象选择与可行性检测（包含青眼精灵龙的特召限制判定、怪兽区域空位判定以及墓地是否存在2只符合条件的怪兽）。
function c86174055.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c86174055.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判定自己场上的怪兽区域空位是否在2个以上。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 判定自己墓地是否存在2只满足条件的怪兽。
		and Duel.IsExistingTarget(c86174055.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地2只2星的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c86174055.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置效果处理信息：特殊召唤选中的2张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理：将选中的2只怪兽特殊召唤，并将其效果无效化。
function c86174055.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 获取自己场上可用的怪兽区域空格数量。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if g:GetCount()<=ct then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
		local tc=g:GetFirst()
		while tc do
			-- 将目标怪兽以表侧表示特殊召唤（分步处理）。
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
			tc=g:GetNext()
		end
		-- 完成特殊召唤的最终处理。
		Duel.SpecialSummonComplete()
	end
end
