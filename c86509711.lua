--マジシャンズ・コンビネーション
-- 效果：
-- ①：1回合1次，魔法·陷阱·怪兽的效果发动时，把自己场上1只「黑魔术师」或者「黑魔术少女」解放才能发动。从自己的手卡·墓地选和解放的怪兽卡名不同的1只「黑魔术师」或者「黑魔术少女」特殊召唤，那个发动的效果无效。
-- ②：魔法与陷阱区域的表侧表示的这张卡被送去墓地的场合才能发动。选场上1张卡破坏。
function c86509711.initial_effect(c)
	-- 在卡片中注册「黑魔术师」和「黑魔术少女」的卡名列表
	aux.AddCodeList(c,46986414,38033121)
	-- 「魔术师的配合」的卡片发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86509711,0))  --"发动但不使用效果"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，魔法·陷阱·怪兽的效果发动时，把自己场上1只「黑魔术师」或者「黑魔术少女」解放才能发动。从自己的手卡·墓地选和解放的怪兽卡名不同的1只「黑魔术师」或者「黑魔术少女」特殊召唤，那个发动的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86509711,1))  --"发动并使用①效果"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c86509711.spcon)
	e2:SetCost(c86509711.spcost)
	e2:SetTarget(c86509711.sptg)
	e2:SetOperation(c86509711.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
	-- ②：魔法与陷阱区域的表侧表示的这张卡被送去墓地的场合才能发动。选场上1张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c86509711.descon)
	e4:SetTarget(c86509711.destg)
	e4:SetOperation(c86509711.desop)
	c:RegisterEffect(e4)
end
-- 过滤场上可解放的「黑魔术师」或「黑魔术少女」的条件函数
function c86509711.cfilter(c,e,tp)
	-- 检查卡片是否为「黑魔术师」或「黑魔术少女」，是否可以解放，且解放后能腾出至少一个怪兽区域
	return c:IsCode(46986414,38033121) and c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0
		-- 且手卡或墓地存在至少1只与该卡卡名不同的、可以特殊召唤的「黑魔术师」或「黑魔术少女」
		and Duel.IsExistingMatchingCard(c86509711.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
-- 过滤手卡或墓地中与解放怪兽卡名不同、且可以特殊召唤的「黑魔术师」或「黑魔术少女」的条件函数
function c86509711.spfilter(c,e,tp,code)
	return not c:IsCode(code) and c:IsCode(46986414,38033121) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件函数：检查被连锁的效果是否可以被无效
function c86509711.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁的效果是否可以被无效
	return Duel.IsChainDisablable(ev)
end
-- 效果①的发动代价函数：设置标志值以在target中进行后续的解放处理
function c86509711.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 效果①的发动准备（target）函数：检查是否满足发动条件，并执行解放代价，设置特殊召唤和无效效果的操作信息
function c86509711.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在满足解放条件的怪兽，且本回合尚未发动过该效果
		return Duel.IsExistingMatchingCard(c86509711.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) and c:GetFlagEffect(86509711)==0
	end
	c:RegisterFlagEffect(86509711,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	-- 给玩家发送“选择要解放的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择自己场上1只满足条件的「黑魔术师」或「黑魔术少女」准备解放
	local g=Duel.SelectMatchingCard(tp,c86509711.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetCode())
	-- 将选择的怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
	-- 设置特殊召唤的操作信息，表示将从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	-- 设置无效效果的操作信息，表示将无效该连锁的发动
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果①的效果处理（operation）函数：从手卡或墓地特殊召唤怪兽，并无效对方的效果
function c86509711.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送“选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只与解放怪兽卡名不同的「黑魔术师」或「黑魔术少女」（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c86509711.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetLabel())
	-- 如果成功选出怪兽并将其表侧表示特殊召唤到自己场上
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 使该连锁发动的效果无效
		Duel.NegateEffect(ev)
	end
end
-- 效果②的发动条件函数：检查这张卡是否在魔法与陷阱区域表侧表示存在并被送去墓地
function c86509711.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_SZONE)
end
-- 效果②的发动准备（target）函数：检查场上是否存在可破坏的卡，并设置破坏的操作信息
function c86509711.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有的卡
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置破坏的操作信息，表示将破坏场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理（operation）函数：选择场上1张卡并将其破坏
function c86509711.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送“选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上任意1张卡
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显式地在场上框选并提示被选中的卡
		Duel.HintSelection(g)
		-- 因效果将选中的卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
