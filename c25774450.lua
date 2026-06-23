--死のマジック・ボックス
-- 效果：
-- ①：以自己以及对方场上的怪兽各1只为对象才能发动。那只对方怪兽破坏。那之后，那只自己怪兽的控制权移给对方。
function c25774450.initial_effect(c)
	-- ①：以自己以及对方场上的怪兽各1只为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c25774450.target)
	e1:SetOperation(c25774450.activate)
	c:RegisterEffect(e1)
end
-- 检查目标怪兽是否能被破坏
function c25774450.filter(c,tp)
	-- 判断目标怪兽是否能被破坏
	return Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 效果的发动条件判断
function c25774450.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断对方场上是否存在可破坏的怪兽
	if chk==0 then return Duel.IsExistingTarget(c25774450.filter,tp,0,LOCATION_MZONE,1,nil,1-tp)
		-- 判断自己场上是否存在可改变控制权的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1只怪兽作为破坏对象
	local g1=Duel.SelectTarget(tp,c25774450.filter,tp,0,LOCATION_MZONE,1,1,nil,1-tp)
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上的1只怪兽作为控制权转移对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果操作信息：破坏对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设置效果操作信息：控制权转移对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g2,1,0,0)
end
-- 效果的处理函数
function c25774450.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取破坏效果的操作信息
	local ex1,dg=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	-- 获取控制权转移效果的操作信息
	local ex2,cg=Duel.GetOperationInfo(0,CATEGORY_CONTROL)
	local dc=dg:GetFirst()
	local cc=cg:GetFirst()
	-- 判断破坏对象是否仍然在场并执行破坏
	if dc:IsRelateToEffect(e) and Duel.Destroy(dc,REASON_EFFECT)~=0 then
		if cc:IsRelateToEffect(e) then
			-- 中断当前效果处理，防止时点错乱
			Duel.BreakEffect()
			-- 将控制权转移给对方玩家
			Duel.GetControl(cc,1-tp)
		end
	end
end
