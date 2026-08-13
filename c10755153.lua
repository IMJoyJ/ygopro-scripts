--ガーディアン・シール
-- 效果：
-- 当自己场上存在「流星之弓-烨焰」时才能召唤·反转召唤·特殊召唤。将1张这张卡身上装备的自己的装备卡送去墓地，破坏对方场上1只怪兽。
function c10755153.initial_effect(c)
	-- 当自己场上存在「流星之弓-烨焰」时才能召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c10755153.sumcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	-- 当自己场上存在「流星之弓-烨焰」时才能特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c10755153.sumlimit)
	c:RegisterEffect(e3)
	-- 将1张这张卡身上装备的自己的装备卡送去墓地，破坏对方场上1只怪兽。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(10755153,0))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCost(c10755153.descost)
	e4:SetTarget(c10755153.destg)
	e4:SetOperation(c10755153.desop)
	c:RegisterEffect(e4)
end
-- 筛选表侧表示且卡号为95638658（「流星之弓-烨焰」）的卡，用于判断场上是否存在该卡。
function c10755153.cfilter(c)
	return c:IsFaceup() and c:IsCode(95638658)
end
-- 通常召唤限制条件：当己方场上不存在表侧表示「流星之弓-烨焰」时，此卡不能通常召唤。
function c10755153.sumcon(e)
	-- 返回条件结果：不存在「流星之弓-烨焰」时为true，即禁止通常召唤。
	return not Duel.IsExistingMatchingCard(c10755153.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤条件判定：召唤方sp的场上存在表侧表示「流星之弓-烨焰」时，才允许此卡特殊召唤。
function c10755153.sumlimit(e,se,sp,st,pos,tp)
	-- 返回条件结果：存在「流星之弓-烨焰」时为true，即允许特殊召唤。
	return Duel.IsExistingMatchingCard(c10755153.cfilter,sp,LOCATION_ONFIELD,0,1,nil)
end
-- 筛选条件：表侧表示、装备对象为指定怪兽ec、且可作为代价送去墓地的装备卡。
function c10755153.costfilter(c,ec)
	return c:IsFaceup() and c:GetEquipTarget()==ec and c:IsAbleToGraveAsCost()
end
-- 代价操作：从己方魔陷区选择一张装备在此卡上的装备卡，作为代价送去墓地。
function c10755153.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价确认：检查是否存在满足条件的装备卡，用于决定能否发动效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c10755153.costfilter,tp,LOCATION_SZONE,0,1,nil,e:GetHandler()) end
	-- 显示提示，要求玩家选择要送去墓地的装备卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从己方魔陷区选择一张符合条件的装备卡（作为代价）。
	local g=Duel.SelectMatchingCard(tp,c10755153.costfilter,tp,LOCATION_SZONE,0,1,1,nil,e:GetHandler())
	-- 将选择的装备卡以代价（REASON_COST）送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果目标选择：选择对方场上1只怪兽作为破坏对象。
function c10755153.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 目标确认：检查对方场上是否存在可成为此效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示提示，要求玩家选择要破坏的对方怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上一只怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将本次操作信息登记为破坏1张卡，并记录对象与数量，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：将取对象的目标怪兽破坏。
function c10755153.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因（REASON_EFFECT）破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
