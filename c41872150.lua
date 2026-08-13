--イナゴの軍勢
-- 效果：
-- 这张卡1个回合可以有1次变回里侧守备表示。这张卡反转召唤成功时，破坏对方场上1张魔法·陷阱卡。
function c41872150.initial_effect(c)
	-- 这张卡1个回合可以有1次变回里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41872150,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c41872150.target)
	e1:SetOperation(c41872150.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转召唤成功时，破坏对方场上1张魔法·陷阱卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41872150,1))  --"破坏对方1张魔法·陷阱卡"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c41872150.destg)
	e2:SetOperation(c41872150.desop)
	c:RegisterEffect(e2)
end
-- 起动效果的发动条件判定：确认此卡可以变成里侧守备表示且本回合未使用过该效果；若满足则登记本回合已使用的标记，并设置将进行表示变更的操作信息。
function c41872150.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(41872150)==0 end
	c:RegisterFlagEffect(41872150,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：声明此效果将把此卡变为里侧守备表示（分类CATEGORY_POSITION），数量为1，供其他效果（如星尘龙等）进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理：若此卡仍与发动效果关联且为表侧表示，则将其变成里侧守备表示。
function c41872150.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将此卡的表示形式变更为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤函数：判断一张卡是否为魔法·陷阱卡，用于选择破坏对象。
function c41872150.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 反转召唤成功时必发效果的取对象处理：当指定对象时验证其为对方场上魔法·陷阱卡；发动时返回可发动，随后提示玩家选择对方场上1张魔法·陷阱卡为对象，并设置破坏操作信息。
function c41872150.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c41872150.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张魔法·陷阱卡作为效果对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c41872150.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：声明此效果将破坏所选对象（分类CATEGORY_DESTROY），数量为对象数，供连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：取得效果的对象卡，若对象仍与效果关联，则将其破坏。
function c41872150.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中的效果对象卡（本效果为单一对象）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏并送去墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
