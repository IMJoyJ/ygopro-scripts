--ゴーティス・チェイン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示的鱼族怪兽除外才能发动。原本卡名和为这张卡发动而除外的怪兽不同的1只「魊影」怪兽从自己的手卡·卡组·墓地·除外状态特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
local s,id,o=GetID()
-- 创建并注册本卡的发动效果：设置效果描述、特殊召唤分类、魔法卡发动类型、自由时点发动时机、提示时点、1回合1次限制，并绑定目标与处理函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只表侧表示的鱼族怪兽除外才能发动。原本卡名和为这张卡发动而除外的怪兽不同的1只「魊影」怪兽从自己的手卡·卡组·墓地·除外状态特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
-- 定义可作为发动代价的鱼族怪兽的过滤条件：需是表侧表示、鱼族、可作为代价除外，且除外后我方怪兽区仍有空位，同时存在至少1只符合条件的「魊影」怪兽可被特殊召唤。
function s.cfilter(c,e,tp)
	-- 检查该怪兽是否为表侧表示的鱼族、可作为代价除外，并且除外后我方怪兽区仍有空位。
	return c:IsFaceup() and c:IsRace(RACE_FISH) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
		-- 检查从手卡·卡组·墓地·除外状态中是否存在与所除外怪兽原本卡名不同的1只「魊影」怪兽可被特殊召唤。
		and Duel.IsExistingMatchingCard(s.filter,tp,0x33,0,1,nil,e,tp,c:GetOriginalCode())
end
-- 定义特殊召唤对象的过滤条件：需要是可以特殊召唤的「魊影」怪兽，且其原本卡名与作为代价除外的怪兽不同，并满足对应的表示形式条件。
function s.filter(c,e,tp,code)
	return c:IsFaceupEx() and c:IsSetCard(0x18a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsCode(code)
end
-- 发动时目标处理：先检查能否发动，再选择1只表侧表示的鱼族怪兽除外作为代价，记录其原本卡名，并设置本次效果为特殊召唤。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动确认阶段，若没有额外的必发处理且存在符合条件的鱼族怪兽可以作为代价，则允许发动。
	if chk==0 then return e:IsCostChecked() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家展示选择要除外的卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己场上选择1只满足条件的表侧表示鱼族怪兽作为代价。
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	-- 将选中的怪兽表侧表示除外，作为发动代价。
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	e:SetLabel(tc:GetOriginalCode())
	-- 设置操作信息：本次效果处理将从手卡·卡组·墓地·除外状态特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x33)
end
-- 效果处理函数：在怪兽区有空位时，从手卡·卡组·墓地·除外状态选择1只符合条件的「魊影」怪兽特殊召唤，并为特殊召唤成功的怪兽附加离场时除外的效果。
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 如果我方怪兽区没有可用空位，则效果处理直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向玩家展示选择要特殊召唤的卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地·除外状态选择1只满足条件且原本卡名与代价怪兽不同的「魊影」怪兽（使用王家长眠之谷过滤）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,0x33,0,1,1,nil,e,tp,e:GetLabel())
	-- 将选择的「魊影」怪兽表侧表示特殊召唤到我方场上，若特殊召唤成功则继续执行。
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		g:GetFirst():RegisterEffect(e1,true)
	end
end
