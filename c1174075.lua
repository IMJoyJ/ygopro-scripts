--竜輝巧－ファフμβ’
-- 效果：
-- 1星怪兽×2只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从卡组把1张「龙辉巧」卡送去墓地。
-- ②：自己进行仪式召唤的场合，也能把那些解放的怪兽从这张卡的超量素材取除。
-- ③：自己场上有机械族仪式怪兽存在，对方把魔法·陷阱卡发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c1174075.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续，要求使用1星怪兽2只以上进行超量召唤
	aux.AddXyzProcedure(c,nil,1,2,nil,nil,99)
	-- ①：这张卡超量召唤的场合才能发动。从卡组把1张「龙辉巧」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1174075,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,1174075)
	e1:SetCondition(c1174075.tgcon)
	e1:SetTarget(c1174075.tgtg)
	e1:SetOperation(c1174075.tgop)
	c:RegisterEffect(e1)
	-- ②：自己进行仪式召唤的场合，也能把那些解放的怪兽从这张卡的超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_OVERLAY_RITUAL_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己场上有机械族仪式怪兽存在，对方把魔法·陷阱卡发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1174075,1))  --"无效并破坏"
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,1174076)
	e3:SetCondition(c1174075.discon)
	e3:SetCost(c1174075.discost)
	e3:SetTarget(c1174075.distg)
	e3:SetOperation(c1174075.disop)
	c:RegisterEffect(e3)
end
-- 判断此卡是否为超量召唤 summoned
function c1174075.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤函数，用于筛选卡组中满足条件的「龙辉巧」卡
function c1174075.tgfilter(c)
	return c:IsSetCard(0x154) and c:IsAbleToGrave()
end
-- 设置效果目标，检查是否满足发动条件
function c1174075.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在卡组中存在至少1张「龙辉巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1174075.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组选择1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行将卡送去墓地的操作
function c1174075.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 从卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c1174075.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选场上满足条件的机械族仪式怪兽
function c1174075.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsRace(RACE_MACHINE)
end
-- 判断是否满足发动条件，包括连锁可无效、对方发动魔法/陷阱卡、己方场上有机械族仪式怪兽
function c1174075.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此卡未在战斗中被破坏且连锁可无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
		and ep==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 检查己方场上是否存在机械族仪式怪兽
		and Duel.IsExistingMatchingCard(c1174075.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置发动费用，消耗1个超量素材
function c1174075.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果目标，确定发动时的处理对象
function c1174075.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示将破坏发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数，执行无效并破坏的操作
function c1174075.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使连锁发动无效，并判断是否可以破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
