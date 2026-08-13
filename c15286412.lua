--極星宝グングニル
-- 效果：
-- 把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
function c15286412.initial_effect(c)
	-- 把自己场上表侧表示存在的1只名字带有「极神」或者「极星」的怪兽从游戏中除外，选择场上存在的1张卡发动。选择的卡破坏。发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c15286412.cost)
	e1:SetTarget(c15286412.target)
	e1:SetOperation(c15286412.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：该怪兽需表侧表示、卡名含有「极神」或「极星」字段，并且可以作为代价从游戏中除外。
function c15286412.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x42,0x4b) and c:IsAbleToRemoveAsCost()
end
-- 发动代价处理：将1只满足条件的自己场上的极神/极星怪兽从游戏中除外作为代价，并将其保存为LabelObject，同时Label置1表示已支付过代价；在合法性检查时仅确认存在满足条件的卡。
function c15286412.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 代价合法性检查：确认自己场上存在至少1只满足条件的怪兽可以作为发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c15286412.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示‘请选择要除外的卡’，用于选择代价怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1只满足条件的表侧表示极神/极星怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c15286412.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽从游戏中除外（作为代价，标记为暂时除外），以便后续通过Duel.ReturnToField返回场上。
	Duel.Remove(g,0,REASON_COST+REASON_TEMPORARY)
	e:SetLabelObject(g:GetFirst())
end
-- 目标选择处理：选择场上除本卡以外的1张卡作为破坏对象，并设定操作信息；在合法性检查时将代价标记重置为0，确认存在可选择为对象的卡。
function c15286412.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	if chk==0 then
		e:SetLabel(0)
		-- 目标合法性检查：确认场上存在除本卡以外可供选择为对象的卡。
		return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	end
	-- 向玩家显示选择提示‘请选择要破坏的卡’，用于选择破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张卡（除本卡外）作为破坏对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：本次效果将会破坏对象卡g，数量为1，供相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：如果对象卡仍与效果关联且被成功破坏，且已支付过除外代价，则为发动者注册一个延迟效果，在接下来的结束阶段计数并最终让除外的怪兽返回场上。
function c15286412.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否仍与效果关联，并执行破坏；若破坏成功且已支付除外代价，则继续创建延迟返回效果。
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and e:GetLabel()==1 then
		-- 发动后第2次的自己的结束阶段时，为这个效果发动而从游戏中除外的怪兽表侧攻击表示回到场上。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetCondition(c15286412.retcon)
		e1:SetOperation(c15286412.retop)
		e1:SetLabel(2)
		e1:SetLabelObject(e:GetLabelObject())
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		-- 将延迟回场效果注册到当前发动玩家，使其在结束阶段被触发。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟效果的触发条件：必须是自己的结束阶段才触发。
function c15286412.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为发动者（即只在自己回合的结束阶段成立）。
	return Duel.GetTurnPlayer()==tp
end
-- 延迟效果操作：每次自己的结束阶段将计数减1，计数减到0时，将之前除外的怪兽以表侧攻击表示返回场上。
function c15286412.retop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct-1
	e:SetLabel(ct)
	-- 当计数达到0时，将效果发动时除外的怪兽以表侧攻击表示返回场上。
	if ct==0 then Duel.ReturnToField(e:GetLabelObject(),POS_FACEUP_ATTACK) end
end
