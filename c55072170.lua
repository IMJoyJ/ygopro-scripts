--ウィッチクラフト・マスターピース
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「魔女术」怪兽存在的场合，以自己或者对方的墓地1张魔法卡为对象才能发动。把1张那张卡的同名卡从自己卡组加入手卡。
-- ②：从自己墓地把这张卡和魔法卡任意数量除外才能发动。和除外的魔法卡数量相同等级的1只「魔女术」怪兽从卡组特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c55072170.initial_effect(c)
	-- ①：自己场上有「魔女术」怪兽存在的场合，以自己或者对方的墓地1张魔法卡为对象才能发动。把1张那张卡的同名卡从自己卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,55072170)
	e1:SetCondition(c55072170.condition)
	e1:SetTarget(c55072170.target)
	e1:SetOperation(c55072170.activate)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和魔法卡任意数量除外才能发动。和除外的魔法卡数量相同等级的1只「魔女术」怪兽从卡组特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55072170,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,55072171)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	-- 设置效果2的发动条件（这张卡送去墓地的回合不能发动）
	e2:SetCondition(aux.exccon)
	e2:SetCost(c55072170.spcost)
	e2:SetTarget(c55072170.sptg)
	e2:SetOperation(c55072170.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「魔女术」怪兽
function c55072170.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 效果1的发动条件：自己场上有「魔女术」怪兽存在
function c55072170.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「魔女术」怪兽
	return Duel.IsExistingMatchingCard(c55072170.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：墓地的魔法卡，且卡组中存在其同名卡
function c55072170.filter(c,tp)
	-- 检查卡片是否为魔法卡，且卡组中是否存在其同名卡并能加入手卡
	return c:IsType(TYPE_SPELL) and Duel.IsExistingMatchingCard(c55072170.filter2,tp,LOCATION_DECK,0,1,nil,c)
end
-- 过滤条件：卡组中与目标卡同名且能加入手卡的卡
function c55072170.filter2(c,tc)
	return c:IsCode(tc:GetCode()) and c:IsAbleToHand()
end
-- 效果1的发动准备（检查、选择对象、设置操作信息）
function c55072170.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c55072170.filter(chkc,tp) end
	-- 检查双方墓地是否存在满足条件的魔法卡作为对象
	if chk==0 then return Duel.IsExistingTarget(c55072170.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp) end
	-- 提示玩家选择要作为对象的墓地魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(55072170,0))  --"请选择要加入手卡的卡的同名卡"
	-- 选择双方墓地的一张魔法卡作为效果对象
	Duel.SelectTarget(tp,c55072170.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果1的运行处理（检索同名卡）
function c55072170.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果1选中的对象卡（墓地的魔法卡）
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张与对象卡同名的卡
	local g=Duel.SelectMatchingCard(tp,c55072170.filter2,tp,LOCATION_DECK,0,1,1,nil,tc)
	if g:GetCount()>0 then
		-- 将选择的同名卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果2的发动代价处理（设置标签以在target中处理除外代价）
function c55072170.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤条件：墓地中可以作为代价除外的魔法卡
function c55072170.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 过滤条件：卡组中等级在指定数值以下、可以特殊召唤的「魔女术」怪兽
function c55072170.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x128) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的发动准备（计算可除外数量、宣言等级、支付除外代价、设置操作信息）
function c55072170.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 获取自己墓地中所有可作为代价除外的魔法卡
		local cg=Duel.GetMatchingGroup(c55072170.cfilter,tp,LOCATION_GRAVE,0,nil)
		return c:IsAbleToRemoveAsCost()
			-- 检查自己场上是否有可用的怪兽区域
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查卡组中是否存在等级在可除外魔法卡数量以下的「魔女术」怪兽
			and Duel.IsExistingMatchingCard(c55072170.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,cg:GetCount())
	end
	-- 获取自己墓地中所有可作为代价除外的魔法卡
	local cg=Duel.GetMatchingGroup(c55072170.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取卡组中所有可以特殊召唤的「魔女术」怪兽（等级不超过可除外魔法卡的最大数量）
	local tg=Duel.GetMatchingGroup(c55072170.spfilter,tp,LOCATION_DECK,0,nil,e,tp,cg:GetCount())
	local lvt={}
	local tc=tg:GetFirst()
	while tc do
		local tlv=0
		tlv=tlv+tc:GetLevel()
		lvt[tlv]=tlv
		tc=tg:GetNext()
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 提示玩家选择要特殊召唤的怪兽的等级
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(55072170,2))  --"请选择要特殊召唤的怪兽的等级"
	-- 让玩家宣言一个要特殊召唤的怪兽的等级（即要除外的魔法卡数量）
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=cg:Select(tp,lv,lv,c)
	rg:AddCard(c)
	-- 将这张卡和选择的魔法卡从墓地除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(lv)
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：卡组中等级等于除外魔法卡数量、可以特殊召唤的「魔女术」怪兽
function c55072170.sfilter(c,e,tp,lv)
	return c:IsSetCard(0x128) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的运行处理（特殊召唤「魔女术」怪兽）
function c55072170.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张等级等于除外魔法卡数量的「魔女术」怪兽
	local g=Duel.SelectMatchingCard(tp,c55072170.sfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
	if #g>0 then
		-- 将选择的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
