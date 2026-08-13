--最古式念導
-- 效果：
-- 自己场上有念动力族怪兽表侧表示存在的场合才能发动。场上1张卡破坏，自己受到1000分伤害。
function c32180819.initial_effect(c)
	-- 自己场上有念动力族怪兽表侧表示存在的场合才能发动。场上1张卡破坏，自己受到1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c32180819.condition)
	e1:SetTarget(c32180819.target)
	e1:SetOperation(c32180819.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤器函数：判断一张卡是否为表侧表示且种族为念动力族。
function c32180819.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 效果发动条件判定函数：确认自己场上有表侧表示的念动力族怪兽存在。
function c32180819.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在至少1张表侧表示且为念动力族的怪兽，作为效果能否发动的条件。
	return Duel.IsExistingMatchingCard(c32180819.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标选择与操作信息设定：选择场上1张卡为破坏对象，并登记破坏与伤害的处理信息。
function c32180819.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 在发动合法性检查中，确认场上存在除本卡以外的可成为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 给玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择双方场上1张卡作为效果对象，并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 登记破坏效果的操作信息：对象为选中的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记伤害效果的操作信息：不指定对象，给己方造成1000点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
-- 效果处理时的实际处理：若对象仍在场上则将其破坏，破坏成功后自己受到1000点伤害。
function c32180819.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与效果关联，并尝试以效果原因将其破坏；若破坏成功则继续后续伤害处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 以效果原因给自己造成1000点伤害。
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
end
