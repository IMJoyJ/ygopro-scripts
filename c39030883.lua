--ダーク・アームド・ドラゴン・バニッシャー
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己墓地的暗属性怪兽刚好3只的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把手卡的这张卡给对方出示才能发动。从手卡把1只6星以下的暗属性怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ②：自己·对方的主要阶段，从自己墓地把最多3只暗属性怪兽除外，以那个数量的场上的卡为对象才能发动。那些卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.descon)
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
-- 特殊召唤手续条件：墓地暗属性怪兽刚好3只
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查主怪兽区是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查墓地暗属性怪兽数量是否刚好为3只
		Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)==3
end
-- ①效果的代价：把手卡的这张卡给对方出示
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤手牌中6星以下的暗属性怪兽
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标：检查是否存在可特招怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌是否有6星以下暗属性怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的处理：从手牌特殊召唤暗属性怪兽并施加特招属性限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主怪兽区是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌选择1只6星以下暗属性怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册只能特殊召唤暗属性怪兽的限制
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：非暗属性怪兽不能特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
-- ②效果的发动条件：主要阶段
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- 过滤墓地中可以除外的暗属性怪兽
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- ②效果的代价：从墓地把最多3只暗属性怪兽除外并记录数量
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查墓地是否存在可除外的暗属性怪兽
	if chk==0 then return e:IsCostChecked() and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 获取场上可作为破坏对象的卡片数量
	local ct=Duel.GetTargetCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if ct>3 then ct=3 end
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择最多3只暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
	-- 将选中的暗属性怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- ②效果的目标：选择除外数量的场上的卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可作为破坏对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择除外数量的场上的卡作为对象
	local tg=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,ct,0,0)
end
-- ②效果的处理：破坏目标卡片
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上与连锁有关的目标卡
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if g:GetCount()>0 then
		-- 破坏目标卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
