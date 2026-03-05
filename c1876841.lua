--D・スキャナン
-- 效果：
-- 这张卡不能通常召唤。从手卡把1只「变形斗士」怪兽除外的场合可以特殊召唤。
-- ①：这张卡得到表示形式的以下效果。
-- ●攻击表示：1回合1次，自己主要阶段才能发动。从卡组把1张「变形斗士」魔法·陷阱卡加入手卡。那之后，选1张手卡回到卡组最上面。
-- ●守备表示：1回合1次，自己主要阶段才能发动。从自己墓地选1只4星以下的「变形斗士」怪兽加入手卡。那之后，选1张手卡回到卡组最上面。
function c1876841.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文：从手卡把1只「变形斗士」怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1876841.spcon)
	e1:SetTarget(c1876841.sptg)
	e1:SetOperation(c1876841.spop)
	c:RegisterEffect(e1)
	-- 效果原文：攻击表示：1回合1次，自己主要阶段才能发动。从卡组把1张「变形斗士」魔法·陷阱卡加入手卡。那之后，选1张手卡回到卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1876841,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c1876841.srcon)
	e2:SetTarget(c1876841.srtg)
	e2:SetOperation(c1876841.srop)
	c:RegisterEffect(e2)
	-- 效果原文：守备表示：1回合1次，自己主要阶段才能发动。从自己墓地选1只4星以下的「变形斗士」怪兽加入手卡。那之后，选1张手卡回到卡组最上面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1876841,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c1876841.rccon)
	e3:SetTarget(c1876841.rctg)
	e3:SetOperation(c1876841.rcop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检索手卡中满足条件的「变形斗士」怪兽（可除外）
function c1876841.spfilter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤条件：检查场上是否有空位且手卡是否有「变形斗士」怪兽可除外
function c1876841.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否有「变形斗士」怪兽
		and Duel.IsExistingMatchingCard(c1876841.spfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
end
-- 特殊召唤目标选择：选择1只手卡中的「变形斗士」怪兽除外
function c1876841.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的「变形斗士」怪兽组
	local g=Duel.GetMatchingGroup(c1876841.spfilter,tp,LOCATION_HAND,0,e:GetHandler())
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤操作：将选中的卡除外
function c1876841.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标卡除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 攻击表示效果发动条件：卡片处于攻击表示且未被无效
function c1876841.srcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
end
-- 过滤函数：检索卡组中满足条件的「变形斗士」魔法·陷阱卡
function c1876841.srfilter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 攻击表示效果目标设定：检查卡组是否有「变形斗士」魔法·陷阱卡
function c1876841.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否有「变形斗士」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1876841.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：将1张手卡返回卡组最上面
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 攻击表示效果处理：从卡组检索1张「变形斗士」魔法·陷阱卡加入手牌，并将1张手卡返回卡组
function c1876841.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张卡组中的「变形斗士」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c1876841.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切卡组
		Duel.ShuffleDeck(tp)
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择1张手卡返回卡组
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 洗切手牌
			Duel.ShuffleHand(tp)
			-- 将目标卡返回卡组最上面
			Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
-- 守备表示效果发动条件：卡片处于守备表示且未被无效
function c1876841.rccon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
end
-- 过滤函数：检索墓地中满足条件的「变形斗士」4星以下怪兽
function c1876841.rcfilter(c)
	return c:IsSetCard(0x26) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 守备表示效果目标设定：检查墓地是否有「变形斗士」4星以下怪兽
function c1876841.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否有「变形斗士」4星以下怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c1876841.rcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：将1只怪兽从墓地加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：将1张手卡返回卡组最上面
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 守备表示效果处理：从墓地检索1只「变形斗士」4星以下怪兽加入手牌，并将1张手卡返回卡组
function c1876841.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1只墓地中的「变形斗士」4星以下怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1876841.rcfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	-- 判断是否成功将卡加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择1张手卡返回卡组
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 洗切手牌
			Duel.ShuffleHand(tp)
			-- 将目标卡返回卡组最上面
			Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
