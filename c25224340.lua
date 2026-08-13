--幻惑の操手
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1只幻想魔族怪兽送去墓地。
-- ②：自己场上有5星以上的幻想魔族怪兽存在的场合，自己主要阶段把墓地的这张卡除外，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
local s,id,o=GetID()
-- 初始化幻惑之操手的两个效果：①从卡组将1只幻想魔族怪兽送去墓地；②自己场上有5星以上幻想魔族时，除外墓地的这张卡，以对方墓地1只怪兽为对象特殊召唤到己方场上，并在下个回合结束阶段将其除外。两个效果1回合合计只能使用其中任意1次。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：从卡组把1只幻想魔族怪兽送去墓地。
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
	-- 设置②效果的发动COST为把墓地的这张卡除外（使用aux.bfgcost辅助函数）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义卡组送墓的过滤条件：怪兽族、幻想魔族，并且可以送去墓地。
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ILLUSION) and c:IsAbleToGrave()
end
-- ①效果的目标与操作信息设置：发动时检查卡组有符合条件的幻想魔族，并设置从卡组送1张卡去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法判定：己方卡组中存在至少1只符合条件的幻想魔族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将1张卡从卡组送去墓地（不取对象，目标玩家tp，位置卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：玩家从卡组选择1只幻想魔族怪兽，以效果原因将其送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组选择1张符合条件的幻想魔族怪兽（必须选1张）。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义过滤条件：表侧表示、幻想魔族、等级5以上的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ILLUSION) and c:IsLevelAbove(5)
end
-- ②效果的发动条件：自己场上有5星以上的幻想魔族怪兽存在。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只符合条件的幻想魔族怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义对方墓地怪兽的可特殊召唤过滤条件：是怪兽且能被当前效果特殊召唤（进行常规苏生限制/召唤条件检查）。
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标函数：连锁对象合法性确认（对象在对方墓地且满足特召条件）；发动合法性检查（自己场上有空位且对方墓地存在可特召对象）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.spfilter(chkc,e,tp) end
	-- 发动合法判定：自己场上有可用的怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且对方墓地存在至少1只可作为此效果对象的怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 显示特殊召唤选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从对方墓地选择1只符合条件的怪兽作为效果对象（同时将其设为连锁对象）。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息：预定特殊召唤所选择的怪兽（1只）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：获取对象卡；若对象有效且能特殊召唤，则将其特殊召唤到己方场上，成功后给该怪兽加上‘幻惑之操手的效果特殊召唤’标记，并设置一个在下个回合结束阶段将其除外的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理时的对象卡（之前选择的对方墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与此连锁相关、不受王家长眠之谷影响，并尝试将其特殊召唤到自己场上；若特殊召唤成功则继续登记除外效果。
	if tc and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"「幻惑之操手」的效果特殊召唤"
		-- 这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 设置延迟效果的标记为下个回合（当前回合数+1），用于判断下个回合的结束阶段。
		e1:SetLabel(Duel.GetTurnCount()+1)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.rmcon)
		e1:SetOperation(s.rmop)
		-- 将该延迟除外效果注册到决斗中，在满足条件时执行。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 除外效果的触发条件：只有被特殊召唤的怪兽仍带有‘幻惑之操手的效果特殊召唤’标记，且当前回合数达到预设的下个回合时才会触发；若标记已消失则重置该效果。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		-- 判定当前回合数是否等于预设的下个回合数，即是否已经到下个回合的结束阶段。
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 除外效果实际处理：将之前特殊召唤的怪兽除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示幻惑之操手的卡片动画，提示这是该卡的效果导致的除外。
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	-- 以表侧表示将目标怪兽除外，原因记为效果。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
