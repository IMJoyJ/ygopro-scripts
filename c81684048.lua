--墓場のゴースト王－パンプキング－
-- 效果：
-- 可以把手卡的这张卡给对方出示；从自己的卡组·墓地把1张「活死人的呼声」在自己场上盖放，丢弃1张手卡。这个效果盖放的卡在盖放的回合也能发动。
-- 这张卡特殊召唤的场合：可以从卡组把除攻击力1950外的，1只6星不死族怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能从手卡·墓地特殊召唤。
-- 「骨冢幽灵王-南瓜王-」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 添加涉及97077563的效果相关声明，注册起动效果（盖放），注册诱发型单体效果（特殊召唤）。
function s.initial_effect(c)
	-- 记录这张卡上记载着97077563（「活死人的呼声」）的卡名事实
	aux.AddCodeList(c,97077563)
	-- 可以把手卡的这张卡给对方出示；从自己的卡组·墓地把1张「活死人的呼声」在自己场上盖放，丢弃1张手卡。这个效果盖放的卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤的场合：可以从卡组把除攻击力1950外的，1只6星不死族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 检查卡片在手卡是否公开，如果未公开则通过出示卡片作为发动的Cost条件
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤可以盖放的97077563（「活死人的呼声」）
function s.setfilter(c)
	return c:IsCode(97077563) and c:IsSSetable()
end
-- 检查卡组或墓地是否存在可以盖放的「活死人的呼声」，以及手卡是否有可以丢弃的卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地是否存在满足盖放条件的「活死人的呼声」
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		-- 并且检查自己手卡是否有可丢弃的卡片
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_DISCARD+REASON_EFFECT) end
end
-- 从卡组或墓地选择1张「活死人的呼声」盖放，然后丢弃1张手卡，盖放的卡赋予本回合能发动的效果
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给玩家发送提示：请选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组或墓地选择1张可以盖放且不受王家长眠之谷影响的「活死人的呼声」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 如果选择了卡片并且成功在场上盖放
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 让玩家从手卡选择1张可以被效果丢弃的卡
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_DISCARD+REASON_EFFECT)
		if dg:GetCount()>0 then
			-- 手动洗切玩家的手卡
			Duel.ShuffleHand(tp)
			-- 将选中的手卡作为效果丢弃送去墓地
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
		-- 这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"适用「骨冢幽灵王-南瓜王-」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：等级6的不死族怪兽，攻击力不是1950，并且可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsLevel(6) and c:IsRace(RACE_ZOMBIE) and not c:IsAttack(1950) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查主要怪兽区是否有空位，以及卡组是否有可以特殊召唤的符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区是否还有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组是否存在满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设定操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 在怪兽区有空位的前提下，从卡组选择符合条件的怪兽特殊召唤，然后对自己适用特召限制的自肃效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果自己场上的主要怪兽区存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 给玩家发送提示：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只满足特殊召唤条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽表侧表示特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是不死族怪兽不能从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制特殊召唤的全局效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃范围：禁止手卡和墓地中不是不死族的怪兽进行特殊召唤
function s.splimit(e,c)
	return c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) and not c:IsRace(RACE_ZOMBIE)
end
