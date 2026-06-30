--オノマトカゲ
-- 效果：
-- 这个卡名在规则上也当作「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上有「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」怪兽的其中任意种存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：把墓地的这张卡除外才能发动。从自己墓地让最多2只超量怪兽回到额外卡组。
local s,id,o=GetID()
-- 注册该卡的①自身特殊召唤效果和②回收墓地超量怪兽效果
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
	-- 把墓地的这张卡除外作为效果发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤出自己场上表侧表示的「刷拉拉」、「我我我」、「隆隆隆」或「怒怒怒」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8f,0x54,0x59,0x82)
end
-- 检查自己场上是否存在满足条件的怪兽作为特殊召唤效果的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「刷拉拉」、「我我我」、「隆隆隆」或「怒怒怒」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的靶点检测，确认场上有空余怪兽区域且自身能够特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测当前玩家的主要怪兽区域是否有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置在效果处理时进行特殊召唤操作的连锁信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤这张卡，并在成功特殊召唤后为该卡注册离场时除外的重定向效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否与连锁相关、不受王家之谷影响并成功将其以表侧表示特殊召唤
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：把墓地的这张卡除外才能发动。从自己墓地让最多2只超量怪兽回到额外卡组。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤出墓地中可以回到额外卡组的超量怪兽
function s.thfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsAbleToExtra()
end
-- 回收效果的靶点检测，确认墓地中存在可回收的超量怪兽，并设置回收至额外卡组的连锁操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检测墓地是否存在至少1只可回收的超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置将墓地的卡片回到额外卡组的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_GRAVE)
end
-- 回收效果的效果处理，从自己墓地选择最多2只超量怪兽返回额外卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送“请选择要返回卡组的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 令玩家从自己墓地中选择1至2只可回收且不受王家之谷影响的超量怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,2,nil)
	if g:GetCount()>0 then
		-- 对选中的卡片组进行提示性选中标记并向对方展示
		Duel.HintSelection(g)
		-- 将选中的卡片通过效果返回持有者的额外卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
