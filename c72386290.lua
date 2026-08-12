--儀水鏡の集光
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从卡组把1只「遗式」怪兽加入手卡。
-- ②：自己场上有水属性仪式怪兽存在的场合，自己·对方的结束阶段，把墓地的这张卡除外才能发动。从自己的卡组·墓地选「仪水镜的集光」以外的1张「仪水镜」魔法·陷阱卡在自己场上盖放。
function c72386290.initial_effect(c)
	-- ①：从卡组把1只「遗式」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c72386290.target)
	e1:SetOperation(c72386290.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上有水属性仪式怪兽存在的场合，自己·对方的结束阶段，把墓地的这张卡除外才能发动。从自己的卡组·墓地选「仪水镜的集光」以外的1张「仪水镜」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,72386290)
	e2:SetCondition(c72386290.stcon)
	-- 把墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c72386290.sttg)
	e2:SetOperation(c72386290.stop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中「遗式」怪兽且能加入手牌
function c72386290.filter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动准备（检查卡组中是否存在可检索的「遗式」怪兽，并设置检索的操作信息）
function c72386290.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足过滤条件的「遗式」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c72386290.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理（从卡组选择1只「遗式」怪兽加入手牌并给对方确认）
function c72386290.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「遗式」怪兽
	local g=Duel.SelectMatchingCard(tp,c72386290.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：场上表侧表示的水属性仪式怪兽
function c72386290.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_RITUAL) and c:IsFaceup()
end
-- ②效果的发动条件（自己场上存在水属性仪式怪兽）
function c72386290.stcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的水属性仪式怪兽
	return Duel.IsExistingMatchingCard(c72386290.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡组或墓地中「仪水镜的集光」以外的「仪水镜」魔法·陷阱卡，且该卡可以盖放
function c72386290.stfilter(c)
	return c:IsSetCard(0x18e) and not c:IsCode(72386290) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果的发动准备（检查卡组或墓地是否存在可盖放的「仪水镜」魔法·陷阱卡）
function c72386290.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或墓地是否存在至少1张满足过滤条件的「仪水镜」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c72386290.stfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- ②效果的处理（从卡组或墓地选择1张「仪水镜」魔法·陷阱卡在自己场上盖放）
function c72386290.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组或墓地选择1张满足过滤条件且不受王家长眠之谷影响的「仪水镜」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c72386290.stfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
