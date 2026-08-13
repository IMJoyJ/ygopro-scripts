--絵札の絆
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有「王后骑士」「卫兵骑士」「国王骑士」以外的怪兽存在的场合才能发动。从自己的手卡·墓地选「王后骑士」「卫兵骑士」「国王骑士」之内1只特殊召唤。
-- ②：从自己的手卡·墓地把「王后骑士」「卫兵骑士」「国王骑士」各最多1只除外才能发动。自己从卡组抽出除外的数量。
function c28340377.initial_effect(c)
	-- 注册代码列表，将本卡与「王后骑士」「国王骑士」「卫兵骑士」的卡号关联，用于效果文本中记载这些卡名的检索。
	aux.AddCodeList(c,25652259,64788463,90876561)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上没有「王后骑士」「卫兵骑士」「国王骑士」以外的怪兽存在的场合才能发动。从自己的手卡·墓地选「王后骑士」「卫兵骑士」「国王骑士」之内1只特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28340377,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,28340377)
	e2:SetCondition(c28340377.spcon)
	e2:SetTarget(c28340377.sptg)
	e2:SetOperation(c28340377.spop)
	c:RegisterEffect(e2)
	-- ②：从自己的手卡·墓地把「王后骑士」「卫兵骑士」「国王骑士」各最多1只除外才能发动。自己从卡组抽出除外的数量。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28340377,1))  --"除外并抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCountLimit(1,28340377)
	e3:SetCost(c28340377.drcost)
	e3:SetTarget(c28340377.drtg)
	e3:SetOperation(c28340377.drop)
	c:RegisterEffect(e3)
end
-- 定义过滤条件：怪兽须为表侧表示且卡名为「国王骑士」「王后骑士」「卫兵骑士」之一。
function c28340377.confilter(c)
	return c:IsFaceup() and c:IsCode(64788463,25652259,90876561)
end
-- 效果①的发动条件：自己场上不存在上述三张骑士以外的怪兽（场上没有怪兽或全部是骑士）。
function c28340377.spcon(e,tp)
	-- 获取自己主要怪兽区当前存在的所有怪兽。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g==0 or (#g>0 and g:FilterCount(c28340377.confilter,nil)==#g)
end
-- 定义特殊召唤对象过滤条件：卡名是上述三张骑士之一，且可以被当前效果特殊召唤。
function c28340377.spfilter(c,e,tp)
	return c:IsCode(64788463,25652259,90876561) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动目标判定：在发动阶段检查是否存在空位和符合条件的怪兽，并登记特殊召唤操作信息。
function c28340377.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在至少1张可特殊召唤的上述骑士怪兽。
		and Duel.IsExistingMatchingCard(c28340377.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记本次连锁为特殊召唤操作，使相关卡片（如「星尘龙」等）能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行效果①：选择1只符合条件的骑士怪兽从手卡·墓地以表侧表示特殊召唤到自己的主要怪兽区。
function c28340377.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认空位，若无空位则效果不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·墓地选择1只符合条件的骑士怪兽（并排除王家长眠之谷等影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28340377.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义代价对象过滤条件：卡名为骑士三张之一且可以作为代价除外。
function c28340377.cfilter(c)
	return c:IsCode(64788463,25652259,90876561) and c:IsAbleToRemoveAsCost()
end
-- 效果②的代价处理：从手卡·墓地选择「王后骑士」「卫兵骑士」「国王骑士」各最多1只（卡名各异，最多3只）作为代价除外，并将实际除外的数量记录到效果标签中。
function c28340377.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡·墓地中所有满足代价条件的骑士怪兽。
	local g=Duel.GetMatchingGroup(c28340377.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	local mt=g:GetClassCount(Card.GetCode)
	if chk==0 then return mt>0 end
	local ct=1
	for i=2,3 do
		-- 根据是否受“不能抽卡”限制，尝试将可抽数量提高到2或3。
		if Duel.IsPlayerCanDraw(tp,i) then ct=i end
	end
	if mt<ct then ct=mt end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从候选中选择1至ct张且卡名互不相同的骑士怪兽作为代价（以保证各最多1只）。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
	-- 执行除外处理，并把实际除外的卡数保存到效果标签，供后续抽卡阶段使用。
	e:SetLabel(Duel.Remove(sg,POS_FACEUP,REASON_COST))
end
-- 效果②的发动目标判定：确认自己至少可以抽1张卡，设定抽卡对象为自身、抽卡数量为代价除外的张数，并登记抽卡操作信息。
function c28340377.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己是否至少能抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	local ct=e:GetLabel()
	-- 将本次效果的抽卡对象玩家设为自己。
	Duel.SetTargetPlayer(tp)
	-- 将本次效果的抽卡数量参数设为之前记录的除外数量。
	Duel.SetTargetParam(ct)
	-- 登记抽卡操作信息，使系统及关联卡片能正确识别本次抽卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 执行效果②的抽卡处理：根据登记的目标玩家和数量进行抽卡。
function c28340377.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取出目标玩家p和抽卡数量d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
