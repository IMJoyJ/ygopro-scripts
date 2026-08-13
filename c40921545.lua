--ヴェルズ・カイトス
-- 效果：
-- 把这张卡解放发动。选择对方场上存在的1张魔法·陷阱卡破坏。
function c40921545.initial_effect(c)
	-- 把这张卡解放发动。选择对方场上存在的1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40921545,0))  --"魔陷破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c40921545.cost)
	e1:SetTarget(c40921545.target)
	e1:SetOperation(c40921545.operation)
	c:RegisterEffect(e1)
end
-- 发动前的代价检查与代价处理：先检查此卡能否被解放作为发动代价，若满足则将此卡解放。
function c40921545.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以解放作为发动代价，将此卡解放送去墓地。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义选择对象的过滤条件：对方场上存在的魔法·陷阱卡。
function c40921545.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时的目标选择与操作信息登记：确认可选取对象、提示选择并选定对方场上1张魔法·陷阱卡，同时登记破坏的操作信息。
function c40921545.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) end
	-- 发动条件判定：确认对方场上存在至少1张满足条件的魔法·陷阱卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c40921545.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示“请选择要破坏的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张魔法·陷阱卡作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c40921545.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记本次处理将进行的破坏操作信息，供连锁判定与相关效果互动使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段：取得之前选择的对象卡，若仍与该效果关联则将其破坏。
function c40921545.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏送去墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
