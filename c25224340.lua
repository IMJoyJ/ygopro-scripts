--幻惑の操手
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1只幻想魔族怪兽送去墓地。
-- ②：自己场上有5星以上的幻想魔族怪兽存在的场合，自己主要阶段把墓地的这张卡除外，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
local s,id,o=GetID()
-- 注册两个效果：①从卡组将1只幻想魔族怪兽送去墓地；②自己场上有5星以上的幻想魔族怪兽存在时，可将此卡除外并特殊召唤对方墓地1只怪兽，该怪兽在下个回合结束时除外。
function s.initial_effect(c)
	-- ①：从卡组把1只幻想魔族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：自己场上有5星以上的幻想魔族怪兽存在的场合，自己主要阶段把墓地的这张卡除外，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	-- 将此卡除外作为费用。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：怪兽卡、幻想魔族、能送去墓地。
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ILLUSION) and c:IsAbleToGrave()
end
-- 效果处理前的检查：确认场上是否存在满足条件的幻想魔族怪兽。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：场上存在至少1只幻想魔族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1只幻想魔族怪兽从卡组送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择并把1只幻想魔族怪兽从卡组送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只幻想魔族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤条件：场上表侧表示的幻想魔族怪兽，且等级不低于5。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ILLUSION) and c:IsLevelAbove(5)
end
-- 效果发动条件：确认自己场上是否存在至少1只5星以上的幻想魔族怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足条件：自己场上存在至少1只5星以上的幻想魔族怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：怪兽卡、可特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理前的检查：确认是否有满足条件的对方墓地怪兽可特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.spfilter(chkc,e,tp) end
	-- 检查是否满足条件：自己场上存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足条件：对方墓地存在至少1只可特殊召唤的怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只可特殊召唤的怪兽。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置连锁操作信息：将1只怪兽特殊召唤到自己场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对方墓地1只怪兽特殊召唤到自己场上，并在下个回合结束时除外。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否有效且未被王家长眠之谷影响，并成功特殊召唤。
	if tc and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"「幻惑之操手」的效果特殊召唤"
		-- 在下个回合结束时将特殊召唤的怪兽除外的效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 设置该效果在下个回合结束时触发。
		e1:SetLabel(Duel.GetTurnCount()+1)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.rmcon)
		e1:SetOperation(s.rmop)
		-- 注册该效果到玩家环境中。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否到下个回合结束阶段。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		-- 判断当前回合数是否等于设定的回合数。
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 效果处理：将目标怪兽除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家该卡被除外。
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	-- 将目标怪兽除外。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
