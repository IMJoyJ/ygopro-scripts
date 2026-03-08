--魔界劇団カーテン・ライザー
-- 效果：
-- ←7 【灵摆】 7→
-- 这个卡名的灵摆效果在决斗中只能使用1次。
-- ①：自己场上没有怪兽存在的场合才能发动。灵摆区域的这张卡特殊召唤。
-- 【怪兽效果】
-- ①：自己场上没有这张卡以外的怪兽存在的场合，这张卡的攻击力上升1100。
-- ②：1回合1次，从卡组把1张「魔界台本」魔法卡送去墓地才能发动。从自己的额外卡组把1只表侧表示的「魔界剧团」灵摆怪兽加入手卡。
function c44179224.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上没有怪兽存在的场合才能发动。灵摆区域的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44179224,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,44179224+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c44179224.spcon)
	e1:SetTarget(c44179224.sptg)
	e1:SetOperation(c44179224.spop)
	c:RegisterEffect(e1)
	-- ①：自己场上没有这张卡以外的怪兽存在的场合，这张卡的攻击力上升1100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(1100)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c44179224.atkcon)
	c:RegisterEffect(e2)
	-- ②：1回合1次，从卡组把1张「魔界台本」魔法卡送去墓地才能发动。从自己的额外卡组把1只表侧表示的「魔界剧团」灵摆怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44179224,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c44179224.thcost)
	e3:SetTarget(c44179224.thtg)
	e3:SetOperation(c44179224.thop)
	c:RegisterEffect(e3)
end
-- 判断自己场上是否没有怪兽存在
function c44179224.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有怪兽存在
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 判断是否满足灵摆召唤的条件
function c44179224.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行灵摆召唤的操作
function c44179224.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断自己场上是否只有此卡存在
function c44179224.atkcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	-- 判断自己场上是否只有此卡存在
	return Duel.GetMatchingGroupCount(nil,tp,LOCATION_MZONE,0,c)==0
end
-- 过滤函数：筛选出卡组中满足条件的「魔界台本」魔法卡
function c44179224.thcfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x20ec) and c:IsAbleToGraveAsCost()
end
-- 设置效果发动的代价，需要从卡组选择一张「魔界台本」魔法卡送去墓地
function c44179224.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「魔界台本」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c44179224.thcfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一张「魔界台本」魔法卡
	local g=Duel.SelectMatchingCard(tp,c44179224.thcfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数：筛选出额外卡组中满足条件的「魔界剧团」灵摆怪兽
function c44179224.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 设置效果发动的处理目标，表示将要从额外卡组将一只灵摆怪兽加入手牌
function c44179224.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44179224.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁处理信息，表示将要将灵摆怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 执行效果处理，从额外卡组选择一只灵摆怪兽加入手牌
function c44179224.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组中选择一只灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c44179224.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
