--パワー・ツール・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：1回合1次，自己主要阶段才能发动。从卡组把3张装备魔法卡给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩余回到卡组。
-- ②：这张卡被破坏的场合，可以作为代替把这张卡装备的1张装备魔法卡送去墓地。
function c2403771.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己主要阶段才能发动。从卡组把3张装备魔法卡给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2403771,0))  --"选择装备卡加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c2403771.thtg)
	e1:SetOperation(c2403771.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏的场合，可以作为代替把这张卡装备的1张装备魔法卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(c2403771.desreptg)
	e2:SetOperation(c2403771.desrepop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选可加入手牌的装备魔法卡
function c2403771.thfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，检查是否满足发动条件并设置操作信息
function c2403771.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少3张装备魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c2403771.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置连锁操作信息，指定将要处理的卡为1张装备魔法卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果发动时的处理函数，执行具体操作
function c2403771.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的装备魔法卡组
	local g=Duel.GetMatchingGroup(c2403771.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		local tg=sg:RandomSelect(1-tp,1)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将选中的卡加入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选可作为代替破坏的装备魔法卡
function c2403771.repfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsLocation(LOCATION_SZONE) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 破坏代替效果的处理函数，判断是否发动并选择代替卡
function c2403771.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local g=c:GetEquipGroup()
		return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE) and g:IsExists(c2403771.repfilter,1,nil)
	end
	-- 询问玩家是否发动效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		local g=c:GetEquipGroup()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:FilterSelect(tp,c2403771.repfilter,1,1,nil)
		-- 设置当前处理的连锁对象为选中的卡
		Duel.SetTargetCard(sg)
		return true
	else return false end
end
-- 破坏代替效果的处理函数，执行将卡送去墓地的操作
function c2403771.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	-- 将目标卡组送去墓地
	Duel.SendtoGrave(tg,REASON_EFFECT+REASON_REPLACE)
end
