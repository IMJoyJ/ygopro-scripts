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
-- 过滤符合灵摆刻度可特殊召唤的「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽
function c11481610.cfilter(c,e,tp,lsc,rsc)
	local lv=c:GetLevel()
	return (c:IsSetCard(0x9f,0x99) or (c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and lv>0 and lv>lsc and lv<rsc
end
-- 发动代价：把最多3张手卡送去墓地
function c11481610.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡中可以作为代价送去墓地的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,e:GetHandler())
	if chk==0 then return g:GetCount()>0 end
	local ct=1
	for i=2,3 do
		-- 根据玩家可抽卡数量计算最多可送去墓地的手卡数量
		if Duel.IsPlayerCanDraw(tp,i) then ct=i end
	end
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:Select(tp,1,ct,nil)
	-- 将选择的卡作为代价送去墓地，并记录送去墓地的数量
	e:SetLabel(Duel.SendtoGrave(sg,REASON_COST))
end
-- 设置效果目标：设置抽卡数量并声明抽卡操作
function c11481610.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否至少能抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	local ct=e:GetLabel()
	-- 设置当前玩家为效果目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为送去墓地的卡片数量
	Duel.SetTargetParam(ct)
	-- 设置操作信息：抽送去墓地数量的卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果处理：抽卡，随后可选特殊召唤符合条件的怪兽，若未特殊召唤则扣除基本分
function c11481610.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家与抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡并获取实际抽卡数量
	local ct=Duel.Draw(p,d,REASON_EFFECT)
	-- 获取自身主要怪兽区域空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local res=false
	-- 获取左侧灵摆区域的卡
	local lc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	-- 获取右侧灵摆区域的卡
	local rc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if ct>0 and ft>0 and lc and rc then
		local lsc=lc:GetLeftScale()
		local rsc=rc:GetRightScale()
		if lsc>rsc then lsc,rsc=rsc,lsc end
		-- 检查手卡是否有符合条件的怪兽并让玩家选择是否特殊召唤
		if Duel.IsExistingMatchingCard(c11481610.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp,lsc,rsc) and Duel.SelectYesNo(tp,aux.Stringid(11481610,0)) then  --"是否从手卡特殊召唤？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			ct=math.min(ct,ft)
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
			-- 获取手卡中所有符合条件的怪兽
			local g=Duel.GetMatchingGroup(c11481610.cfilter,tp,LOCATION_HAND,0,nil,e,tp,lsc,rsc)
			-- 选择最多为抽卡数量且卡名各不相同的怪兽组
			local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
			-- 将选择的怪兽表侧表示特殊召唤
			res=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0
		end
	end
	if not res then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 获取手卡数量
		local lp=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		-- 失去手卡数量×1000的基本分
		Duel.SetLP(tp,Duel.GetLP(tp)-lp*1000)
	end
end
