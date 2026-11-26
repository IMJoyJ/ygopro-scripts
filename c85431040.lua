--イービル・ソーン
-- 效果：
-- ①：把这张卡解放才能发动。给与对方300伤害，可以从卡组把最多2只「邪恶之棘」攻击表示特殊召唤。这个效果特殊召唤的怪兽不能把效果发动。
function c85431040.initial_effect(c)
	-- ①：把这张卡解放才能发动。给与对方300伤害，可以从卡组把最多2只「邪恶之棘」攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85431040,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c85431040.cost)
	e1:SetTarget(c85431040.target)
	e1:SetOperation(c85431040.operation)
	c:RegisterEffect(e1)
end
-- 支付发动代价：确认此卡可被解放并将此卡作为代价解放
function c85431040.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡自身作为发动代价解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 发动前登记给予对方300点效果伤害的操作信息
function c85431040.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记给予对方300点伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 过滤卡组中卡名为「邪恶之棘」且可表侧攻击表示特殊召唤的怪兽
function c85431040.filter(c,e,tp)
	return c:IsCode(85431040) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果处理：给予对方300点伤害并确认造成伤害后，根据空位（最多2只，受「青眼精灵龙」限制为1）从卡组选「邪恶之棘」攻击表示特召并封印其效果发动
function c85431040.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给予对方300点效果伤害，若未实际造成伤害（返回值为0）则中止后续特殊召唤
	if Duel.Damage(1-tp,300,REASON_EFFECT)==0 then return end
	-- 获取己方怪兽区当前的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 从己方卡组检索所有可表侧攻击表示特殊召唤的「邪恶之棘」
	local g=Duel.GetMatchingGroup(c85431040.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 询问己方玩家是否从卡组特殊召唤「邪恶之棘」
	if Duel.SelectYesNo(tp,aux.Stringid(85431040,1)) then  --"是否要特殊召唤「邪恶之棘」？"
		-- 向己方发送从卡组选择要特殊召唤的「邪恶之棘」的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,ft,nil)
		local tc=sg:GetFirst()
		while tc do
			-- 分步将选中的「邪恶之棘」以表侧攻击表示特殊召唤到己方场上并确认成功
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
		-- 完成分步特殊召唤流程，统一结算特殊召唤成功时点
		Duel.SpecialSummonComplete()
	end
end
