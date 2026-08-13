--E-HERO デス・プリズン
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：「暗黑融合」的效果才能特殊召唤的融合怪兽在自己场上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：从卡组把1只「英雄」怪兽送去墓地才能发动。这个回合，「英雄」融合怪兽融合召唤的场合，表侧表示的这张卡可以作为那只融合怪兽有卡名记述的1只融合素材怪兽代用（其他的融合素材不能代用）。
local s,id,o=GetID()
-- 初始化这张卡的效果：①注册从手卡的规则特殊召唤效果（需要场上有暗黑融合特殊召唤的融合怪兽）；②注册起动效果，以从卡组送墓英雄怪兽为代价，本回合内此卡可作为英雄融合怪兽的融合素材代用。
function s.initial_effect(c)
	-- 将「暗黑融合」的卡号94820406加入卡片关联卡名列表，用于判定与「暗黑融合」相关的效果（如场上的融合怪兽是否具有暗黑融合特殊召唤标记）。
	aux.AddCodeList(c,94820406)
	-- ①：「暗黑融合」的效果才能特殊召唤的融合怪兽在自己场上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：从卡组把1只「英雄」怪兽送去墓地才能发动。这个回合，「英雄」融合怪兽融合召唤的场合，表侧表示的这张卡可以作为那只融合怪兽有卡名记述的1只融合素材怪兽代用（其他的融合素材不能代用）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.cost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡片表侧表示且带有“暗黑融合特殊召唤”的标记（即由「暗黑融合」的效果特殊召唤的融合怪兽）。
function s.cfilter(c)
	return c:IsFaceup() and c.dark_calling
end
-- ①特殊召唤的发动条件：这张卡在手卡时，若自己主要怪兽区有空位，且自己场上有满足s.cfilter的怪兽（由「暗黑融合」特殊召唤的表侧融合怪兽），则可以进行这个特殊召唤。
function s.spcon(e,c)
	if c==nil then return true end
	-- 确认自己场上主要怪兽区存在至少1个空格，以确保能特殊召唤这张卡。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 确认自己场上有至少1只表侧表示且由「暗黑融合」特殊召唤的融合怪兽（满足s.cfilter）。
		and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 代价选择条件：从卡组选1只「英雄」字段的怪兽卡，且可以作为代价送入墓地。
function s.costfilter(c,ec)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 代价处理：发动时需要从卡组选择1只「英雄」怪兽送入墓地作为代价；先检查是否存在可选的卡，若存在则让玩家选择并送墓。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检测（chk==0）：检查自己卡组是否存在至少1张满足s.costfilter的「英雄」怪兽，作为能否发动的前提。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,c) end
	-- 显示选择提示“请选择要送去墓地的卡”，引导玩家选择要作为代价送往墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己卡组选择1张满足s.costfilter的「英雄」怪兽，作为要送入墓地的代价。
	local cg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil,c)
	-- 将所选的卡以代价（REASON_COST）送入墓地，完成代价支付。
	Duel.SendtoGrave(cg,REASON_COST)
end
-- ②效果处理：若这张卡仍在场上且表侧表示，则给它赋予本回合内可作为「英雄」融合怪兽融合素材代用的效果，并注册客户端提示。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这个回合，「英雄」融合怪兽融合召唤的场合，表侧表示的这张卡可以作为那只融合怪兽有卡名记述的1只融合素材怪兽代用（其他的融合素材不能代用）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(s.subval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"代替素材效果适用中"
end
-- 代替素材的判定：只有被代替的融合素材是「英雄」字段的怪兽时，这张卡才能作为其代用，即不能代替其他字段的素材。
function s.subval(e,c)
	return c:IsSetCard(0x8)
end
