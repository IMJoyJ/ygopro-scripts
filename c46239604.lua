--魔知ガエル
-- 效果：
-- ①：这张卡只要在怪兽区域存在，卡名当作「死亡青蛙」使用。
-- ②：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
-- ③：这张卡从场上送去墓地时才能发动。从自己的卡组·墓地选「魔知青蛙」以外的1只「青蛙」怪兽加入手卡。
function c46239604.initial_effect(c)
	-- 为这张卡注册卡名变更效果：只要在怪兽区域存在，卡名当作「死亡青蛙」（卡号84451804）使用。
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
-- 限制攻击对象的永续效果判定：除这张卡自身以外的怪兽不能被对方选择为攻击对象。
function c46239604.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 发动条件：这张卡之前必须存在于场上（即这张卡是从场上送去墓地的场合才能发动）。
function c46239604.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：「青蛙」系列的怪兽卡，且不是「魔知青蛙」自身，并且可以加入手卡。
function c46239604.filter(c)
	return c:IsSetCard(0x12) and c:IsType(TYPE_MONSTER) and not c:IsCode(46239604) and c:IsAbleToHand()
end
-- 目标函数：先确认发动条件成立，再为「从卡组·墓地把卡加入手卡」设置操作信息。
function c46239604.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己的墓地·卡组中存在至少1张满足过滤条件的卡（可以加入手卡的「青蛙」怪兽）。
	if chk==0 then return Duel.IsExistingMatchingCard(c46239604.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本连锁将从卡组·墓地以效果把1张卡加入发动玩家手卡（加入的卡在处理时确定，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果处理函数：提示选择加入手卡的卡，从卡组·墓地选1只满足条件的怪兽加入手卡，若成功加入则向对方展示。
function c46239604.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组·墓地选择1只满足过滤条件（且不受王家长眠之谷影响）的「青蛙」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c46239604.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的这张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
