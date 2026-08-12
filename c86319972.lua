--魔法名－「新しき世界の始まり」
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把1只「阿莱斯特」怪兽或融合怪兽除外才能发动。从额外卡组把1只「召唤兽」怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。
-- ②：这张卡在墓地存在的状态，怪兽被表侧除外的场合，把这张卡除外，以自己的除外状态的1只「召唤兽」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：包含①卡片发动时从额外卡组无视召唤条件特殊召唤「召唤兽」怪兽的效果，以及②墓地存在的这张卡被除外并特召自己除外的「召唤兽」怪兽的效果。
function s.initial_effect(c)
	-- ①：从自己墓地把1只「阿莱斯特」怪兽或融合怪兽除外才能发动。从额外卡组把1只「召唤兽」怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，怪兽被表侧除外的场合，把这张卡除外，以自己的除外状态的1只「召唤兽」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	-- 把这张卡除外作为效果②的发动的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地符合除外代价条件的「阿莱斯特」怪兽或融合怪兽。
function s.cfilter(c)
	return (c:IsSetCard(0x1e1) or c:IsType(TYPE_FUSION)) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果①发动的代价：从自己墓地把1只「阿莱斯特」怪兽或融合怪兽除外。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查自己墓地是否存在至少1只满足过滤条件的卡片可用于除外代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择用于除外代价的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地中选择1只满足代价过滤条件的卡片。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡正面表侧除外，作为效果发动的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：自己额外卡组中能够无视召唤条件特殊召唤，且能以可用空格特殊召唤的「召唤兽」融合怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xf4) and c:IsType(TYPE_FUSION)
		-- 判断该卡是否可以被无视召唤条件特殊召唤，且自己场上有可供其出场的额外区域或主要怪兽区域空位。
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果①的发动检测与效果分类注册，表明包含从额外卡组特殊召唤怪兽的效果。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查自己额外卡组是否存在至少1只满足过滤条件的「召唤兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置当前处理的连锁信息：包含从额外卡组特殊召唤1只怪兽的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理：从额外卡组把1只「召唤兽」怪兽无视召唤条件表侧表示特殊召唤，并为其注册在结束阶段除外的延迟效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择用于特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足特殊召唤过滤条件的「召唤兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 如果该怪兽成功无视召唤条件特殊召唤到自己场上。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)~=0 then
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.rmcon)
		e1:SetOperation(s.rmop)
		-- 在全局环境中注册在结束阶段除外该怪兽的延迟效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段除外效果的触发条件检查：判断该怪兽是否已离场或失去标记，若是则重置效果，否则允许触发除外效果。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外效果的效果处理：将该怪兽正面表侧除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 提示当前卡片效果发动，显示该卡的效果动画。
	Duel.Hint(HINT_CARD,0,id)
	-- 通过效果处理将该怪兽正面表侧除外。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
-- 过滤条件：表侧除外的怪兽（若是从场上除外，则必须曾存在于怪兽区域）。
function s.rmfilter(c)
	return c:IsFaceupEx() and (not c:IsPreviousLocation(LOCATION_ONFIELD) or c:IsPreviousLocation(LOCATION_MZONE))
		and c:IsType(TYPE_MONSTER)
end
-- 效果②的发动条件：当前被除外的卡片中存在满足过滤条件的表侧怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rmfilter,1,nil)
end
-- 过滤条件：自己除外状态的、能够特殊召唤的「召唤兽」怪兽。
function s.spfilter2(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0xf4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动检测与对象选择：以自己除外状态的1只「召唤兽」怪兽为对象才能发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.spfilter2(chkc,e,tp) end
	-- 在发动效果前，检查自己主要怪兽区域是否还有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 以及检查自己的除外状态中是否存在能成为特殊召唤对象的「召唤兽」怪兽。
		and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择特殊召唤的目标卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家在自己除外的卡片中选择1只满足过滤条件的「召唤兽」怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：包含特殊召唤选择的对象怪兽的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将选定的对象怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁被选定为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将该对象怪兽以正面表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
