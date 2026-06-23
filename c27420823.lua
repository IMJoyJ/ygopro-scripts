--K9－17号 “Ripper”
-- 效果：
-- 5星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「K9」卡加入手卡。这个回合对方是已把怪兽的效果发动的场合，可以再从自己的卡组·墓地把1张「K9」速攻魔法卡在自己场上盖放。
-- ②：对方把手卡·墓地的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个效果无效。
local s,id,o=GetID()
-- 初始化效果函数，设置XYZ召唤手续、启用复活限制、注册两个效果
function s.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为5、数量为2的怪兽进行叠放
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- 设置效果①，检索「K9」卡并可能盖放速攻魔法卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 设置效果②，无效对方怪兽效果的发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- 添加自定义连锁计数器，用于记录对方发动的非怪兽效果次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 计数器过滤函数，仅统计非怪兽类型的连锁
function s.chainfilter(re,tp,cid)
	return not re:IsActiveType(TYPE_MONSTER)
end
-- 效果①的费用，消耗1个超量素材
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索过滤函数，筛选「K9」卡且能加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x1cb) and c:IsAbleToHand()
end
-- 效果①的发动条件，确认卡组存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 盖放过滤函数，筛选「K9」速攻魔法卡且可盖放
function s.setfilter(c)
	return c:IsSetCard(0x1cb) and c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
end
-- 效果①的处理函数，检索卡并可能盖放速攻魔法卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 确认卡加入手牌并处理后续盖放逻辑
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		-- 确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 检查是否存在满足条件的速攻魔法卡
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
			-- 检查对方是否在本回合发动过非怪兽效果
			and Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
			-- 询问是否盖放速攻魔法卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡盖放？"
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 提示选择要盖放的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			-- 选择满足条件的速攻魔法卡进行盖放
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
			if sg:GetCount()>0 then
				-- 执行盖放操作
				Duel.SSet(tp,sg)
			end
		end
	end
end
-- 效果②的发动条件，对方在手牌或墓地发动怪兽效果
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁发动位置信息
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep~=tp and (LOCATION_HAND+LOCATION_GRAVE)&loc~=0
		-- 判断连锁效果是否为怪兽类型且可无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 效果②的费用，消耗1个超量素材
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动条件，确认是否能无效效果
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果②的处理函数，使效果无效
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行使效果无效的操作
	Duel.NegateEffect(ev)
end
