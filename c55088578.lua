--オノマトカゲ
-- 效果：
-- 这个卡名在规则上也当作「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上有「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽的其中任意种存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：把墓地的这张卡除外才能发动。从自己墓地让最多2只超量怪兽回到额外卡组。
local s,id,o=GetID()
-- 注册这张卡的两个起动效果：①效果为手卡·墓地发动、自己场上有「刷拉拉」「我我我」「隆隆隆」「怒怒怒」怪兽时自身特殊召唤（1回合1次，CountLimit为id）；②效果为墓地发动、支付把这张卡除外的代价、把自己墓地最多2只超量怪兽回到额外卡组（1回合1次，CountLimit为id+o）
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己场上有「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽的其中任意种存在的场合才能发动。这张卡特殊召唤。这个卡名的①的效果1回合只能使用1次
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
	-- ②：把墓地的这张卡除外才能发动。从自己墓地让最多2只超量怪兽回到额外卡组。这个卡名的②的效果1回合只能使用1次
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收超量怪兽"
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数：表侧表示且属于「刷拉拉」「我我我」「隆隆隆」「怒怒怒」系列之一的怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8f,0x54,0x59,0x82)
end
-- ①效果的发动条件检查：确认自己场上存在「刷拉拉」「我我我」「隆隆隆」「怒怒怒」怪兽的其中任意种
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区域是否存在至少1只表侧表示的上述系列怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的目标设定：先检查自己主要怪兽区是否有可用空格，且这张卡可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区域的可用空格数是否大于0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本连锁将把这张卡1张特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：这张卡特殊召唤成功后，赋予其从场上离开的场合除外的永续效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与连锁相关联且不受「王家长眠之谷」影响，然后将其表侧表示特殊召唤到自己场上
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：从自己墓地让最多2只超量怪兽回到额外卡组
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤函数：墓地中可以回到额外卡组的超量怪兽
function s.thfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsAbleToExtra()
end
-- ②效果的目标设定：检查自己墓地（除这张卡外）是否存在可回到额外卡组的超量怪兽，并设置回额外卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只（除发动的这张卡外的）超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置操作信息：声明本连锁将把玩家墓地预计1张卡回到额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的处理：让玩家从自己墓地选择最多2只超量怪兽回到额外卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送「请选择要返回卡组的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让自己玩家从自己墓地选择1～2只不受「王家长眠之谷」影响、可回到额外卡组的超量怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,2,nil)
	if g:GetCount()>0 then
		-- 显示所选卡的动画并记录这些卡被选择
		Duel.HintSelection(g)
		-- 把选择的卡以效果的原因回到额外卡组（返回底端后洗额外卡组）
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
