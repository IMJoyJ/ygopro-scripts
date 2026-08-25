--EMポップアップ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把最多3张手卡送去墓地才能发动。自己从卡组抽出那个数量。那之后，可以把最多有这个效果抽出的数量的持有用自己的灵摆区域2张卡的灵摆刻度可以灵摆召唤的等级的「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽从手卡特殊召唤（同名卡最多1张）。没因这张卡的效果特殊召唤的场合，自己失去自己手卡数量×1000基本分。
function c11481610.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把最多3张手卡送去墓地才能发动。自己从卡组抽出那个数量。那之后，可以把最多有这个效果抽出的数量的持有用自己的灵摆区域2张卡的灵摆刻度可以灵摆召唤的等级的「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽从手卡特殊召唤（同名卡最多1张）。没因这张卡的效果特殊召唤的场合，自己失去自己手卡数量×1000基本分。
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
-- 过滤函数：判定手卡中的怪兽是否为「娱乐伙伴」「异色眼」怪兽，或「魔术师」灵摆怪兽，且等级介于己方灵摆区域两张卡的灵摆刻度之间，并能被效果特殊召唤。
function c11481610.cfilter(c,e,tp,lsc,rsc)
	local lv=c:GetLevel()
	return (c:IsSetCard(0x9f,0x99) or (c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and lv>0 and lv>lsc and lv<rsc
end
-- 代价处理：从手卡选择1到最多3张卡作为代价送去墓地，并将实际送入墓地的数量记录到效果标签中，用于后续抽卡；选择上限还受到玩家能否抽对应张数的影响。
function c11481610.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡中所有可以作为代价送去墓地的卡组，并排除效果发动者自身。
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,e:GetHandler())
	if chk==0 then return g:GetCount()>0 end
	local ct=1
	for i=2,3 do
		-- 检查玩家是否能抽i张卡，若能则更新可选择送墓数量上限为i，最终得到1到3之间允许的最大送墓数。
		if Duel.IsPlayerCanDraw(tp,i) then ct=i end
	end
	-- 向玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:Select(tp,1,ct,nil)
	-- 将选择的手卡全部送去墓地作为代价，并把实际送入墓地的卡数存入效果标签，供后续抽卡阶段使用。
	e:SetLabel(Duel.SendtoGrave(sg,REASON_COST))
end
-- 发动时目标设定：确认自己至少能抽1张卡，并将抽卡对象设置为自己、抽卡数量设置为代价送墓的数量，同时设置操作信息为抽卡效果。
function c11481610.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己必须至少能抽1张卡才能发动（因为至少需要送墓1张手卡）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	local ct=e:GetLabel()
	-- 将本连锁的对象玩家设置为发动者自己，表示抽卡由自己进行。
	Duel.SetTargetPlayer(tp)
	-- 将本连锁的对象参数设置为要抽的卡数ct，即代价阶段送墓的卡数。
	Duel.SetTargetParam(ct)
	-- 设置操作信息：本连锁包含抽卡效果，目标玩家为自己，预计抽ct张卡，用于配合其他卡的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果处理：先抽与代价送墓数量相同的卡；若抽卡数大于0、己方主怪兽区有空位且灵摆区域有2张卡，则询问玩家是否特殊召唤；若选择是，则从手卡选择最多（实际抽卡数）只符合条件的且卡名不同的怪兽特殊召唤；若最终没有特殊召唤任何怪兽，则失去手卡数×1000基本分。
function c11481610.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家p和对象参数d，即抽卡对象与预定抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家p抽d张卡，返回实际抽到的卡数ct（可能因抽卡限制少于预期）。
	local ct=Duel.Draw(p,d,REASON_EFFECT)
	-- 获取己方主要怪兽区可用的空格数，用于限制后续特殊召唤的数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local res=false
	-- 获取己方灵摆区域左格的卡，若没有则为nil，用于读取灵摆刻度。
	local lc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	-- 获取己方灵摆区域右格的卡，若没有则为nil，用于读取灵摆刻度。
	local rc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if ct>0 and ft>0 and lc and rc then
		local lsc=lc:GetLeftScale()
		local rsc=rc:GetRightScale()
		if lsc>rsc then lsc,rsc=rsc,lsc end
		-- 检查手卡中是否存在至少1只满足条件且能特殊召唤的怪兽，若存在则询问玩家是否从手卡进行特殊召唤。
		if Duel.IsExistingMatchingCard(c11481610.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp,lsc,rsc) and Duel.SelectYesNo(tp,aux.Stringid(11481610,0)) then  --"是否从手卡特殊召唤？"
			-- 中断当前效果链，使后续特殊召唤作为独立效果处理，避免错过时点。
			Duel.BreakEffect()
			ct=math.min(ct,ft)
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
			-- 获取手卡中所有满足条件（字段、等级在灵摆刻度之间、可特殊召唤）的怪兽组g。
			local g=Duel.GetMatchingGroup(c11481610.cfilter,tp,LOCATION_HAND,0,nil,e,tp,lsc,rsc)
			-- 让玩家从符合条件的怪兽中选择1到ct只，并保证所选卡名互不相同（同名卡最多1张），返回选择组sg。
			local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
			-- 将选择的手卡怪兽以表侧表示特殊召唤到自己场上，返回是否至少成功特殊召唤1只，存入res。
			res=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0
		end
	end
	if not res then
		Duel.BreakEffect()
		local lp=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		-- 减少发动者LP，数值为手卡数量×1000，即每有1张手卡失去1000基本分。
		Duel.SetLP(tp,Duel.GetLP(tp)-lp*1000)
	end
end
