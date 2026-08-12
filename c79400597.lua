--静冠の呪眼
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡也能从自己墓地把1张「咒眼」卡除外来发动。那个场合，自己从卡组抽1张。
-- ②：1回合1次，有「太阴之咒眼」装备的自己的「咒眼」怪兽向对方怪兽攻击的伤害计算后才能发动。那只对方怪兽除外。
-- ③：魔法与陷阱区域的这张卡被效果破坏的场合，以除外的最多3张自己的「咒眼」卡为对象才能发动。那些卡回到墓地。
function c79400597.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡也能从自己墓地把1张「咒眼」卡除外来发动。那个场合，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,79400597+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c79400597.target)
	e1:SetOperation(c79400597.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，有「太阴之咒眼」装备的自己的「咒眼」怪兽向对方怪兽攻击的伤害计算后才能发动。那只对方怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c79400597.rmtg)
	e2:SetOperation(c79400597.rmop)
	c:RegisterEffect(e2)
	-- ③：魔法与陷阱区域的这张卡被效果破坏的场合，以除外的最多3张自己的「咒眼」卡为对象才能发动。那些卡回到墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c79400597.tgcon)
	e3:SetTarget(c79400597.tgtg)
	e3:SetOperation(c79400597.tgop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查卡片是否为「咒眼」卡且能作为Cost除外
function c79400597.costfilter(c)
	return c:IsSetCard(0x129) and c:IsAbleToRemoveAsCost()
end
-- 卡片发动时的效果处理分支：若满足条件，玩家可选择支付除外墓地1张「咒眼」卡的Cost，并在发动成功时抽1张卡
function c79400597.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查自己墓地是否存在至少1张可以作为Cost除外的「咒眼」卡
	if Duel.IsExistingMatchingCard(c79400597.costfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查玩家是否可以抽卡，并询问玩家是否选择除外墓地的「咒眼」卡来发动抽卡效果
		and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(79400597,0)) then  --"是否除外墓地「咒眼」卡并抽卡？"
		-- 提示玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家从自己墓地选择1张满足过滤条件的「咒眼」卡
		local g=Duel.SelectMatchingCard(tp,c79400597.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选择的卡表侧表示除外作为发动的Cost
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		e:SetLabel(1)
		-- 设置当前连锁的操作信息为：玩家tp抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		e:SetLabel(0)
	end
end
-- 卡片发动时的效果处理：若此卡仍在场且标记了抽卡效果，则执行抽卡
function c79400597.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and e:GetLabel()==1 then
		-- 让玩家tp因效果抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 效果②的发动条件检查：检查是否有装备了「太阴之咒眼」的自己的「咒眼」怪兽向对方怪兽进行攻击，且该对方怪兽可以被除外
function c79400597.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽（攻击对象）
	local d=Duel.GetAttackTarget()
	if chk==0 then return d~=nil and d:IsAbleToRemove() and a:IsControler(tp) and a:IsSetCard(0x129)
		and a:GetEquipGroup() and a:GetEquipGroup():IsExists(Card.IsCode,1,nil,44133040) end
	e:SetLabelObject(d)
	-- 设置当前连锁的操作信息为：除外1只对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,d,1,0,0)
end
-- 效果②的效果处理：若此卡仍在场且对方怪兽仍处于战斗状态，则将该对方怪兽除外
function c79400597.rmop(e,tp,eg,ep,ev,re,r,rp)
	local d=e:GetLabelObject()
	if e:GetHandler():IsRelateToEffect(e) and d:IsRelateToBattle() then
		-- 将对方怪兽表侧表示除外
		Duel.Remove(d,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果③的发动条件：此卡在魔法与陷阱区域被效果破坏并送去墓地
function c79400597.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_SZONE)
end
-- 过滤函数：检查卡片是否为表侧表示的「咒眼」卡
function c79400597.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x129)
end
-- 效果③的靶向处理：选择除外的最多3张自己的「咒眼」卡作为对象
function c79400597.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c79400597.filter(chkc) end
	-- 检查除外区是否存在至少1张表侧表示的自己的「咒眼」卡
	if chk==0 then return Duel.IsExistingTarget(c79400597.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要回到墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(79400597,1))  --"请选择要回到墓地的卡"
	-- 让玩家选择除外的1到3张自己的「咒眼」卡作为效果对象
	local g=Duel.SelectTarget(tp,c79400597.filter,tp,LOCATION_REMOVED,0,1,3,nil)
	-- 设置当前连锁的操作信息为：将选择的对象卡片送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果③的效果处理：将选择的且仍符合条件的对象卡片送去墓地
function c79400597.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将这些卡作为效果处理送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end
