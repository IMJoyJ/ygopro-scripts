--プランキッズ・ドゥードゥル
-- 效果：
-- 「调皮宝贝」怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「调皮宝贝」魔法·陷阱卡加入手卡。
-- ②：把这张卡解放，以连接怪兽以外的自己墓地2张「调皮宝贝」卡为对象才能发动（同名卡最多1张）。那些卡加入手卡。
function c17382973.initial_effect(c)
	-- 为卡片添加连接召唤手续，需要2个满足过滤条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x120),2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「调皮宝贝」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17382973,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,17382973)
	e1:SetCondition(c17382973.thcon)
	e1:SetTarget(c17382973.thtg)
	e1:SetOperation(c17382973.thop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，以连接怪兽以外的自己墓地2张「调皮宝贝」卡为对象才能发动（同名卡最多1张）。那些卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17382973,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,17382974)
	e2:SetCost(c17382973.thcost2)
	e2:SetTarget(c17382973.thtg2)
	e2:SetOperation(c17382973.thop2)
	c:RegisterEffect(e2)
end
-- 效果条件：确认此卡是以连接召唤方式特殊召唤成功
function c17382973.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤函数：筛选满足「调皮宝贝」卡组、魔法·陷阱类型且能加入手牌的卡
function c17382973.thfilter(c)
	return c:IsSetCard(0x120) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果处理目标设置：检查卡组是否存在满足条件的卡并设置操作信息
function c17382973.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c17382973.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：设置将1张卡从卡组加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：提示选择卡组中满足条件的卡并加入手牌
function c17382973.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择卡组中的卡：选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c17382973.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌：将选中的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认手牌：向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 解放或除外的过滤函数：筛选满足条件的卡（在场上或墓地、可作为费用移除、具有特定效果）
function c17382973.excostfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(25725326,tp)
end
-- 费用过滤函数：检查移除某张卡后剩余卡组是否满足卡名不同的条件
function c17382973.costfilter(c,tp,g)
	local tg=g:Clone()
	tg:RemoveCard(c)
	return tg:GetClassCount(Card.GetCode)>=2
end
-- 效果处理：设置费用并选择要解放或除外的卡
function c17382973.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	-- 获取满足条件的卡组：获取场上或墓地中满足条件的卡
	local g=Duel.GetMatchingGroup(c17382973.excostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	-- 获取目标卡组：获取墓地中满足条件的卡
	local tg=Duel.GetMatchingGroup(c17382973.thfilter2,tp,LOCATION_GRAVE,0,nil,e)
	if e:GetHandler():IsReleasable() then g:AddCard(e:GetHandler()) end
	if chk==0 then
		e:SetLabel(100)
		return g:IsExists(c17382973.costfilter,1,nil,tp,tg)
	end
	local cg=g:Filter(c17382973.costfilter,nil,tp,tg)
	local tc
	if #cg>1 then
		-- 提示选择：提示玩家选择要解放或代替解放除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25725326,0))  --"请选择要解放或代替解放除外的卡"
		tc=cg:Select(tp,1,1,nil):GetFirst()
	else
		tc=cg:GetFirst()
	end
	local te=tc:IsHasEffect(25725326,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将卡除外：将选中的卡以除外形式作为费用
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 解放卡：将选中的卡解放作为费用
		Duel.Release(tc,REASON_COST)
	end
end
-- 目标过滤函数：筛选满足「调皮宝贝」卡组、非连接怪兽、可成为效果对象且能加入手牌的卡
function c17382973.thfilter2(c,e)
	return c:IsSetCard(0x120) and not c:IsType(TYPE_LINK)
		and c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
-- 效果处理目标设置：选择满足条件的2张卡并设置操作信息
function c17382973.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetLabel()==100 end
	e:SetLabel(0)
	-- 获取满足条件的卡组：获取墓地中满足条件的卡
	local g=Duel.GetMatchingGroup(c17382973.thfilter2,tp,LOCATION_GRAVE,0,nil,e)
	-- 提示选择：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡组：选择2张卡名不同的卡
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 设置连锁目标：将选中的卡设置为连锁处理对象
	Duel.SetTargetCard(g1)
	-- 设置操作信息：设置将2张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 效果处理：处理连锁中设置的目标卡并加入手牌
function c17382973.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁目标卡组：获取当前连锁中设置的目标卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将卡加入手牌：将目标卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
