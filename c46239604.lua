--魔知ガエル
-- 效果：
-- ①：这张卡只要在怪兽区域存在，卡名当作「死亡青蛙」使用。
-- ②：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
-- ③：这张卡从场上送去墓地时才能发动。从自己的卡组·墓地选「魔知青蛙」以外的1只「青蛙」怪兽加入手卡。
function c46239604.initial_effect(c)
	-- 向系统登记此卡在怪兽区域时卡名当作「死亡青蛙」（卡片密码：84451804）使用
	aux.EnableChangeCode(c,84451804)
	-- ③：这张卡从场上送去墓地时才能发动。从自己的卡组·墓地选「魔知青蛙」以外的1只「青蛙」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46239604,0))  --"加入手牌"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c46239604.condition)
	e2:SetTarget(c46239604.target)
	e2:SetOperation(c46239604.operation)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c46239604.atlimit)
	c:RegisterEffect(e3)
end
-- 限制对方只能选择此卡作为攻击目标，不能选择自己场上的其他怪兽
function c46239604.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 确认此卡在送去墓地之前确实存在于场上
function c46239604.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 卡组或墓地中属于「青蛙」字段且不为此卡名称、可加入手牌的怪兽过滤条件
function c46239604.filter(c)
	return c:IsSetCard(0x12) and c:IsType(TYPE_MONSTER) and not c:IsCode(46239604) and c:IsAbleToHand()
end
-- 送墓检索/回收效果的发动准备与合法性检查
function c46239604.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或墓地是否存在符合检索条件的「青蛙」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c46239604.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 从卡组或墓地将「青蛙」怪兽加入手牌的执行
function c46239604.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示，请选择需要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地中选择1只符合条件的「青蛙」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c46239604.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的怪兽卡展示给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
