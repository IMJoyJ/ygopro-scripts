--カラクリ屋敷
-- 效果：
-- 自己场上表侧表示存在的名字带有「机巧」的怪兽的表示形式变更时才能发动。选择场上存在的1张卡破坏。
function c33184236.initial_effect(c)
	-- 效果发动条件：自己场上表侧表示存在的名字带有「机巧」的怪兽的表示形式变更时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetCondition(c33184236.condition)
	e1:SetTarget(c33184236.target)
	e1:SetOperation(c33184236.activate)
	c:RegisterEffect(e1)
end
-- 过滤器函数：检查怪兽是否为控制者且名字带有「机巧」，并且表示形式发生改变（从正面表示变为背面表示或反之）
function c33184236.cfilter(c,tp)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return c:IsControler(tp) and c:IsSetCard(0x11) and ((pp==0x1 and np==0x4) or (pp==0x4 and np==0x1))
end
-- 条件函数：判断是否有满足过滤条件的怪兽被选中
function c33184236.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c33184236.cfilter,1,nil,tp)
end
-- 目标选择函数：选择场上存在的1张卡作为破坏对象
function c33184236.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 检查阶段：确认场上存在满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示信息：向玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标：从场上选择1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：将破坏效果的处理对象和数量记录到连锁信息中
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数：对选中的卡进行破坏处理
function c33184236.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标：获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行破坏：以效果为原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
