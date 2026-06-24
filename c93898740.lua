--破械習合
local s,id,o=GetID()
-- 初始化效果函数，注册两个效果：一个发动效果和一个破坏时的诱发效果
function s.initial_effect(c)
	-- 发动效果：可以将场上2只满足条件的怪兽作为素材，连接召唤1只恶魔族连接怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 破坏时效果：当此卡被破坏送去墓地时，可以特殊召唤1只幻神族怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选场上正面表示且能成为效果对象的怪兽
function s.filter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 过滤函数，用于筛选自己控制的连接怪兽（破械族）
function s.lkfilter(c,tp)
	return c:IsSetCard(0x1130) and c:IsType(TYPE_LINK) and c:IsControler(tp)
end
-- 子组选择函数，检查所选怪兽中是否存在破械族连接怪兽，并确认额外卡组中存在满足条件的恶魔族连接怪兽
function s.sgselect(g,tp)
	return g:IsExists(s.lkfilter,1,nil,tp)
		-- 检查额外卡组中是否存在满足条件的恶魔族连接怪兽
		and Duel.IsExistingMatchingCard(s.lfilter,tp,LOCATION_EXTRA,0,1,nil,g)
end
-- 过滤函数，用于筛选恶魔族且可以作为连接召唤素材的怪兽（需要2个以上素材）
function s.lfilter(c,mg)
	return c:IsRace(RACE_FIEND) and c:IsLinkSummonable(mg,nil,2,2)
end
-- 发动效果的目标选择函数，选择2只满足条件的怪兽作为对象，并设置操作信息为特殊召唤1只额外卡组的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取场上所有正面表示且能成为效果对象的怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.sgselect,2,2,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,s.sgselect,false,2,2,tp)
	-- 将选中的怪兽设置为连锁处理的目标
	Duel.SetTargetCard(sg)
	-- 设置操作信息，表示将特殊召唤额外卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤函数，用于筛选场上的正面表示且未被该效果免疫的怪兽
function s.mtfilter(c,tp,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
		and not c:IsImmuneToEffect(e)
end
-- 发动效果的处理函数，若满足条件则从额外卡组选择1只恶魔族连接怪兽进行连接召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的对象
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()==2 and g:IsExists(s.mtfilter,2,nil,tp,e) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组中选择1只满足条件的恶魔族连接怪兽
		local sg=Duel.SelectMatchingCard(tp,s.lfilter,tp,LOCATION_EXTRA,0,1,1,nil,g)
		local lc=sg:GetFirst()
		if lc then
			-- 执行连接召唤，使用选中的怪兽作为素材进行连接召唤
			Duel.LinkSummon(tp,lc,g,nil,2,2)
		end
	end
end
-- 破坏时效果的发动条件函数，判断此卡是否因效果被破坏且在场上正面表示过
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤函数，用于筛选幻神族且可以特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 破坏时效果的目标选择函数，检查是否有满足条件的幻神族怪兽可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的幻神族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤卡组中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 破坏时效果的处理函数，若满足条件则从卡组中选择1只幻神族怪兽进行特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的幻神族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤，将选中的怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
