--EMポップアップ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把最多3张手卡送去墓地才能发动。自己从卡组抽出那个数量。那之后，可以把最多有这个效果抽出的数量的持有用自己的灵摆区域2张卡的灵摆刻度可以灵摆召唤的等级的「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽从手卡特殊召唤（同名卡最多1张）。没因这张卡的效果特殊召唤的场合，自己失去自己手卡数量×1000基本分。
function c11481610.initial_effect(c)
	-- ①：把最多3张手卡送去墓地才能发动。自己从卡组抽出那个数量。那之后，可以把最多有这个效果抽出的数量的持有用自己的灵摆区域2张卡的灵摆刻度可以灵摆召唤的等级的「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽从手卡特殊召唤（同名卡最多1张）。没因这张卡的效果特殊召唤的场合，自己失去自己手卡数量×1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11481610+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c11481610.cost)
	e1:SetTarget(c11481610.target)
	e1:SetOperation(c11481610.activate)
	c:RegisterEffect(e1)
end
-- 用于过滤满足条件的怪兽，包括属于「娱乐伙伴」、「魔术师」、「异色眼」系列且可以特殊召唤的灵摆怪兽
function c11481610.cfilter(c,e,tp,lsc,rsc)
	local lv=c:GetLevel()
	return (c:IsSetCard(0x9f,0x99) or (c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and lv>0 and lv>lsc and lv<rsc
end
-- 支付效果代价，将手卡送去墓地
function c11481610.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家手牌中可以作为效果代价送去墓地的卡组
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,e:GetHandler())
	if chk==0 then return g:GetCount()>0 end
	local ct=1
	for i=2,3 do
		-- 判断玩家是否可以抽卡，用于确定最多可以送入墓地的卡数
		if Duel.IsPlayerCanDraw(tp,i) then ct=i end
	end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:Select(tp,1,ct,nil)
	-- 将选择的卡送去墓地并记录送入墓地的卡数
	e:SetLabel(Duel.SendtoGrave(sg,REASON_COST))
end
-- 设置效果的发动目标
function c11481610.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	local ct=e:GetLabel()
	-- 设置效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数
	Duel.SetTargetParam(ct)
	-- 设置效果操作信息，表示将要进行抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 处理效果的发动
function c11481610.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家从卡组抽卡
	local ct=Duel.Draw(p,d,REASON_EFFECT)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local res=false
	-- 获取玩家左侧灵摆区域的卡
	local lc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	-- 获取玩家右侧灵摆区域的卡
	local rc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if ct>0 and ft>0 and lc and rc then
		local lsc=lc:GetLeftScale()
		local rsc=rc:GetRightScale()
		if lsc>rsc then lsc,rsc=rsc,lsc end
		-- 检查是否存在满足条件的怪兽可以特殊召唤，并询问玩家是否发动
		if Duel.IsExistingMatchingCard(c11481610.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp,lsc,rsc) and Duel.SelectYesNo(tp,aux.Stringid(11481610,0)) then  --"是否从手卡特殊召唤？"
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			ct=math.min(ct,ft)
			-- 如果玩家受到效果影响，则限制特殊召唤数量为1
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
			-- 获取满足条件的怪兽组
			local g=Duel.GetMatchingGroup(c11481610.cfilter,tp,LOCATION_HAND,0,nil,e,tp,lsc,rsc)
			-- 从满足条件的怪兽组中选择满足条件的子组
			local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
			-- 将选择的怪兽特殊召唤到场上
			res=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0
		end
	end
	if not res then
		-- 获取玩家手牌数量
		local lp=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		-- 根据手牌数量扣除基本分
		Duel.SetLP(tp,Duel.GetLP(tp)-lp*1000)
	end
end
