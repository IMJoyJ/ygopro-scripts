--スクラップ・ポリッシュ
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「废铁」的怪兽破坏。自己场上表侧表示存在的全部名字带有「废铁」的怪兽的攻击力直到这个回合的结束阶段时上升1000。
function c74439492.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「废铁」的怪兽破坏。自己场上表侧表示存在的全部名字带有「废铁」的怪兽的攻击力直到这个回合的结束阶段时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c74439492.target)
	e1:SetOperation(c74439492.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的名字带有「废铁」的怪兽
function c74439492.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x24)
end
-- 效果发动时的对象选择与可行性检查
function c74439492.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c74439492.filter(chkc) end
	-- 检查自己场上是否存在至少1只可以作为对象的表侧表示「废铁」怪兽
	if chk==0 then return Duel.IsExistingTarget(c74439492.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查自己场上是否至少存在2只表侧表示的「废铁」怪兽（确保破坏1只后仍有怪兽可以上升攻击力）
		and Duel.IsExistingMatchingCard(c74439492.filter,tp,LOCATION_MZONE,0,2,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示的「废铁」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c74439492.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表示该效果包含破坏1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理的执行函数
function c74439492.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽在场上表侧表示存在且成功被该效果破坏
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 获取当前自己场上表侧表示存在的全部「废铁」怪兽
		local g=Duel.GetMatchingGroup(c74439492.filter,tp,LOCATION_MZONE,0,nil)
		local ac=g:GetFirst()
		while ac do
			-- 攻击力直到这个回合的结束阶段时上升1000。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			ac:RegisterEffect(e1)
			ac=g:GetNext()
		end
	end
end
