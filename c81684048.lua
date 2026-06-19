--Pumpking the King of Grave Ghosts
-- 效果：
-- 可以把手卡的这张卡给对方出示；从自己的卡组·墓地把1张「活死人的呼声」在自己场上盖放，丢弃1张手卡。这个效果盖放的卡在盖放的回合也能发动。
-- 这张卡特殊召唤的场合：可以从卡组把除攻击力1950外的，1只6星不死族怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能从手卡·墓地特殊召唤。
-- 「骨冢幽灵王-南瓜王-」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数并记录关联卡片代码列表
function s.initial_effect(c)
	-- 记录该卡记载了「活死人的呼声」的卡片密码
	aux.AddCodeList(c,97077563)
	-- 可以把手卡的这张卡给对方出示；从自己的卡组·墓地把1张「活死人的呼声」在自己场上盖放，丢弃1张手卡。这个效果盖放的卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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
-- 出示手卡中的这张卡作为效果发动的Cost
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤自己卡组或墓地中满足盖放条件的「活死人的呼声」
function s.setfilter(c)
	return c:IsCode(97077563) and c:IsSSetable()
end
-- 盖放并丢弃手卡效果的发动条件与靶子判定
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组和墓地中是否存在可以盖放的「活死人的呼声」
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		-- 判定手卡中除了可以丢弃的卡以外，是否还有可以盖放的卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_DISCARD+REASON_EFFECT) end
end
-- 从卡组·墓地盖放「活死人的呼声」并丢弃1张手卡，且赋予该陷阱卡在盖放回合发动的效果的实际处理
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给玩家发送选择要盖放卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组或墓地选择1张不受王家长眠之谷影响且满足盖放条件的「活死人的呼声」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判定盖放是否成功进行
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 选择自己手卡中的1张卡片丢弃
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_DISCARD+REASON_EFFECT)
		if dg:GetCount()>0 then
			-- 将玩家的手牌重新洗切
			Duel.ShuffleHand(tp)
			-- 将因效果丢弃的卡片送去墓地
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
-- 过滤卡组中除攻击力1950以外的6星不死族怪兽
function s.spfilter(c,e,tp)
	return c:IsLevel(6) and c:IsRace(RACE_ZOMBIE) and not c:IsAttack(1950) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤成功时从卡组特殊召唤6星不死族怪兽效果的发动靶子判定
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否还有空位可用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可特殊召唤的除攻击力1950以外的6星不死族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息为从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤不死族怪兽并附加特殊召唤誓约限制效果的实际处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定自己场上的怪兽区域是否还有可用的格子
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 给玩家发送选择特殊召唤怪兽的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只满足条件的6星不死族怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
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
	-- 为玩家注册禁止特殊召唤的全局规则限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 誓约限制条件：禁止从手牌或墓地特殊召唤非不死族的怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) and not c:IsRace(RACE_ZOMBIE)
end
