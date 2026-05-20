--オノマトカゲ
-- 效果：
-- 这个卡名在规则上也当作「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上有「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽的其中任意种存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：把墓地的这张卡除外才能发动。从自己墓地让最多2只超量怪兽回到额外卡组。
local s,id,o=GetID()
-- 初始化效果：注册①效果（手卡·墓地特殊召唤）与②效果（墓地除外回收超量怪兽）
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己场上有「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽的其中任意种存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己墓地让最多2只超量怪兽回到额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收超量怪兽"
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 将墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8f,0x54,0x59,0x82)
end
-- ①效果的发动条件：自己场上存在满足条件的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动准备：检查怪兽区域空位并确认自身是否可以特殊召唤，设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域，且这张卡可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，涉及卡片为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：将自身特殊召唤，并添加离场时除外的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身仍存在于原本位置且不受「王家之谷」影响，将自身特殊召唤
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：把墓地的这张卡除外才能发动。从自己墓地让最多2只超量怪兽回到额外卡组。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤条件：墓地的超量怪兽且能回到额外卡组
function s.thfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsAbleToExtra()
end
-- ②效果的发动准备：检查墓地是否存在超量怪兽，设置回到额外卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可以回到额外卡组的超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置回到额外卡组的操作信息，涉及墓地的1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的处理：选择自己墓地最多2只超量怪兽回到额外卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己墓地1到2只不受「王家之谷」影响的超量怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,2,nil)
	if g:GetCount()>0 then
		-- 对选中的卡片进行效果对象确认的视觉提示
		Duel.HintSelection(g)
		-- 将选中的怪兽送回额外卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
