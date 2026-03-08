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
-- 检查是否可以将此卡变为里侧守备表示，并且此卡在本回合未使用过该效果
function c41872150.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(41872150)==0 end
	c:RegisterFlagEffect(41872150,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁操作信息，表示此效果会改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 执行将此卡变为里侧守备表示的操作
function c41872150.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将此卡变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤魔法卡或陷阱卡
function c41872150.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置连锁操作信息，表示此效果会破坏对方场上的魔法或陷阱卡
function c41872150.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c41872150.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张魔法或陷阱卡作为破坏目标
	local g=Duel.SelectTarget(tp,c41872150.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，表示此效果会破坏目标卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏目标卡片的操作
function c41872150.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
