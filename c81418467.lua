--原石竜インペリアル・ドラゴン
-- 效果：
-- 这张卡在把1只通常怪兽解放的场合才能召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：对方主要阶段，把手卡的这张卡给对方观看才能发动。进行1只「原石」怪兽的召唤。
-- ②：这张卡上级召唤的场合才能发动。以下效果各适用。
-- ●对方场上的全部表侧表示怪兽的效果无效化。
-- ●种族或属性和自己墓地的通常怪兽的其中任意种相同的对方场上的怪兽全部除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含召唤限制、手牌发动召唤「原石」怪兽的二速效果、以及上级召唤成功时无效对方怪兽效果并除外相同种族/属性怪兽的效果。
function s.initial_effect(c)
	-- 这张卡在把1只通常怪兽解放的场合才能召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"进行召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(s.ttcon)
	e1:SetOperation(s.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- ①：对方主要阶段，把手卡的这张卡给对方观看才能发动。进行1只「原石」怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetHintTiming(TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.smcon)
	e2:SetCost(s.smcost)
	e2:SetTarget(s.smtg)
	e2:SetOperation(s.smop)
	c:RegisterEffect(e2)
	-- ②：这张卡上级召唤的场合才能发动。以下效果各适用。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 过滤满足解放条件的通常怪兽（自己场上的通常怪兽，或对方场上表侧表示的通常怪兽）。
function s.tbfilter(c,tp)
	return c:IsType(TYPE_NORMAL) and (c:IsControler(tp) or c:IsFaceup())
end
-- 召唤限制效果的达成条件判定（检查场上是否存在可作为解放的通常怪兽）。
function s.ttcon(e,c,minc)
	if c==nil then return true end
	-- 获取双方场上可作为解放的通常怪兽。
	local g=Duel.GetMatchingGroup(s.tbfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil,c:GetControler())
	-- 判定是否能且仅能解放1只上述通常怪兽来进行召唤。
	return minc<=1 and Duel.CheckTribute(c,1,1,g,c:GetControler())
end
-- 召唤限制效果的解放处理（选择并解放1只通常怪兽）。
function s.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方场上可作为解放的通常怪兽。
	local g=Duel.GetMatchingGroup(s.tbfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 玩家选择1只用于召唤的通常怪兽作为祭品。
	local tg=Duel.SelectTribute(tp,c,1,1,g)
	c:SetMaterial(tg)
	-- 将选中的怪兽作为召唤素材解放。
	Duel.Release(tg,REASON_SUMMON+REASON_MATERIAL)
end
-- 判定是否为对方回合的主要阶段。
function s.smcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判定当前是否为对方回合的主要阶段1或主要阶段2。
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 效果发动的Cost：把手卡的这张卡给对方观看。
function s.smcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤手牌或场上可以进行通常召唤的「原石」怪兽。
function s.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsSetCard(0x1b9)
end
-- 判定手牌或场上是否存在可召唤的「原石」怪兽，并设置召唤的操作信息。
function s.smtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定手牌或场上是否存在至少1只可以进行通常召唤的「原石」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置效果处理包含召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理：让玩家选择1只手牌或场上的「原石」怪兽进行通常召唤。
function s.smop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要进行通常召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 玩家从手牌或场上选择1只满足条件的「原石」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 忽略每回合的通常召唤次数限制，对选中的怪兽进行通常召唤。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 判定此卡是否为上级召唤成功。
function s.drcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤对方场上表侧表示、且其种族或属性与自己墓地某张通常怪兽相同的可除外怪兽。
function s.rmfilter1(c)
	return c:IsFaceup() and c:IsAbleToRemove()
	-- 检查自己墓地是否存在与该怪兽种族或属性相同的通常怪兽。
	and Duel.IsExistingMatchingCard(s.rmfilter2,1-c:GetControler(),LOCATION_GRAVE,0,1,nil,c:GetRace(),c:GetAttribute())
end
-- 过滤自己墓地中与指定怪兽种族或属性相同的通常怪兽。
function s.rmfilter2(c,race,att)
	return c:IsType(TYPE_NORMAL) and c:IsFaceupEx() and (c:IsRace(race) or c:IsAttribute(att))
end
-- 判定对方场上是否存在可无效或可除外的怪兽，并设置无效与除外的操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定对方场上是否存在可以被无效效果的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		-- 或者判定对方场上是否存在满足除外条件的怪兽。
		or Duel.IsExistingMatchingCard(s.rmfilter1,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有可以被无效效果的表侧表示怪兽。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	-- 获取对方场上所有满足除外条件的怪兽。
	local g2=Duel.GetMatchingGroup(s.rmfilter1,tp,0,LOCATION_MZONE,nil)
	-- 若存在可无效的怪兽，则设置无效这些怪兽效果的操作信息。
	if #g>0 then Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0) end
	-- 若存在可除外的怪兽，则设置除外这些怪兽的操作信息。
	if #g2>0 then Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,g2:GetCount(),0,0) end
end
-- 效果处理：依次适用“无效对方场上全部表侧表示怪兽的效果”和“除外与自己墓地通常怪兽种族或属性相同的对方场上怪兽”。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上当前所有可以被无效效果的表侧表示怪兽。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使与目标怪兽相关的连锁都无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- ●对方场上的全部表侧表示怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- ●对方场上的全部表侧表示怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 立即刷新场上卡片的无效状态。
	Duel.AdjustInstantly()
	-- 中断当前效果，使后续的除外处理与无效处理不视为同时进行。
	Duel.BreakEffect()
	-- 获取对方场上所有满足除外条件的怪兽。
	local g2=Duel.GetMatchingGroup(s.rmfilter1,tp,0,LOCATION_MZONE,nil)
	-- 将满足条件的对方场上的怪兽全部表侧表示除外。
	Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
end
