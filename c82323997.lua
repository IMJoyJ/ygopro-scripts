--スカーレッド・ノヴァ・ドラゴン／バスター
-- 效果：
-- 这张卡不能通常召唤，用「爆裂模式」的效果才能特殊召唤。
-- ①：对方把卡的效果发动时，把场上的这张卡直到结束阶段除外才能发动。把最多有自己墓地的调整数量的对方场上的卡除外。
-- ②：对方怪兽的攻击宣言时，把场上的这张卡直到结束阶段除外才能发动。那次攻击无效。那之后，战斗阶段结束。
-- ③：这张卡被破坏的场合才能发动。从自己墓地把1只「真红莲新星龙」特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含特殊召唤限制、对方发动效果时除外自身并除外对方卡片、对方攻击宣言时除外自身并无效攻击结束战斗阶段、被破坏时特殊召唤墓地「真红莲新星龙」的效果。
function s.initial_effect(c)
	-- 记录这张卡上记载了「爆裂模式」（80280737）和「真红莲新星龙」（97489701）的卡名。
	aux.AddCodeList(c,80280737,97489701)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「爆裂模式」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为只能通过「爆裂模式」的效果进行特殊召唤。
	e1:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e1)
	-- ①：对方把卡的效果发动时，把场上的这张卡直到结束阶段除外才能发动。把最多有自己墓地的调整数量的对方场上的卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.rmcon)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- ②：对方怪兽的攻击宣言时，把场上的这张卡直到结束阶段除外才能发动。那次攻击无效。那之后，战斗阶段结束。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"无效攻击"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.nacon)
	e3:SetCost(s.rmcost)
	e3:SetOperation(s.naop)
	c:RegisterEffect(e3)
	-- ③：这张卡被破坏的场合才能发动。从自己墓地把1只「真红莲新星龙」特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.assault_name=97489701
-- 检查是否为对方玩家发动了卡的效果。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
-- 效果发动代价：将场上的这张卡暂时除外，并注册在结束阶段返回场上的延迟效果。
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	-- 检查是否成功将自身作为代价暂时除外，且该卡的原卡号与本卡一致。
	if Duel.Remove(c,0,REASON_COST+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"直到结束阶段除外"
		-- 直到结束阶段除外才能发动。把最多有自己墓地的调整数量的对方场上的卡除外。那次攻击无效。那之后，战斗阶段结束。从自己墓地把1只「真红莲新星龙」特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		-- 在全局环境注册该回合结束阶段将此卡返回场上的效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤条件：判断卡片是否为调整怪兽。
function s.cfilter(c)
	return c:IsType(TYPE_TUNER)
end
-- 效果①的发动检测与靶向：获取自己墓地调整怪兽的数量，确认数量大于0且对方场上有可除外的卡，并设置除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地的调整怪兽数量。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return ct>0
		-- 并且确认对方场上存在至少1张可以被除外的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 设置连锁中的操作信息：除外对方场上的卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end
-- 效果①的处理：计算自己墓地调整数量，让玩家选择最多该数量的对方场上的卡并除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，重新计算自己墓地的调整怪兽数量。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if ct==0 then return end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 过滤并让玩家选择1到ct张（最多为自己墓地调整数量）对方场上可除外的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,ct,nil)
	if g:GetCount()>0 then
		-- 闪烁显示被选择的卡片。
		Duel.HintSelection(g)
		-- 以效果原因将选择的卡片表侧表示除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 结束阶段将暂时除外的此卡返回场上的处理函数。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将作为效果目标（之前被暂时除外）的此卡返回到场上。
	Duel.ReturnToField(e:GetLabelObject())
end
-- 效果②的发动条件：对方怪兽进行攻击宣言时。
function s.nacon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	return at:IsControler(1-tp)
end
-- 效果②的处理：无效那次攻击，并结束战斗阶段。
function s.naop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效当前的攻击，若成功则继续处理。
	if Duel.NegateAttack() then
		-- 中断当前效果处理，使后续的结束战斗阶段处理不与无效攻击同时发生。
		Duel.BreakEffect()
		-- 跳过当前的战斗阶段，使其直接进入结束步骤（即结束战斗阶段）。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- 效果③的发动检测与靶向：确认自己场上有空位且墓地有可以特殊召唤的「真红莲新星龙」，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：确认自己怪兽区有空位，且自己墓地存在满足特殊召唤条件的「真红莲新星龙」。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁中的操作信息：从自己墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 过滤条件：卡名为「真红莲新星龙」（97489701）且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsCode(97489701) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的处理：从自己墓地选择1只「真红莲新星龙」特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件且不受「王家长眠之谷」影响的「真红莲新星龙」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
