--破械習合
local s,id,o=GetID()
-- 注册卡片效果的初始化函数（包含以双方场上包括自己场上「破械神」连接怪兽在内的2只表侧怪兽为素材连接召唤1只恶魔族连接怪兽的效果，以及盖放的此卡被破坏时从卡组特殊召唤1只「破械」怪兽的效果）
function s.initial_effect(c)
	-- 以包含我方场上「破械神」连接怪兽在内的、我方·对手场上的2只表侧表示怪兽为对象可以发动。仅以该2只怪兽为素材进行1只恶魔族连接怪兽的连接召唤
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
	-- 覆盖的此卡被效果破坏的场合可以发动。从牌组将1只「破械」怪兽特殊召唤
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
-- 过滤场上表侧表示且可以成为效果对象的怪兽的过滤函数
function s.filter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 过滤自己场上属于「破械神」系列连接怪兽的过滤函数
function s.lkfilter(c,tp)
	return c:IsSetCard(0x1130) and c:IsType(TYPE_LINK) and c:IsControler(tp)
end
-- 用于选择作为连接素材的卡组的条件函数
function s.sgselect(g,tp)
	return g:IsExists(s.lkfilter,1,nil,tp)
		-- 并且检查额外卡组中是否存在可以以这些卡为素材进行连接召唤的怪兽
		and Duel.IsExistingMatchingCard(s.lfilter,tp,LOCATION_EXTRA,0,1,nil,g)
end
-- 过滤额外卡组中可以用指定素材进行连接召唤的恶魔族怪兽的过滤函数
function s.lfilter(c,mg)
	return c:IsRace(RACE_FIEND) and c:IsLinkSummonable(mg,nil,2,2)
end
-- 效果①的发动准备与取对象函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取场上所有符合条件的表侧表示怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.sgselect,2,2,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,s.sgselect,false,2,2,tp)
	-- 将选择的2只怪兽设置为该效果的对象
	Duel.SetTargetCard(sg)
	-- 设置效果处理的分类为特殊召唤，数量为1，目标位置为额外卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 检查作为素材的怪兽是否仍在场上表侧表示存在，且不受该陷阱卡效果影响的过滤函数
function s.mtfilter(c,tp,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
		and not c:IsImmuneToEffect(e)
end
-- 效果①效果处理的处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与连锁相关联的对象怪兽
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()==2 and g:IsExists(s.mtfilter,2,nil,tp,e) then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只可以用选择的怪兽为素材进行连接召唤的怪兽
		local sg=Duel.SelectMatchingCard(tp,s.lfilter,tp,LOCATION_EXTRA,0,1,1,nil,g)
		local lc=sg:GetFirst()
		if lc then
			-- 仅以选择的2只怪兽作为素材将该怪兽进行连接召唤
			Duel.LinkSummon(tp,lc,g,nil,2,2)
		end
	end
end
-- 效果②特殊召唤效果的发动条件函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤卡组中属于「破械」系列且可以特殊召唤的怪兽的过滤函数
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②特殊召唤效果的发动准备与检查函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查当前玩家场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组是否存在可以特殊召唤的「破械」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理的分类为特殊召唤，数量为1，目标位置为卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②特殊召唤效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若没有可用的怪兽区域，则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只符合条件的「破械」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
