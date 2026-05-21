--破壊の代行者 ヴィーナス
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己墓地把1只「创造之代行者 维纳斯」除外才能发动。这张卡从手卡特殊召唤。
-- ②：支付500的倍数的基本分，从自己墓地的怪兽以及除外的自己怪兽之中以支付的基本分每500为1只的「神圣球体」为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合回到持有者卡组最下面。
function c99054885.initial_effect(c)
	-- ①：从自己墓地把1只「创造之代行者 维纳斯」除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99054885,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,99054885)
	e1:SetCost(c99054885.sscost)
	e1:SetTarget(c99054885.sstg)
	e1:SetOperation(c99054885.ssop)
	c:RegisterEffect(e1)
	-- ②：支付500的倍数的基本分，从自己墓地的怪兽以及除外的自己怪兽之中以支付的基本分每500为1只的「神圣球体」为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合回到持有者卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99054885,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,99054885)
	e2:SetCost(c99054885.spcost)
	e2:SetTarget(c99054885.sptg)
	e2:SetOperation(c99054885.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以作为发动代价除外的「创造之代行者 维纳斯」
function c99054885.ssfilter(c)
	return c:IsCode(64734921) and c:IsAbleToRemoveAsCost()
end
-- ①号效果的发动代价：从自己墓地将1只「创造之代行者 维纳斯」除外
function c99054885.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可以作为代价除外的「创造之代行者 维纳斯」
	if chk==0 then return Duel.IsExistingMatchingCard(c99054885.ssfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地中的1只「创造之代行者 维纳斯」
	local g=Duel.SelectMatchingCard(tp,c99054885.ssfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①号效果的发动准备：检查自身是否能特殊召唤并设置操作信息
function c99054885.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的处理：将手牌中的这张卡特殊召唤
function c99054885.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己墓地或除外状态的、可以作为效果对象并特殊召唤的「神圣球体」
function c99054885.spfilter(c,e,tp)
	return c:IsCode(39552864) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsCanBeEffectTarget(e) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- ②号效果的发动代价：计算并支付500的倍数的基本分
function c99054885.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查自己是否能支付至少500基本分且场上有空余怪兽区域
	if chk==0 then return Duel.CheckLPCost(tp,500,true) and ft>0 end
	-- 获取玩家当前的生命值
	local lp=Duel.GetLP(tp)
	-- 获取自己墓地及除外状态中所有满足条件的「神圣球体」
	local g=Duel.GetMatchingGroup(c99054885.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	local ct=g:GetCount()
	if ct>ft then ct=ft end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	local t={}
	for i=1,ct do
		-- 如果无法支付对应的基本分，则停止增加可选数量
		if not Duel.CheckLPCost(tp,i*500,true) then break end
		t[i]=i
	end
	-- 提示玩家选择要特殊召唤的怪兽数量
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(99054885,2))  --"请选择要特殊召唤的怪兽的数量"
	-- 让玩家选择要特殊召唤的「神圣球体」数量（即确定支付基本分的倍数）
	local announce=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 玩家支付对应数量乘以500的基本分
	Duel.PayLPCost(tp,announce*500,true)
	e:SetLabel(announce)
end
-- ②号效果的发动准备：选择对应数量的「神圣球体」作为效果对象
function c99054885.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c99054885.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地或除外状态是否存在至少1只可以作为对象的「神圣球体」
		and Duel.IsExistingTarget(c99054885.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	local ct=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择与支付基本分数量相等的「神圣球体」作为效果对象
	local g=Duel.SelectTarget(tp,c99054885.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,ct,ct,nil,e,tp)
	-- 设置特殊召唤这些对象怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- ②号效果的处理：将作为对象的怪兽特殊召唤，并添加离场时回到卡组最下面的效果
function c99054885.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local c=e:GetHandler()
	-- 获取作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	local tc=sg:GetFirst()
	while tc do
		-- 将目标怪兽表侧表示特殊召唤到自己场上（分步处理）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽从场上离开的场合回到持有者卡组最下面。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		tc:RegisterEffect(e1)
		tc=sg:GetNext()
	end
	-- 完成所有分步特殊召唤的处理
	Duel.SpecialSummonComplete()
end
