--ブリキの大公
-- 效果：
-- 4星怪兽×3
-- 1回合1次，把这张卡1个超量素材取除，选择对方场上1只怪兽才能发动。选择的怪兽的表示形式变更。这个时候，反转效果怪兽的效果不发动。这个效果在对方回合也能发动。
function c66506689.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽×3
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，选择对方场上1只怪兽才能发动。选择的怪兽的表示形式变更。这个时候，反转效果怪兽的效果不发动。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66506689,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c66506689.cost)
	e1:SetTarget(c66506689.tg)
	e1:SetOperation(c66506689.op)
	c:RegisterEffect(e1)
end
-- 效果发动的代价：检测并取除这张卡的1个超量素材
function c66506689.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：可以改变表示形式的怪兽
function c66506689.filter(c)
	return c:IsCanChangePosition()
end
-- 效果发动的目标选择：判定并选择对方场上1只可以改变表示形式的怪兽作为对象
function c66506689.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c66506689.filter(chkc) end
	-- 判定对方场上是否存在至少1只可以改变表示形式的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c66506689.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息：请选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上1只可以改变表示形式的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66506689.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：获取对象怪兽并改变其表示形式，且不触发反转效果
function c66506689.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 改变目标怪兽的表示形式（表侧守备与表侧攻击互相转换），且不触发反转效果
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)
	end
end
