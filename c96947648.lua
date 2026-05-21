--サルベージ
-- 效果：
-- ①：以自己墓地2只攻击力1500以下的水属性怪兽为对象才能发动。那些水属性怪兽加入手卡。
function c96947648.initial_effect(c)
	-- ①：以自己墓地2只攻击力1500以下的水属性怪兽为对象才能发动。那些水属性怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c96947648.target)
	e1:SetOperation(c96947648.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中攻击力1500以下、可以加入手牌的水属性怪兽
function c96947648.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttackBelow(1500) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 过滤在效果处理时仍与该效果有关联且为水属性的对象卡片
function c96947648.opfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果发动的对象选择与合法性检测
function c96947648.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c96947648.filter(chkc) end
	-- 在发动阶段，检测自己墓地是否存在至少2只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c96947648.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向玩家发送提示信息，要求选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地2只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c96947648.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置当前连锁的操作信息为将2张目标卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理的执行函数，将选中的对象卡片加入手牌
function c96947648.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c96947648.opfilter,nil,e)
	if sg:GetCount()>0 then
		-- 将符合条件的对象卡片因效果加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
