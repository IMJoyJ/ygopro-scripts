--インフェルニティ・ジェネラル
-- 效果：
-- 自己手卡是0张的场合，把自己墓地存在的这张卡从游戏中除外，选择自己墓地存在的2只3星以下的名字带有「永火」的怪兽才能发动。选择的怪兽从墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c17502671.initial_effect(c)
	-- 自己手卡是0张的场合，把自己墓地存在的这张卡从游戏中除外，选择自己墓地存在的2只3星以下的名字带有「永火」的怪兽才能发动。选择的怪兽从墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17502671,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c17502671.spcon)
	-- 设置效果的发动COST为：将位于墓地的这张卡从游戏中除外（aux.bfgcost实现）。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c17502671.sptg)
	e1:SetOperation(c17502671.spop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件判断函数spcon：检测发动者手卡是否为0张，并返回布尔值作为条件。
function c17502671.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定发动者手卡数量为0，满足『自己手卡是0张的场合』的发动条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 定义怪兽选择过滤条件：卡名属于「永火」字段、等级3星以下、且能被效果特殊召唤。
function c17502671.filter(c,e,tp)
	return c:IsSetCard(0xb) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的目标选择与合法性检查：确认不处于青眼精灵龙限制下、主要怪兽区空位足够、墓地存在2只符合条件的「永火」怪兽；满足后从中选择2只作为效果对象。
function c17502671.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c17502671.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查我方主要怪兽区可用空格数大于1，以确保可以同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查墓地是否存在至少2只满足过滤条件且能成为效果对象的「永火」怪兽；若存在则效果可以发动。
		and Duel.IsExistingTarget(c17502671.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 向操作玩家显示『请选择要特殊召唤的卡』的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从我方墓地选择2只满足过滤条件的「永火」怪兽，并设置为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c17502671.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置操作信息：声明本连锁将进行2只怪兽的特殊召唤，供相关效果（如星尘龙、王家长眠之谷）检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 定义效果处理函数spop：取得对象卡，确认对象仍与效果关联且场上空位足够，再逐只特殊召唤并使其效果无效化；若受青眼精灵龙限制或空位不足则直接终止。
function c17502671.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理时选择的对象卡组（即那2只怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检查我方主要怪兽区可用空格数是否小于要特殊召唤的怪兽数量；若数量不足则不能进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<sg:GetCount()
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	local tc=sg:GetFirst()
	local c=e:GetHandler()
	while tc do
		-- 将当前怪兽以表侧表示逐张特殊召唤（特殊召唤分解步骤）；成功后再为它附加效果无效化状态。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
		tc=sg:GetNext()
	end
	-- 完成整组特殊召唤的收尾处理，使之前通过SpecialSummonStep逐张召唤的怪兽正式特殊召唤成功。
	Duel.SpecialSummonComplete()
end
