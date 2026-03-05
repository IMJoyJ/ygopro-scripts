--百鬼羅刹大危機
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只「哥布林」怪兽和对方场上1只怪兽或者自己墓地1只「哥布林」怪兽和对方墓地1只怪兽为对象才能发动。那2只怪兽除外。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己的除外状态的5只「哥布林」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册发动和两个效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只「哥布林」怪兽和对方场上1只怪兽或者自己墓地1只「哥布林」怪兽和对方墓地1只怪兽为对象才能发动。那2只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己的除外状态的5只「哥布林」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤场上或墓地的「哥布林」怪兽，满足除外条件且能选择目标
function s.rmfilter1(c,tp)
	local loc=c:GetLocation()
	return c:IsFaceupEx() and c:IsSetCard(0xac) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
		-- 检查是否存在满足条件的第二只目标怪兽
		and Duel.IsExistingTarget(s.rmfilter2,tp,0,loc,1,nil)
end
-- 过滤任意怪兽，满足除外条件
function s.rmfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 设置除外效果的目标选择逻辑
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否存在满足条件的「哥布林」怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的「哥布林」怪兽作为目标
	local g1=Duel.SelectTarget(tp,s.rmfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	local loc=g1:GetFirst():GetLocation()
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的第二只怪兽作为目标
	local g2=Duel.SelectTarget(tp,s.rmfilter2,tp,0,loc,1,1,nil)
	g1:Merge(g2)
	-- 设置除外效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
end
-- 过滤任意怪兽，满足除外条件
function s.rmopfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 执行除外效果，将目标怪兽除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁相关的对象卡
	local g=Duel.GetTargetsRelateToChain()
	-- 过滤对象卡，排除受王家长眠之谷影响的卡
	local tg=g:Filter(aux.NecroValleyFilter(s.rmopfilter),nil)
	if tg:GetCount()==2 then
		-- 将符合条件的卡除外
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断效果是否可以发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 设置特殊召唤效果的费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤可特殊召唤的「哥布林」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xac) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
-- 设置特殊召唤效果的目标选择逻辑
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 获取所有可特殊召唤的「哥布林」怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否满足特殊召唤条件
	if chk==0 then return ft>=5 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,5,nil,e,tp) and g:GetClassCount(Card.GetCode)>=5
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择5只卡名不同的「哥布林」怪兽
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,5,5)
	-- 设置特殊召唤效果的目标卡
	Duel.SetTargetCard(tg)
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,tg:GetCount(),0,0)
end
-- 执行特殊召唤效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if g:GetCount()<=ft then
		-- 将所有目标卡特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将部分目标卡特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
		-- 将剩余卡送去墓地
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
