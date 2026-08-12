--レグルスの矢
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「圣月之皇太子 雷古勒斯」存在的场合，可以从以下效果选择1个发动。
-- ●把这个回合进行过战斗的对方场上1只怪兽破坏。
-- ●通常·速攻魔法卡发动时才能发动。那个效果无效。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「圣月之皇太子 雷古勒斯」或者有那个卡名记述的怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（发动并选择效果）和②效果（墓地除外特召）。
function s.initial_effect(c)
	-- 注册该卡记述了卡号为96228804（圣月之皇太子 雷古勒斯）的卡片。
	aux.AddCodeList(c,96228804)
	-- ①：自己场上有「圣月之皇太子 雷古勒斯」存在的场合，可以从以下效果选择1个发动。●把这个回合进行过战斗的对方场上1只怪兽破坏。●通常·速攻魔法卡发动时才能发动。那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_CHAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「圣月之皇太子 雷古勒斯」或者有那个卡名记述的怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	-- 设置效果②的cost为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示存在的「圣月之皇太子 雷古勒斯」。
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(96228804)
end
-- 效果①的发动条件：自己场上有「圣月之皇太子 雷古勒斯」存在。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「圣月之皇太子 雷古勒斯」。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：这个回合进行过战斗的怪兽。
function s.desfilter(c)
	return c:GetBattledGroupCount()>0
end
-- 效果①的发动准备与分支选择：检查并选择“破坏进行过战斗的怪兽”或“无效通常/速攻魔法卡的发动”，并设置相应的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只这个回合进行过战斗的怪兽（分支1可行性）。
	local b1=Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil)
	-- 获取当前的连锁序号。
	local ch=Duel.GetCurrentChain()
	local b2=false
	local og=Group.CreateGroup()
	local tse=nil
	if e:GetHandler():IsStatus(STATUS_CHAINING) then ch=ch-1 end
	if ch>0 then
		-- 获取当前连锁中正在发动的效果对象。
		tse=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT)
		b2=tse:IsHasType(EFFECT_TYPE_ACTIVATE)
			-- 检查该效果是否为速攻魔法或通常魔法的发动，且该效果可以被无效（分支2可行性）。
			and (tse:IsActiveType(TYPE_QUICKPLAY) or tse:GetHandler():GetType()==TYPE_SPELL) and Duel.IsChainDisablable(ev)
	end
	if chk==0 then return b1 or b2 end
	-- 让玩家从可用的分支效果中选择一个发动。
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},  --"破坏"
		{b2,aux.Stringid(id,3),2})  --"效果无效"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 获取对方场上所有这个回合进行过战斗的怪兽。
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
		-- 设置操作信息：预计破坏1只符合条件的怪兽。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_DISABLE)
		-- 设置操作信息：预计无效卡片效果。
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,og,1,0,0)
	end
end
-- 效果①的处理函数：根据玩家选择的分支，执行破坏怪兽或无效魔法卡效果的操作。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择对方场上1只这个回合进行过战斗的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			-- 选中目标怪兽并显示选择动画。
			Duel.HintSelection(g)
			-- 因效果破坏选中的怪兽。
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif e:GetLabel()==2 then
		-- 获取当前的连锁序号。
		local ch=Duel.GetCurrentChain()
		-- 无效前一个连锁（即要无效的魔法卡）的效果。
		Duel.NegateEffect(ch-1)
	end
end
-- 过滤条件：墓地中可以特殊召唤的「圣月之皇太子 雷古勒斯」或记述了该卡名的怪兽。
function s.spfilter(c,e,tp)
	-- 检查卡片是否为「圣月之皇太子 雷古勒斯」或记述了该卡名，且能被特殊召唤。
	return aux.IsCodeOrListed(c,96228804) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查怪兽区域空位、墓地中是否存在符合条件的目标，并进行取对象和设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只符合特召条件的目标怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤选中的目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理函数：将选中的目标怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍与连锁相关，且不受「王家长眠之谷」的影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
