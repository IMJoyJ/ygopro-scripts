--白き龍の威光
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：选自己的手卡·场上（表侧表示）·墓地最多3只「青眼白龙」，给双方确认。那之后，确认数量的对方场上的卡破坏。
-- ②：把墓地的这张卡除外才能发动。等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的「青眼白龙」解放，从手卡把1只仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 注册「白龙的威光」的①②两个效果：①为场上发动的破坏效果；②为墓地除外自身进行仪式召唤的效果，并登记效果文中对应的「青眼白龙」卡名。
function s.initial_effect(c)
	-- 登记本卡效果文中记载的卡名「青眼白龙」（89631139），使相关联动效果可识别该卡名。
	aux.AddCodeList(c,89631139)
	-- ①：选自己的手卡·场上（表侧表示）·墓地最多3只「青眼白龙」，给双方确认。那之后，确认数量的对方场上的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 为②效果生成仪式召唤处理：以「青眼白龙」为解放素材，素材等级合计等于仪式怪兽的等级，从手卡进行仪式召唤。
	local e2=aux.AddRitualProcEqual2(c,nil,nil,nil,s.mfilter,true)
	e2:SetDescription(aux.Stringid(id,1))  --"仪式召唤"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置②效果的发动代价为把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	c:RegisterEffect(e2)
end
-- 筛选条件：卡名为「青眼白龙」的卡，以IsFaceupEx判断表示状态来覆盖手卡·场上（表侧表示）·墓地三种位置。
function s.chkfilter(c)
	return c:IsFaceupEx() and c:IsCode(89631139)
end
-- ①效果发动时点检查：自己的手卡/场上（表侧表示）/墓地存在至少1只「青眼白龙」，并且对方场上有卡，满足才可发动。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己在手卡·场上（表侧表示）·墓地是否存在至少1只「青眼白龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1张卡。
		and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的全部卡，作为后续破坏的候选集合。
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：宣告本效果将进行破坏，并将对方场上的卡作为破坏候选对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果实际处理：从自己的手卡/场上/墓地选择最多3只「青眼白龙」给对方确认，然后选择相同数量的对方场上的卡破坏。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新获取对方场上的全部卡，以应对发动后场况变化。
	local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 处理时重新获取自己手卡/场上/墓地的所有「青眼白龙」，作为可选确认对象。
	local g=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,nil)
	local ct=math.min(3,math.min(dg:GetCount(),g:GetCount()))
	if ct==0 then return end
	-- 弹出选择提示，要求玩家选择要展示给对方确认的「青眼白龙」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local rg=g:Select(tp,1,ct,nil)
	if rg:GetCount()>0 then
		local hg=rg:Filter(Card.IsLocation,nil,LOCATION_HAND)
		local og=rg-hg
		-- 将选中的手卡中的「青眼白龙」展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,hg)
		-- 对选中的非手卡部分（场上表侧表示或墓地的「青眼白龙」）显示选中动画，并记录为对象。
		Duel.HintSelection(og)
		if hg:GetCount()>=1 then
			-- 由于展示过手卡，效果处理完毕后洗切自己的手卡。
			Duel.ShuffleHand(tp)
		end
		-- 弹出选择提示，要求玩家选择要破坏的对方场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=dg:Select(tp,rg:GetCount(),rg:GetCount(),nil)
		-- 对选出的要破坏的卡显示选中动画。
		Duel.HintSelection(sg)
		-- 以效果名义破坏选中的对方场上的卡。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- 仪式召唤素材过滤：只允许选择「青眼白龙」作为解放素材，并且不会选择效果自身卡（即墓地的这张魔法卡）。
function s.mfilter(c,e,tp,chk)
	return (not chk or c~=e:GetHandler()) and c:IsCode(89631139)
end
