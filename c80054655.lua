--クロスロードランナー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：调整被送去自己墓地的场合才能发动（伤害步骤也能发动）。这张卡从手卡·墓地特殊召唤。除这张卡外的「废品战士」或者有那个卡名记述的怪兽在场上存在的场合，可以再把对方场上的攻击力1900以上的怪兽全部变成守备表示。这个效果特殊召唤的这张卡从场上离开的场合除外。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册该卡的效果：调整送去自己墓地时，可以从手卡·墓地特殊召唤，并可能改变对方怪兽表示形式。
function s.initial_effect(c)
	-- 将「废品战士」加入该卡的效果文本记载卡片列表中。
	aux.AddCodeList(c,60800381)
	-- ①：调整被送去自己墓地的场合才能发动（伤害步骤也能发动）。这张卡从手卡·墓地特殊召唤。除这张卡外的「废品战士」或者有那个卡名记述的怪兽在场上存在的场合，可以再把对方场上的攻击力1900以上的怪兽全部变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：属于自己且是调整怪兽的卡。
function s.cfilter(c,tp)
	return c:GetOwner()==tp and c:IsType(TYPE_TUNER)
end
-- 发动条件：送去墓地的卡中存在自己原本持有的调整怪兽，且不包含这张卡自身。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果发动时的目标选择与检测：检查自身是否能特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有空怪兽格，且这张卡是否能特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，包含这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤条件：场上表侧表示的「废品战士」或者有该卡名记述的怪兽。
function s.pcfilter(c)
	-- 检查卡片是否表侧表示，且卡名为「废品战士」或其效果文本中记载了「废品战士」的怪兽。
	return c:IsFaceup() and (c:IsCode(60800381) or c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,60800381))
end
-- 过滤条件：对方场上攻击力1900以上且可以改变表示形式的攻击表示怪兽。
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition() and c:IsAttackAbove(1900)
end
-- 效果处理：特殊召唤自身，并为其添加离场时除外的效果；若满足条件，可选择将对方场上攻击力1900以上的怪兽全部变成守备表示。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与连锁相关，且不受「王家之谷的眠谷」的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 将这张卡以表侧表示特殊召唤，并检查是否特殊召唤成功。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1)
		-- 检查场上是否存在除这张卡以外的「废品战士」或有该卡名记述的怪兽。
		if Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_ONFIELD,0,1,c)
			-- 检查对方场上是否存在攻击力1900以上的攻击表示怪兽。
			and Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
			-- 让玩家选择是否发动改变表示形式的追加效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否改变表示形式？"
			-- 获取对方场上所有满足条件的攻击力1900以上的攻击表示怪兽。
			local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
			if g:GetCount()>0 then
				-- 中断当前效果处理，使后续的改变表示形式处理不与特殊召唤同时进行。
				Duel.BreakEffect()
				-- 将目标怪兽全部变成表侧守备表示。
				Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
			end
		end
	end
	-- 这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 在玩家身上注册该特殊召唤限制效果。
	Duel.RegisterEffect(e2,tp)
end
-- 限制条件：不能从额外卡组特殊召唤同调怪兽以外的怪兽。
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
