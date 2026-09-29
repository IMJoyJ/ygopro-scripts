--レイズ・ムーンの煌めき
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次，①②的效果发动的决斗中，自己不能用抽卡以外的方法从卡组把卡加入手卡。
-- ①：从额外卡组把1只「盈彩月夜」超量怪兽特殊召唤，把这张卡作为那超量素材。那之后，可以让自己墓地的「盈彩月夜」卡全部回到卡组。
-- ②：把墓地的这张卡除外才能发动。自己抽1张。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- ①：从额外卡组把1只「盈彩月夜」超量怪兽特殊召唤，把这张卡作为那超量素材。那之后，可以让自己墓地的「盈彩月夜」卡全部回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次，②：把墓地的这张卡除外才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡效果"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- ①②的效果发动的决斗中，自己不能用抽卡以外的方法从卡组把卡加入手卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(s.checkop)
		-- 全局注册监听从卡组把卡加入手卡的处理
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局监测：记录是否有玩家非抽卡从卡组把卡加入手卡
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历加入手卡的卡片组
	for tc in aux.Next(eg) do
		if not tc:IsReason(REASON_DRAW) and tc:IsPreviousLocation(LOCATION_DECK) then
			-- 为对应玩家注册非抽卡检索过的标记
			Duel.RegisterFlagEffect(rp,id,0,0,1)
		end
	end
end
-- 发动Cost：确认本局未非抽卡检索，并施加决斗中不能从卡组把卡加入手卡的限制
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本局决斗中自己是否尚未用抽卡以外的方法从卡组把卡加入手卡
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- ①②的效果发动的决斗中，自己不能用抽卡以外的方法从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	-- 设置限制对象为卡组中的卡
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	-- 对玩家注册决斗中不能把卡组的卡加入手卡的限制
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：额外卡组的「盈彩月夜」超量怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1ec) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认额外怪兽区或主要怪兽区有可特殊召唤的空格
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动检查与设置操作信息：从额外卡组特殊召唤「盈彩月夜」超量怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 确认额外卡组存在可特殊召唤的「盈彩月夜」超量怪兽且自身可以作为超量素材
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		and e:GetHandler():IsCanOverlay() end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤条件：墓地的「盈彩月夜」卡
function s.tdfilter(c)
	return c:IsSetCard(0x1ec) and c:IsAbleToDeck()
end
-- 效果处理：特殊召唤「盈彩月夜」超量怪兽并垫为素材，之后可选墓地「盈彩月夜」卡全部回卡组
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只「盈彩月夜」超量怪兽
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	-- 将选中的超量怪兽表侧表示特殊召唤
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsLocation(LOCATION_MZONE)
		and c:IsLocation(LOCATION_ONFIELD) and c:IsRelateToChain() and c:IsCanOverlay() then
		c:CancelToGrave()
		-- 将这张卡作为该超量怪兽的超量素材叠放
		Duel.Overlay(tc,Group.FromCards(c))
		-- 确认墓地是否存在「盈彩月夜」卡
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,1,nil)
			-- 玩家选择是否让自己墓地的「盈彩月夜」卡全部回到卡组
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让卡回到卡组？"
			-- 中断效果处理（分割前后时点）
			Duel.BreakEffect()
			-- 获取自己墓地全部不受王家长眠之谷影响的「盈彩月夜」卡
			local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,nil)
			-- 检查并处理王家长眠之谷的无效判定
			if aux.NecroValleyNegateCheck(g) then return end
			-- 将墓地的「盈彩月夜」卡全部回到卡组并洗切卡组
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 发动Cost：除外墓地的自身并施加决斗检索限制
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地的这张卡是否能除外作为Cost且满足发动限制
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and s.cost(e,tp,eg,ep,ev,re,r,rp,chk) end
	-- 将墓地的这张卡除外作为Cost
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
end
-- 效果发动检查与设置操作信息：自己抽1张卡
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1
	Duel.SetTargetParam(1)
	-- 设置操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：自己抽1张卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取抽卡的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 目标玩家从卡组抽1张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
