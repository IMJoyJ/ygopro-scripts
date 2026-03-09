--エルシャドール・エグリスタ
-- 效果：
-- 「影依」怪兽＋炎属性怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。那之后，从自己手卡选1张「影依」卡送去墓地。
-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c48424886.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置该卡为影依融合怪兽，需要炎属性的融合素材
	aux.AddFusionProcShaddoll(c,ATTRIBUTE_FIRE)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(c48424886.splimit)
	c:RegisterEffect(e2)
	-- ①：对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。那之后，从自己手卡选1张「影依」卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48424886,0))  --"无效并破坏"
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON)
	e3:SetCountLimit(1,48424886)
	e3:SetCondition(c48424886.condition)
	e3:SetTarget(c48424886.target)
	e3:SetOperation(c48424886.operation)
	c:RegisterEffect(e3)
	-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(48424886,1))  --"卡片回收"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetTarget(c48424886.thtg)
	e4:SetOperation(c48424886.thop)
	c:RegisterEffect(e4)
end
-- 限制该卡只能通过融合召唤从额外卡组特殊召唤
function c48424886.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 效果发动条件：对方进行怪兽特殊召唤且当前无连锁处理中
function c48424886.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方进行怪兽特殊召唤且当前无连锁处理中
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 过滤函数，用于筛选手牌中的影依卡
function c48424886.filter(c)
	return c:IsSetCard(0x9d)
end
-- 设置效果目标：检查手牌是否存在影依卡，并设置操作信息为无效召唤和破坏
function c48424886.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌是否存在影依卡
	if chk==0 then return Duel.IsExistingMatchingCard(c48424886.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息为无效召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息为破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 效果处理函数：使对方的特殊召唤无效并破坏那些怪兽，然后选择手牌中的影依卡送去墓地
function c48424886.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方的特殊召唤无效
	Duel.NegateSummon(eg)
	-- 破坏对方特殊召唤的怪兽
	Duel.Destroy(eg,REASON_EFFECT)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌中选择一张影依卡
	local g=Duel.SelectMatchingCard(tp,c48424886.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 中断当前效果处理，使后续效果视为错时点处理
		Duel.BreakEffect()
		-- 将选中的影依卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选墓地中的影依魔法或陷阱卡
function c48424886.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果目标：检查墓地中是否存在影依魔法或陷阱卡，并设置操作信息为加入手牌
function c48424886.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48424886.thfilter(chkc) end
	-- 检查墓地中是否存在影依魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c48424886.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地中选择一张影依魔法或陷阱卡
	local g=Duel.SelectTarget(tp,c48424886.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：将选中的影依魔法或陷阱卡加入手牌
function c48424886.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
