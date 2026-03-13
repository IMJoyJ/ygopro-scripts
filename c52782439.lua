--特別ダイヤ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1张「临时行车时间表」或「紧急行车时间表」加入手卡。那之后，可以在对方场上把1只「行车时间表衍生物」（机械族·地·10星·攻/守3000）特殊召唤。
-- ②：把墓地的这张卡除外，以自己的墓地·除外状态的1只机械族·10星怪兽为对象才能发动。自己场上1张卡送去墓地，作为对象的怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片的两个效果，分别是检索和特殊召唤效果
function s.initial_effect(c)
	-- 记录该卡与「临时行车时间表」和「紧急行车时间表」的关联
	aux.AddCodeList(c,25274141,97520701)
	-- ①：从卡组把1张「临时行车时间表」或「紧急行车时间表」加入手卡。那之后，可以在对方场上把1只「行车时间表衍生物」（机械族·地·10星·攻/守3000）特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己的墓地·除外状态的1只机械族·10星怪兽为对象才能发动。自己场上1张卡送去墓地，作为对象的怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 检索过滤器，用于筛选「临时行车时间表」或「紧急行车时间表」
function s.thfilter(c)
	return c:IsCode(25274141,97520701) and c:IsAbleToHand()
end
-- 效果处理目标函数，检查是否能从卡组检索符合条件的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示要进行检索操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行检索和可能的衍生物特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选的卡
		Duel.ConfirmCards(1-tp,g)
		-- 检查对方场上是否有可用怪兽区域
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			-- 检查是否可以特殊召唤衍生物
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,3000,3000,10,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP,1-tp)
			-- 询问玩家是否要特殊召唤衍生物
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤衍生物？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 创建衍生物卡片对象
			local token=Duel.CreateToken(tp,id+o)
			-- 将衍生物特殊召唤到对方场上
			Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
-- 特殊召唤过滤器，用于筛选机械族10星的怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_MACHINE) and c:IsLevel(10)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 送去墓地过滤器，用于选择可以送去墓地的卡
function s.cfilter(c,tp,chk)
	-- 判断卡是否可以送去墓地并检查是否有可用区域
	return c:IsAbleToGrave() and (not chk or Duel.GetMZoneCount(tp,c)>0)
end
-- 特殊召唤效果的目标函数，设置目标和条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	-- 检查是否存在满足特殊召唤条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		-- 检查是否存在可以送去墓地的卡
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,true) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息，表示要将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
	-- 设置操作信息，表示要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果处理函数，执行送去墓地和特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	local g=Group.CreateGroup()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 检查是否存在可以送去墓地的卡
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,true) then
		-- 选择满足条件的卡送去墓地
		g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp,true)
	else
		-- 选择满足条件的卡送去墓地
		g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp,false)
	end
	-- 判断是否满足特殊召唤条件并执行特殊召唤
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		-- 判断目标怪兽是否与连锁相关且未受王家长眠之谷影响
		and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 刷新场地信息
		Duel.AdjustAll()
		-- 将目标怪兽特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
