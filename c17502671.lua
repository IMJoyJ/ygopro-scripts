--インフェルニティ・ジェネラル
-- 效果：
-- 自己手卡是0张的场合，把自己墓地存在的这张卡从游戏中除外，选择自己墓地存在的2只3星以下的名字带有「永火」的怪兽才能发动。选择的怪兽从墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c17502671.initial_effect(c)
	-- 创建效果，设置效果描述为“特殊召唤”，分类为特殊召唤，属性为取对象效果，类型为起动效果，发动位置为墓地，条件为己方手卡为0张，费用为将此卡除外，目标为选择2只3星以下的永火怪兽，效果处理为特殊召唤并使效果无效化
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17502671,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c17502671.spcon)
	-- 效果的费用为将此卡从游戏中除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c17502671.sptg)
	e1:SetOperation(c17502671.spop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件为己方手卡数量为0张
function c17502671.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 己方手卡数量为0张
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 过滤函数，用于筛选3星以下且名字带有「永火」的怪兽，且可以被特殊召唤
function c17502671.filter(c,e,tp)
	return c:IsSetCard(0xb) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标，当chkc不为空时返回是否为己方墓地的永火怪兽，当chk为0时返回是否满足发动条件（未受青眼精灵龙影响、场上空位大于等于2、墓地存在2只符合条件的怪兽）
function c17502671.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c17502671.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 场上可用怪兽区域大于等于2
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 墓地存在2只符合条件的怪兽
		and Duel.IsExistingTarget(c17502671.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择2只符合条件的怪兽作为效果目标
	local g=Duel.SelectTarget(tp,c17502671.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理函数，获取目标怪兽组并进行特殊召唤及效果无效化处理
function c17502671.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 判断场上空位是否足够进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<sg:GetCount()
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	local tc=sg:GetFirst()
	local c=e:GetHandler()
	while tc do
		-- 将目标怪兽特殊召唤到场上
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 创建一个使怪兽效果无效的效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 创建一个使怪兽效果无效化的效果
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
		tc=sg:GetNext()
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
