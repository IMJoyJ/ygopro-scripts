--水晶機巧－サルファドール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以自己场上1张「水晶机巧」卡为对象才能发动。那张卡破坏，这张卡特殊召唤。这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「水晶机巧-柠晶救龙」以外的最多2张「水晶机巧」卡送去墓地（同名卡最多1张）。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果，①效果为起动效果，②效果为诱发效果
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，以自己场上1张「水晶机巧」卡为对象才能发动。那张卡破坏，这张卡特殊召唤。这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.spdtg)
	e1:SetOperation(s.spdop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「水晶机巧-柠晶救龙」以外的最多2张「水晶机巧」卡送去墓地（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义过滤函数，用于判断场上是否满足条件的「水晶机巧」卡
function s.desfilter(c,tp)
	-- 满足条件的「水晶机巧」卡必须是表侧表示且有空怪兽区
	return c:IsFaceup() and c:IsSetCard(0xea) and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的发动条件判断，检查是否能特殊召唤自身并存在满足条件的目标
function s.spdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.desfilter(chkc,tp) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否存在满足条件的目标
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的目标卡
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置操作信息，将要破坏的卡加入操作对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，将自身特殊召唤加入操作对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理函数，破坏目标卡并特殊召唤自身
function s.spdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且成功破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 判断自身是否有效且未受王家长眠之谷影响
		and c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建永续效果，限制本回合非机械族怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该永续效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 永续效果的限制条件，非机械族怪兽不能从额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_MACHINE) and c:IsLocation(LOCATION_EXTRA)
end
-- 定义过滤函数，用于筛选可送去墓地的「水晶机巧」卡
function s.tgfilter(c)
	return c:IsSetCard(0xea) and c:IsAbleToGrave() and not c:IsCode(id)
end
-- ②效果的发动条件判断，检查卡组中是否存在满足条件的卡
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，将要送去墓地的卡加入操作对象
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数，从卡组选择最多2张「水晶机巧」卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的卡
	local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if #tg>0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从满足条件的卡中选择最多2张且卡名各不相同的卡
		local sg=tg:SelectSubGroup(tp,aux.dncheck,false,1,2)
		-- 将选中的卡送去墓地
		if sg then Duel.SendtoGrave(sg,REASON_EFFECT) end
	end
end
