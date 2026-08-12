--銀河超航行
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的除外状态的1只光·暗属性怪兽特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的超量怪兽被除外的场合，把这张卡除外，以那之内的1只为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册卡片的效果①和效果②
function s.initial_effect(c)
	-- ①：自己的除外状态的1只光·暗属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 注册一个合并延迟事件监听器，用于监听卡片被除外的事件
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_REMOVE)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的超量怪兽被除外的场合，把这张卡除外，以那之内的1只为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外并特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.spcon)
	-- 设置发动Cost为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检索自己除外状态的、可以特殊召唤的光·暗属性怪兽
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的除外区是否存在至少1只满足条件的光·暗属性怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从除外区特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_REMOVED)
end
-- 效果①的效果处理（特殊召唤）函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己除外状态的1只光·暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 将选中的怪兽以表侧表示特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数：检索原本在自己场上表侧表示存在、被除外的超量怪兽，且该怪兽可以成为效果对象并特殊召唤
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动条件：被除外的卡中存在满足条件的超量怪兽，且不包含这张卡本身
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,e,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果②的发动准备与对象选择函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.spfilter,nil,e,tp)
	if chkc then return g:IsContains(chkc) end
	-- 检查自己场上是否有空余怪兽区域，且被除外的卡中是否存在至少1只满足条件的超量怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	-- 提示玩家选择要特殊召唤的卡（作为效果对象）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 将选中的超量怪兽设为效果对象
	Duel.SetTargetCard(sg)
	-- 设置连锁信息，表示该效果包含特殊召唤该对象怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
end
-- 效果②的效果处理（特殊召唤对象怪兽）函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关联，则将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
