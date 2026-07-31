--アトランティスの戦将
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 注册关联卡名列表：「传说之都 亚特兰蒂斯」、「海」
	aux.AddCodeList(c,38391684,22702055)
	-- 设定卡名变更规则（在特定区域当作「海」使用）
	aux.EnableChangeCode(c,22702055)
	-- 把这张卡从手牌丢弃去墓地才能发动。从卡组把1张有「传说之都 亚特兰蒂斯」的卡名记载的魔法·陷阱卡加入手牌。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 场上有「海」表侧表示存在的场合，这张卡可以从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 检索效果Cost：把手牌的这张卡丢弃去墓地
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡丢弃去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索卡片过滤条件：有「传说之都 亚特兰蒂斯」卡名记载的魔法·陷阱卡
function s.thfilter(c)
	-- 判断是否为有「传说之都 亚特兰蒂斯」记载且可加入手牌的魔法·陷阱卡
	return aux.IsCodeListed(c,38391684) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 检索效果发动准备与目标确认
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：从卡组选卡加入手牌并确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 特殊召唤条件过滤：场上表侧表示的「海」
function s.cfilter(c)
	return c:IsCode(22702055) and c:IsFaceup()
end
-- 特殊召唤效果发动条件检查
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有表侧表示的「海」或处于「海」环境
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) or Duel.IsEnvironment(22702055,tp)
end
-- 特殊召唤效果目标确认
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：怪兽区域有空位且自身可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果处理：从墓地特殊召唤自身
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与连锁关联且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
