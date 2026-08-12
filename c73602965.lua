--白銀の城の執事 アリアス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把手卡·场上的这张卡送去墓地才能发动。从手卡把1只「拉比林斯迷宫」怪兽特殊召唤或把1张通常陷阱卡盖放。这个效果盖放的卡在盖放的回合也能发动。
-- ②：对方连锁「白银之城的执事 阿里亚斯」以外的自己的「拉比林斯迷宫」卡或通常陷阱卡的效果的发动把效果发动时才能把这个效果在墓地发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡/场上送墓发动，特召手卡「拉比林斯迷宫」怪兽或盖放通常陷阱）和②效果（对方连锁己方「拉比林斯迷宫」卡或通常陷阱发动效果时，在墓地特召自身）。
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，把手卡·场上的这张卡送去墓地才能发动。从手卡把1只「拉比林斯迷宫」怪兽特殊召唤或把1张通常陷阱卡盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tfcon)
	e1:SetCost(s.tfcost)
	e1:SetTarget(s.tftg)
	e1:SetOperation(s.tfop)
	c:RegisterEffect(e1)
	-- ②：对方连锁「白银之城的执事 阿里亚斯」以外的自己的「拉比林斯迷宫」卡或通常陷阱卡的效果的发动把效果发动时才能把这个效果在墓地发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：自己或对方的主要阶段。
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ①效果的发动代价：把手卡·场上的这张卡送去墓地。
function s.tfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将这张卡作为发动代价送去墓地。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤条件：手卡中可以盖放的陷阱卡。
function s.setfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- 过滤条件：手卡中可以特殊召唤的「拉比林斯迷宫」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备：检查手卡中是否存在可特召的「拉比林斯迷宫」怪兽（且怪兽区域有空位）或可盖放的通常陷阱卡。
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡中是否存在除这张卡以外的「拉比林斯迷宫」怪兽。
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
		-- 并且在送去墓地后，自己场上有可用于特殊召唤的怪兽区域。
		and Duel.GetMZoneCount(tp,c)>0
	-- 检查手卡中是否存在可以盖放的陷阱卡。
	local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil)
	if chk==0 then return b1 or b2 end
end
-- ①效果的处理：让玩家选择从手卡特殊召唤1只「拉比林斯迷宫」怪兽，或者盖放1张通常陷阱卡（该卡在盖放的回合也能发动）。
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此时手卡中是否存在可特召的「拉比林斯迷宫」怪兽，且怪兽区域有空位。
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 检查此时手卡中是否存在可盖放的通常陷阱卡。
	local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil)
	if not (b1 or b2) then return end
	-- 让玩家选择是进行特殊召唤（选项1）还是进行盖放（选项2）。
	local sel=aux.SelectFromOptions(tp,{b1,1152},{b2,1153})
	if sel==1 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从手卡选择1只满足条件的「拉比林斯迷宫」怪兽。
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选择的怪兽在自己场上表侧表示特殊召唤。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 提示玩家选择要盖放的陷阱卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 玩家从手卡选择1张不受墓地限制影响的通常陷阱卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_HAND,0,1,1,nil)
		local tc=g:GetFirst()
		-- 如果成功将选择的陷阱卡盖放到魔法与陷阱区域。
		if tc and Duel.SSet(tp,tc)~=0 then
			-- 这个效果盖放的卡在盖放的回合也能发动。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))  --"适用「白银之城的执事 阿里亚斯」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
-- ②效果的发动条件：对方连锁「白银之城的执事 阿里亚斯」以外的自己的「拉比林斯迷宫」卡或通常陷阱卡的效果的发动把效果发动时。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的连锁序号。
	local ct=Duel.GetCurrentChain()
	if ct<2 then return false end
	-- 获取前一个连锁（即被对方连锁的己方效果）的发动效果和发动玩家。
	local te,p=Duel.GetChainInfo(ct-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if not te then return false end
	local b1=te:GetHandler():IsSetCard(0x17e) and not te:GetHandler():IsCode(id)
	local b2=te:GetActiveType()==TYPE_TRAP
	return (b1 or b2) and p==tp and rp==1-tp
end
-- ②效果的发动准备：检查自身是否能从墓地特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：将墓地的这张卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，且这张卡是否仍存在于墓地。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 将墓地的这张卡特殊召唤到自己场上。
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end
