--星遺物の加護
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地2只卡名不同的「星杯」怪兽为对象才能发动。那些怪兽加入手卡。
-- ②：自己场上的连接状态的连接怪兽被战斗破坏的场合，可以作为代替把墓地的这张卡除外。
function c97648103.initial_effect(c)
	-- ①：以自己墓地2只卡名不同的「星杯」怪兽为对象才能发动。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,97648103)
	e1:SetTarget(c97648103.target)
	e1:SetOperation(c97648103.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的连接状态的连接怪兽被战斗破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c97648103.reptg)
	e2:SetValue(c97648103.repval)
	e2:SetOperation(c97648103.repop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以作为效果对象的「星杯」怪兽
function c97648103.thfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xfd) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- ①号效果的发动准备，确认墓地中存在2只卡名不同的「星杯」怪兽，并进行取对象和设置操作信息
function c97648103.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c97648103.thfilter(chkc,e) end
	-- 获取自己墓地中所有满足条件的「星杯」怪兽
	local g=Duel.GetMatchingGroup(c97648103.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=2 end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择2张卡名不同的怪兽
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选中的怪兽设为效果处理的对象
	Duel.SetTargetCard(g1)
	-- 设置操作信息为将2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- ①号效果的处理，将仍存在于墓地且符合对象条件的卡加入手牌
function c97648103.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将符合条件的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
-- 过滤自己场上因战斗破坏的处于连接状态的连接怪兽
function c97648103.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsReason(REASON_BATTLE)
		and c:IsType(TYPE_LINK) and c:IsLinkState()
end
-- 代替破坏效果的目标检测，确认墓地的这张卡可以除外，且场上有符合条件的怪兽被战斗破坏，并询问玩家是否发动
function c97648103.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c97648103.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定代替破坏的适用对象
function c97648103.repval(e,c)
	return c97648103.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的具体操作
function c97648103.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡除外作为代替
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
