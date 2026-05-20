--Dボーイズ
-- 效果：
-- 反转：可以从卡组把「D少年组」任意数量表侧攻击表示特殊召唤。那之后，自己受到这个效果特殊召唤的怪兽数量×1000的数值的伤害。
function c79279397.initial_effect(c)
	-- 反转：可以从卡组把「D少年组」任意数量表侧攻击表示特殊召唤。那之后，自己受到这个效果特殊召唤的怪兽数量×1000的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79279397,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c79279397.target)
	e1:SetOperation(c79279397.spop)
	c:RegisterEffect(e1)
end
-- 效果发动时的可行性检查（检查怪兽区域空位数以及卡组中是否存在可特殊召唤的「D少年组」）
function c79279397.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张可以特殊召唤的「D少年组」
		and Duel.IsExistingMatchingCard(c79279397.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息为从卡组特殊召唤至少1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤卡组中卡名为「D少年组」且可以表侧攻击表示特殊召唤的怪兽
function c79279397.filter(c,e,tp)
	return c:IsCode(79279397) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果处理的核心逻辑（计算可召唤数量、选择并特殊召唤「D少年组」、计算并给予玩家伤害）
function c79279397.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1到ft（可用空格数）张满足条件的「D少年组」
	local g=Duel.SelectMatchingCard(tp,c79279397.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上，并记录成功特殊召唤的数量
		local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		if ct>0 then
			-- 中断当前效果处理，使后续的伤害处理与特殊召唤不视为同时进行（造成错时点）
			Duel.BreakEffect()
			-- 给予自己受到这个效果特殊召唤的怪兽数量×1000的数值的伤害
			Duel.Damage(tp,ct*1000,REASON_EFFECT)
		end
	end
end
