--エレキック・ファイティング・ポーター
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡把最多2只3星以下的光属性怪兽特殊召唤。这个效果把原本种族相同的2只怪兽特殊召唤的场合，这个回合，那些怪兽可以直接攻击。这个效果把原本等级相同的2只怪兽特殊召唤的场合，这个回合，那些怪兽不会被战斗破坏。
local s,id,o=GetID()
-- 创建并注册主效果，设置为发动时点、可特殊召唤、限制1回合1次
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于筛选手牌中光属性且等级不超过3的怪兽
function s.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上存在空位且手牌中有符合条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，提示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理效果发动的主要逻辑：选择并特殊召唤怪兽，并根据条件赋予额外效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算最多可特殊召唤的怪兽数量（不超过2只且不超过场上空位）
	local ct=math.min(2,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	if ct<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,ct,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 遍历选中的怪兽组，依次执行特殊召唤操作
	for tc in aux.Next(g) do
		-- 将单张怪兽特殊召唤到场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		if g:GetClassCount(Card.GetOriginalRace)==1 and g:GetCount()>1 then
			-- 这个效果把原本种族相同的2只怪兽特殊召唤的场合，这个回合，那些怪兽可以直接攻击。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		if g:GetClassCount(Card.GetOriginalLevel)==1 and g:GetCount()>1 then
			-- 这个效果把原本等级相同的2只怪兽特殊召唤的场合，这个回合，那些怪兽不会被战斗破坏。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e2:SetValue(1)
			tc:RegisterEffect(e2)
		end
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
