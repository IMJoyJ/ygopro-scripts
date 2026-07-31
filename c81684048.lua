--墓場のゴースト王－パンプキング－
-- 效果：
-- 可以把手卡的这张卡给对方出示；从自己的卡组·墓地把1张「活死人的呼声」在自己场上盖放，丢弃1张手卡。这个效果盖放的卡在盖放的回合也能发动。
-- 这张卡特殊召唤的场合：可以从卡组把除攻击力1950外的，1只6星不死族怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能从手卡·墓地特殊召唤。
-- 「骨冢幽灵王-南瓜王-」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌展示盖放「活死人的呼声」并弃牌效果、②特召成功从卡组特召6星不死族怪兽效果
function s.initial_effect(c)
	-- 注册关联卡片卡号：「活死人的呼声」(97077563)
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
	-- 这张卡特殊召唤的场合：可以从卡组把除攻击力1950外的，1只6星不死族怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能从手卡·墓地特殊召唤。
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
-- ①效果发动Cost：确认手牌的此卡未处于公开状态
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 盖放过滤条件：「活死人的呼声」且可以在场上盖放
function s.setfilter(c)
	return c:IsCode(97077563) and c:IsSSetable()
end
-- ①效果发动准备：检查卡组·墓地是否存在「活死人的呼声」及手牌是否有可丢弃的卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地是否存在可盖放的「活死人的呼声」
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		-- 检查手牌是否存在可因效果丢弃的卡片
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_DISCARD+REASON_EFFECT) end
end
-- ①效果处理：从卡组·墓地盖放1张「活死人的呼声」，丢弃1张手牌，并赋予该卡盖放回合即可发动的能力
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组或墓地选择1张「活死人的呼声」（受王谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 成功盖放选中的卡后进行后续处理
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 提示并选择手牌中1张要丢弃的卡
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_DISCARD+REASON_EFFECT)
		if dg:GetCount()>0 then
			-- 洗混手牌
			Duel.ShuffleHand(tp)
			-- 将选中的手牌因效果丢弃去墓地
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
-- 特殊召唤过滤条件：6星、不死族、攻击力不是1950且可特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsLevel(6) and c:IsRace(RACE_ZOMBIE) and not c:IsAttack(1950) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动准备：设置从卡组特殊召唤怪兽的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在满足条件的6星不死族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组特殊召唤1只满足条件的6星不死族怪兽，并注册回合内特召限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认怪兽区域有空位时进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的6星不死族怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽表侧表示特殊召唤
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
	-- 为玩家注册回合内特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制判定：限制从手牌·墓地特殊召唤非不死族怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) and not c:IsRace(RACE_ZOMBIE)
end
