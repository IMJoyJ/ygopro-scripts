--烈風の覇者シムルグ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：上级召唤的这张卡不会成为对方的魔法·陷阱卡的效果的对象。
-- ②：魔法·陷阱卡的效果发动时，把自己场上1只鸟兽族·风属性怪兽解放，以对方场上1张卡为对象才能发动。那张卡回到持有者卡组。
-- ③：这张卡在墓地存在，自己的鸟兽族怪兽被战斗破坏时才能发动。这张卡加入手卡。
function c95192919.initial_effect(c)
	-- ①：上级召唤的这张卡不会成为对方的魔法·陷阱卡的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c95192919.tgcon)
	e1:SetValue(c95192919.tgval)
	c:RegisterEffect(e1)
	-- ②：魔法·陷阱卡的效果发动时，把自己场上1只鸟兽族·风属性怪兽解放，以对方场上1张卡为对象才能发动。那张卡回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95192919,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,95192919)
	e2:SetCondition(c95192919.tdcon)
	e2:SetCost(c95192919.tdcost)
	e2:SetTarget(c95192919.tdtg)
	e2:SetOperation(c95192919.tdop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在，自己的鸟兽族怪兽被战斗破坏时才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95192919,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,95192920)
	e3:SetCondition(c95192919.thcon)
	e3:SetTarget(c95192919.thtg)
	e3:SetOperation(c95192919.thop)
	c:RegisterEffect(e3)
end
-- 判断这张卡是否为上级召唤的状态
function c95192919.tgcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 判断是否为对方发动的魔法·陷阱卡的效果
function c95192919.tgval(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断发动的效果是否为魔法·陷阱卡的效果
function c95192919.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤自己场上的风属性·鸟兽族怪兽（如果是里侧表示则必须由自己控制）
function c95192919.costfilter(c,tp)
	return c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_WIND) and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果②的代价处理：解放自己场上1只鸟兽族·风属性怪兽
function c95192919.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为解放代价的鸟兽族·风属性怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c95192919.costfilter,1,nil,tp) end
	-- 选择自己场上1只鸟兽族·风属性怪兽解放
	local sg=Duel.SelectReleaseGroup(tp,c95192919.costfilter,1,1,nil,tp)
	-- 解放选中的怪兽
	Duel.Release(sg,REASON_COST)
end
-- 效果②的对象选择与效果处理信息注册
function c95192919.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	-- 检查对方场上是否存在可以返回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 发送系统提示信息：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上1张可以返回卡组的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②的效果处理：使目标卡片回到持有者卡组并洗牌
function c95192919.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤原本由自己控制且被破坏的鸟兽族怪兽
function c95192919.cfilter(c,tp)
	return c:IsRace(RACE_WINDBEAST) and c:IsPreviousControler(tp)
end
-- 判断是否自己的鸟兽族怪兽被战斗破坏
function c95192919.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c95192919.cfilter,1,e:GetHandler(),tp)
end
-- 效果③的对象选择与效果处理信息注册
function c95192919.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息：将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理：将这张卡从墓地加入手卡
function c95192919.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
