--結界術師 メイコウ
-- 效果：
-- 把这张卡解放发动。场上表侧表示存在的1张永续魔法或者永续陷阱卡破坏。
function c47731128.initial_effect(c)
	-- 把这张卡解放发动。场上表侧表示存在的1张永续魔法或者永续陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47731128,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c47731128.cost)
	e1:SetTarget(c47731128.target)
	e1:SetOperation(c47731128.operation)
	c:RegisterEffect(e1)
end
-- 代价函数：当chk==0时检查自身是否可解放；否则以解放自身作为代价。
function c47731128.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价原因（REASON_COST）解放此卡自身。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：对象须为表侧表示，且为永续魔法（类型等于0x20002）或永续陷阱（类型同时包含陷阱与永续标志，即bit.band(tpe,0x20004)==0x20004）。
function c47731128.filter(c)
	local tpe=c:GetType()
	return c:IsFaceup() and (tpe==0x20002 or bit.band(tpe,0x20004)==0x20004)
end
-- 目标选择函数：确认场上存在合法对象后，从双方场上选择1张符合条件的表侧表示永续魔法/永续陷阱作为效果对象，并登记破坏的操作信息。
function c47731128.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c47731128.filter(chkc) end
	-- 检查双方场上是否存在至少1张符合条件的表侧表示永续魔法/永续陷阱，且不选择发动效果的这张卡自身（e:GetHandler()作为排除项）。
	if chk==0 then return Duel.IsExistingTarget(c47731128.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向操作玩家发送选择破坏对象的提示消息（请选择要破坏的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张符合条件的表侧表示永续魔法/永续陷阱，并自动将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c47731128.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记当前连锁的操作信息：将对1张卡进行破坏处理，供相关效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数：取得之前选择的对象，若对象仍与此效果关联，则将其破坏。
function c47731128.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的那1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
