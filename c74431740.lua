--バスター・リブート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只「/爆裂体」怪兽解放才能发动。和那只怪兽卡名不同的1只「/爆裂体」怪兽无视召唤条件从卡组守备表示特殊召唤。
-- ②：把墓地的这张卡除外，以「爆裂再起」以外的自己墓地的有「爆裂模式」的卡名记述的卡以及「爆裂模式」任意数量为对象才能发动（同名卡最多1张）。那些卡回到卡组。
function c74431740.initial_effect(c)
	-- 注册卡片记述了「爆裂模式」（80280737）的卡片密码
	aux.AddCodeList(c,80280737)
	-- ①：把自己场上1只「/爆裂体」怪兽解放才能发动。和那只怪兽卡名不同的1只「/爆裂体」怪兽无视召唤条件从卡组守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetLabel(0)
	e1:SetCountLimit(1,74431740)
	e1:SetCost(c74431740.cost)
	e1:SetTarget(c74431740.target)
	e1:SetOperation(c74431740.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以「爆裂再起」以外的自己墓地的有「爆裂模式」的卡名记述的卡以及「爆裂模式」任意数量为对象才能发动（同名卡最多1张）。那些卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,74431741)
	-- 把墓地的这张卡除外作为发动成本
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c74431740.tdtg)
	e2:SetOperation(c74431740.tdop)
	c:RegisterEffect(e2)
end
-- 效果①的发动成本（Cost）暂存标记函数
function c74431740.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 效果①解放怪兽的过滤条件（必须是「/爆裂体」怪兽，且卡组存在与其卡名不同的可特召「/爆裂体」怪兽，且解放后有可用的怪兽区域）
function c74431740.cfilter(c,e,tp)
	-- 检查是否为「/爆裂体」怪兽，且卡组中存在与其卡名不同的可特殊召唤的「/爆裂体」怪兽
	return c:IsSetCard(0x104f) and Duel.IsExistingMatchingCard(c74431740.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
		-- 检查该怪兽解放后，自己场上是否有可用于特殊召唤的空怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①从卡组特殊召唤的怪兽的过滤条件（与解放的怪兽卡名不同、是「/爆裂体」怪兽、可以守备表示特殊召唤）
function c74431740.spfilter(c,e,tp,code)
	return not c:IsCode(code) and c:IsSetCard(0x104f) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备与目标确认函数（处理解放Cost并声明特殊召唤操作信息）
function c74431740.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在至少1只满足解放条件的怪兽
		return Duel.CheckReleaseGroup(tp,c74431740.cfilter,1,nil,e,tp)
	end
	-- 玩家选择1只满足解放条件的怪兽
	local rg=Duel.SelectReleaseGroup(tp,c74431740.cfilter,1,1,nil,e,tp)
	-- 将被解放怪兽的卡名保存为连锁参数，以便在效果处理时进行卡名比对
	Duel.SetTargetParam(rg:GetFirst():GetCode())
	-- 将选择的怪兽解放作为发动成本
	Duel.Release(rg,REASON_COST)
	-- 设置特殊召唤的操作信息（从卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（无视召唤条件从卡组守备表示特殊召唤）函数
function c74431740.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动时保存的被解放怪兽的卡名
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只与被解放怪兽卡名不同的「/爆裂体」怪兽
	local g=Duel.SelectMatchingCard(tp,c74431740.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,code)
	if g:GetCount()>0 then
		-- 将选择的怪兽无视召唤条件以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②返回卡组的目标卡片过滤条件（非「爆裂再起」、记述有「爆裂模式」或本身是「爆裂模式」的卡、可以回到卡组）
function c74431740.tdfilter(c,e)
	-- 过滤出非本名、且自身是「爆裂模式」或记述了「爆裂模式」且能回到卡组的卡
	return not c:IsCode(74431740) and aux.IsCodeOrListed(c,80280737) and c:IsAbleToDeck()
		and (not e or c:IsCanBeEffectTarget(e))
end
-- 效果②的发动准备与选择对象函数
function c74431740.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74431740.tdfilter(chkc) end
	-- 检查自己墓地是否存在至少1张满足条件的卡（排除自身）
	if chk==0 then return Duel.IsExistingTarget(c74431740.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 获取自己墓地中所有满足条件的卡（排除自身）
	local g=Duel.GetMatchingGroup(c74431740.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e)
	-- 设置卡片组检查函数，确保后续选择的卡片互不重名（同名卡最多1张）
	aux.GCheckAdditional=aux.dncheck
	-- 允许玩家选择任意数量（至少1张）且互不重名的卡
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,#g)
	-- 重置卡片组检查函数，避免影响后续的其他选择
	aux.GCheckAdditional=nil
	-- 将选择的卡片注册为效果的对象
	Duel.SetTargetCard(sg)
	-- 设置回到卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
end
-- 效果②的效果处理（将对象卡片回到卡组）函数
function c74431740.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍对该效果有效的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将这些卡送回持有者卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
