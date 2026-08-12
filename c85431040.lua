--イービル・ソーン
-- 效果：
-- ①：把这张卡解放才能发动。给与对方300伤害，可以从卡组把最多2只「邪恶之棘」攻击表示特殊召唤。这个效果特殊召唤的怪兽不能把效果发动。
function c85431040.initial_effect(c)
	-- ①：把这张卡解放才能发动。给与对方300伤害，可以从卡组把最多2只「邪恶之棘」攻击表示特殊召唤。这个效果特殊召唤的怪兽不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85431040,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c85431040.cost)
	e1:SetTarget(c85431040.target)
	e1:SetOperation(c85431040.operation)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）：检查自身是否可以解放，并在发动时将自身解放
function c85431040.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果发动时的对象选择与操作信息注册：注册给与对方伤害的操作信息
function c85431040.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置在效果处理时给与对方300点伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 过滤卡组中卡名为「邪恶之棘」且可以以表侧攻击表示特殊召唤的怪兽
function c85431040.filter(c,e,tp)
	return c:IsCode(85431040) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果处理：给与对方300伤害，并可以从卡组将最多2只「邪恶之棘」以表侧攻击表示特殊召唤，且这些怪兽不能发动效果
function c85431040.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给与对方300点伤害，若伤害未成功给与则效果处理终止
	if Duel.Damage(1-tp,300,REASON_EFFECT)==0 then return end
	-- 获取自身场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取卡组中所有满足特殊召唤条件的「邪恶之棘」怪兽
	local g=Duel.GetMatchingGroup(c85431040.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 询问玩家是否选择从卡组特殊召唤「邪恶之棘」
	if Duel.SelectYesNo(tp,aux.Stringid(85431040,1)) then  --"是否要特殊召唤「邪恶之棘」？"
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,ft,nil)
		local tc=sg:GetFirst()
		while tc do
			-- 尝试将选中的怪兽以表侧攻击表示特殊召唤（分步处理）
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
				-- 这个效果特殊召唤的怪兽不能把效果发动。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetRange(LOCATION_MZONE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
			tc=sg:GetNext()
		end
		-- 完成所有分步特殊召唤的处理
		Duel.SpecialSummonComplete()
	end
end
