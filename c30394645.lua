--教導の死徒
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡特殊召唤。
-- ②：这张卡从手卡特殊召唤的场合才能发动。双方各自从自身的额外卡组把1只怪兽送去墓地。
-- ③：这张卡被送去墓地的场合，以「教导的死徒」以外的自己墓地1张「教导」卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 创建三个效果，分别对应①②③效果的发动条件与处理
function s.initial_effect(c)
	-- ①：这张卡在手卡存在，从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡特殊召唤的场合才能发动。双方各自从自身的额外卡组把1只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以「教导的死徒」以外的自己墓地1张「教导」卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回收"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在从额外卡组召唤的怪兽
function s.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 判断场上是否存在从额外卡组召唤的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在从额外卡组召唤的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 设置特殊召唤的处理条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤的操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断该卡是否是从手卡特殊召唤的
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_HAND)
end
-- 设置送去墓地效果的处理条件
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方额外卡组中可送去墓地的怪兽数量
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,nil)
	-- 获取对方额外卡组中可送去墓地的怪兽数量
	local g2=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,nil)
	if chk==0 then return g:GetCount()>0 and g2:GetCount()>0 end
end
-- 判断双方额外卡组中是否存在可送去墓地的怪兽
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方额外卡组中是否存在可送去墓地的怪兽
	if not Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,nil)
		-- 判断对方额外卡组中是否存在可送去墓地的怪兽
		or not Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,1,nil) then return end
	-- 获取当前回合玩家
	local p=Duel.GetTurnPlayer()
	-- 获取当前回合玩家额外卡组中可送去墓地的怪兽数量
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,p,LOCATION_EXTRA,0,nil)
	-- 提示当前回合玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:Select(p,1,1,nil)
	if sg:GetCount()>0 then
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	-- 获取当前回合玩家对方额外卡组中可送去墓地的怪兽数量
	local g2=Duel.GetMatchingGroup(Card.IsAbleToGrave,p,0,LOCATION_EXTRA,nil)
	-- 提示对方玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,1-p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg2=g2:Select(1-p,1,1,nil)
	if sg2:GetCount()>0 then
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(sg2,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选墓地中非「教导的死徒」且为「教导」卡的卡片
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x145) and c:IsAbleToHand()
end
-- 设置回收效果的处理条件
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 判断己方墓地中是否存在满足条件的「教导」卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标卡片
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置回收的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行回收的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡片是否有效且未受王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
