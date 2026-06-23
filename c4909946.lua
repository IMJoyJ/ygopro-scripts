--ボスオンパレード
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，从卡组把1只「巨大战舰」怪兽加入手卡。
-- ②：1回合1次，自己主要阶段才能发动。自己的手卡·场上1只怪兽破坏，从卡组把1只攻击力1200而守备力1000以下的机械族·光属性怪兽在自己或对方的场上特殊召唤。
-- ③：把墓地的这张卡除外才能发动。从自己的卡组·墓地把1张「头目连战」在自己场上表侧表示放置。
local s,id,o=GetID()
-- 初始化效果，注册三个效果，分别对应①②③效果
function s.initial_effect(c)
	-- 记录该卡拥有「头目连战」的卡名
	aux.AddCodeList(c,66947414)
	-- ①效果：作为这张卡的发动时的效果处理，从卡组把1只「巨大战舰」怪兽加入手卡
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②效果：1回合1次，自己主要阶段才能发动。自己的手卡·场上1只怪兽破坏，从卡组把1只攻击力1200而守备力1000以下的机械族·光属性怪兽在自己或对方的场上特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③效果：把墓地的这张卡除外才能发动。从自己的卡组·墓地把1张「头目连战」在自己场上表侧表示放置
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"放置"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	-- ③效果的发动费用为将此卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 检索过滤器，用于筛选「巨大战舰」怪兽加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x15) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动处理函数，检查是否有满足条件的卡并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足①效果发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置①效果的操作信息为检索1张卡到手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的发动处理函数，选择并加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 破坏过滤器，用于筛选可破坏的怪兽
function s.dfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER)
		-- 检查是否有满足②效果发动条件的特殊召唤卡
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 特殊召唤过滤器，用于筛选攻击力1200且守备力1000以下的机械族·光属性怪兽
function s.spfilter(c,e,tp,ec)
	return c:IsAttack(1200) and c:IsDefenseBelow(1000) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
		-- 判断自己场上是否有可用区域进行特殊召唤
		and (Duel.GetMZoneCount(tp,ec)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断对方场上是否有可用区域进行特殊召唤
		or Duel.GetMZoneCount(1-tp,ec)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
-- ②效果的发动处理函数，设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足破坏条件的怪兽数组
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e,tp)
	if chk==0 then return #g>0 end
	-- 设置②效果的操作信息为破坏1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置②效果的操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的发动处理函数，选择破坏和特殊召唤的卡并执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 检查是否有满足破坏条件的手牌或场上的怪兽
	if Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) then
		-- 选择满足破坏条件的怪兽
		g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	else
		-- 若无满足条件的怪兽则选择任意一只怪兽进行破坏
		g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,TYPE_MONSTER)
	end
	if g:GetCount()>0 then
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then
			-- 显示选中的怪兽被破坏的动画效果
			Duel.HintSelection(g)
		end
		-- 判断是否成功破坏并检查是否有满足特殊召唤条件的卡
		if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,nil) then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足特殊召唤条件的卡
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,nil)
			if #sg>0 then
				local tc=sg:GetFirst()
				-- 判断自己场上是否有可用区域进行特殊召唤
				local ssp=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 判断对方场上是否有可用区域进行特殊召唤
				local osp=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
				-- 询问是否在对方场上特殊召唤
				if osp and (not ssp or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then  --"是否在对方场上特殊召唤？"
					-- 在对方场上特殊召唤选中的怪兽
					Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
				elseif ssp then
					-- 在自己场上特殊召唤选中的怪兽
					Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
-- 放置过滤器，用于筛选「头目连战」卡
function s.tffilter(c,tp)
	return c:IsCode(66947414)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ③效果的发动处理函数，检查是否有满足条件的卡并设置操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足③效果发动条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查是否有满足条件的「头目连战」卡
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
-- ③效果的发动处理函数，选择并放置卡
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有可用区域进行放置
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的卡
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tffilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将选中的卡放置到场上
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
