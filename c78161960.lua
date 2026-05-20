--リジェクト・リボーン
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。战斗阶段结束。那之后，可以从自己墓地选调整和同调怪兽各1只特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c78161960.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能发动。战斗阶段结束。那之后，可以从自己墓地选调整和同调怪兽各1只特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c78161960.condition)
	e1:SetCost(c78161960.cost)
	e1:SetOperation(c78161960.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数（对方怪兽直接攻击宣言时）
function c78161960.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽的控制者是否为对方，且攻击对象是否为空（即直接攻击）
	return eg:GetFirst():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 定义发动代价函数，注册战斗阶段标识以防止异常处理
function c78161960.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 为玩家注册一个在战斗阶段结束时重置的标识效果
	Duel.RegisterFlagEffect(tp,78161960,RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 定义调整怪兽的过滤条件：是调整怪兽、可以特殊召唤，且墓地中还存在至少1只可以特殊召唤的同调怪兽
function c78161960.filter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查墓地中是否存在除当前卡以外的、可以特殊召唤的同调怪兽
		and Duel.IsExistingMatchingCard(c78161960.filter2,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
-- 定义同调怪兽的过滤条件：是同调怪兽且可以特殊召唤
function c78161960.filter2(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果处理函数：结束战斗阶段，并可选地从墓地特殊召唤调整和同调怪兽各1只且效果无效化
function c78161960.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否成功注册了发动标识，若未注册则不处理后续效果
	if Duel.GetFlagEffect(tp,78161960)==0 then return end
	local c=e:GetHandler()
	-- 跳过对方的战斗阶段，使其直接进入结束步骤（即结束战斗阶段）
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	-- 检查自己场上的怪兽区域空位数是否大于1（因为需要特殊召唤2只怪兽）
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己墓地是否存在满足条件的调整怪兽（且同时存在同调怪兽）
		and Duel.IsExistingMatchingCard(c78161960.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否选择进行特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(78161960,0)) then  --"特殊召唤"
		-- 中断当前效果处理，使后续的特殊召唤处理与结束战斗阶段不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只满足条件的调整怪兽（适用王家之谷的过滤）
		local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c78161960.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只除已选调整怪兽以外的、满足条件的同调怪兽（适用王家之谷的过滤）
		local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c78161960.filter2),tp,LOCATION_GRAVE,0,1,1,g1:GetFirst(),e,tp)
		g1:Merge(g2)
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		local tc=g1:GetFirst()
		while tc do
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			tc=g1:GetNext()
		end
	end
end
