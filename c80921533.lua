--死皇帝の陵墓
-- 效果：
-- ①：双方玩家在自己主要阶段可以从以下效果选择1个发动。
-- ●支付1000基本分才能发动。不用解放来进行需要1只解放的手卡1只怪兽的通常召唤。
-- ●支付2000基本分才能发动。不用解放来进行需要2只解放的手卡1只怪兽的通常召唤。
function c80921533.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：双方玩家在自己主要阶段可以从以下效果选择1个发动。●支付1000基本分才能发动。不用解放来进行需要1只解放的手卡1只怪兽的通常召唤。●支付2000基本分才能发动。不用解放来进行需要2只解放的手卡1只怪兽的通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80921533,0))  --"通常召唤"
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(c80921533.target)
	e2:SetOperation(c80921533.operation)
	c:RegisterEffect(e2)
	-- 不用解放来进行需要1只解放的手卡1只怪兽的通常召唤。/不用解放来进行需要2只解放的手卡1只怪兽的通常召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c80921533.ntcon)
	e3:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e3)
	e2:SetLabelObject(e3)
end
-- 不用解放进行通常召唤的规则效果的允许条件判定函数
function c80921533.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查是否不需要解放且场上存在0个祭品
	return minc==0 and Duel.CheckTribute(c,0)
end
-- 过滤手牌中需要解放且可以通常召唤或盖放的怪兽
function c80921533.filter(c,se)
	if not c:IsSummonableCard() then return false end
	local mi,ma=c:GetTributeRequirement()
	return mi>0 and (c:IsSummonable(false,se) or c:IsMSetable(false,se))
end
-- 获取手牌中符合条件的怪兽的最小和最大祭品需求数量
function c80921533.get_targets(se,tp)
	-- 获取手牌中所有需要解放且可以通常召唤或盖放的怪兽组
	local g=Duel.GetMatchingGroup(c80921533.filter,tp,LOCATION_HAND,0,nil,se)
	local minct=5
	local maxct=0
	local tc=g:GetFirst()
	while tc do
		local mi,ma=tc:GetTributeRequirement()
		if mi>0 and mi<minct then minct=mi end
		if ma>maxct then maxct=ma end
		tc=g:GetNext()
	end
	return minct,maxct
end
-- 效果发动时的目标选择与基本分支付处理函数
function c80921533.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local se=e:GetLabelObject()
	if chk==0 then
		local mi,ma=c80921533.get_targets(se,tp)
		if mi==5 then return false end
		-- 检查玩家是否能够支付最少祭品数量对应的基本分
		return Duel.CheckLPCost(tp,mi*1000)
	end
	local mi,ma=c80921533.get_targets(se,tp)
	local ac=0
	-- 提示玩家选择要支付的基本分
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(80921533,3))  --"请选择要支付的基本分"
	-- 若手牌中符合条件的怪兽所需祭品数唯一，则玩家只能宣言并支付该数量对应的基本分
	if mi==ma then ac=Duel.AnnounceNumber(tp,mi*1000)
	-- 若存在需要2只解放的怪兽且玩家基本分充足，则让玩家选择宣言支付1000或2000基本分
	elseif ma>=2 and Duel.CheckLPCost(tp,2000) then ac=Duel.AnnounceNumber(tp,1000,2000)
	-- 否则玩家只能选择宣言支付1000基本分
	else ac=Duel.AnnounceNumber(tp,1000) end
	-- 扣除玩家宣言的基本分数值作为发动代价
	Duel.PayLPCost(tp,ac)
	e:SetLabel(ac/1000)
	-- 设置连锁信息，表示该效果包含通常召唤或盖放的操作
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 过滤手牌中祭品需求与支付的基本分相对应且可以通常召唤或盖放的怪兽
function c80921533.sfilter(c,se,ct)
	if not c:IsSummonableCard() then return false end
	local mi,ma=c:GetTributeRequirement()
	return (mi==ct or ma==ct) and (c:IsSummonable(false,se) or c:IsMSetable(false,se))
end
-- 效果处理函数，让玩家选择手牌中的怪兽并进行不用解放的通常召唤或盖放
function c80921533.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	local se=e:GetLabelObject()
	-- 提示玩家选择要召唤或盖放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手牌中选择1张符合支付基本分档位且可召唤或盖放的怪兽
	local g=Duel.SelectMatchingCard(tp,c80921533.sfilter,tp,LOCATION_HAND,0,1,1,nil,se,ct)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(false,se)
		local s2=tc:IsMSetable(false,se)
		-- 若该怪兽既能召唤也能盖放，则让玩家选择表示形式，否则默认进行召唤
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			-- 将选中的怪兽以表侧表示进行通常召唤
			Duel.Summon(tp,tc,false,se)
		else
			-- 将选中的怪兽以里侧守备表示进行通常召唤的盖放
			Duel.MSet(tp,tc,false,se)
		end
	end
end
