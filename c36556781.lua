--ドラグニティナイト－ゴルムファバル
-- 效果：
-- 「龙骑兵团」调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤成功时，以自己墓地1只「龙骑兵团」调整为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。
-- ②：把给这张卡装备的自己场上1张装备卡送去墓地，以对方墓地最多2张卡为对象才能发动。那些卡除外。这个效果在对方回合也能发动。
function c36556781.initial_effect(c)
	-- 添加同调召唤手续，要求1只满足条件的调整和1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x29),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功时，以自己墓地1只「龙骑兵团」调整为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36556781,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,36556781)
	e1:SetCondition(c36556781.eqcon)
	e1:SetTarget(c36556781.eqtg)
	e1:SetOperation(c36556781.eqop)
	c:RegisterEffect(e1)
	-- ②：把给这张卡装备的自己场上1张装备卡送去墓地，以对方墓地最多2张卡为对象才能发动。那些卡除外。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36556781,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,36556782)
	e2:SetCost(c36556781.rmcost)
	e2:SetTarget(c36556781.rmtg)
	e2:SetOperation(c36556781.rmop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为同调召唤成功
function c36556781.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的「龙骑兵团」调整怪兽
function c36556781.eqfilter(c)
	return c:IsSetCard(0x29) and c:IsType(TYPE_TUNER) and not c:IsForbidden()
end
-- 设置效果目标，选择满足条件的墓地调整怪兽
function c36556781.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36556781.eqfilter(chkc) end
	-- 判断场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断墓地是否存在满足条件的调整怪兽
		and Duel.IsExistingTarget(c36556781.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的墓地调整怪兽作为目标
	local g=Duel.SelectTarget(tp,c36556781.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end
-- 执行装备操作，将目标怪兽装备给此卡
function c36556781.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 尝试将目标怪兽装备给此卡
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 设置装备限制效果，确保只有此卡能装备该怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c36556781.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制效果的值函数，判断目标是否为装备者
function c36556781.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤满足条件的可作为费用的卡
function c36556781.costfilter(c,tp)
	return c:IsControler(tp) and c:IsAbleToGraveAsCost()
end
-- 设置效果费用，从装备区选择一张卡送去墓地作为费用
function c36556781.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(c36556781.costfilter,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,c36556781.costfilter,1,1,nil,tp)
	-- 将选择的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果目标，选择对方墓地最多2张可除外的卡
function c36556781.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chk:IsAbleToRemove() end
	-- 判断对方墓地是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地最多2张可除外的卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,2,nil)
	-- 设置操作信息，记录将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 执行效果，将目标卡除外
function c36556781.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将满足条件的卡除外
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
