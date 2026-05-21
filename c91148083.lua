--神々の黄昏
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「极神」的怪兽发动。选择的怪兽的控制权转移给对方。下次的对方的结束阶段时，选择的怪兽破坏，对方场上存在的卡全部从游戏中除外。
function c91148083.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「极神」的怪兽发动。选择的怪兽的控制权转移给对方。下次的对方的结束阶段时，选择的怪兽破坏，对方场上存在的卡全部从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c91148083.target)
	e1:SetOperation(c91148083.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选自己场上表侧表示、名字带有「极神」且可以转移控制权的怪兽
function c91148083.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b) and c:IsControlerCanBeChanged()
end
-- 效果发动时的目标选择与检测函数
function c91148083.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c91148083.filter(chkc) end
	-- 检查自己场上是否存在至少1只符合条件的「极神」怪兽
	if chk==0 then return Duel.IsExistingTarget(c91148083.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 在界面上提示玩家选择要转移控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上1只符合条件的「极神」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c91148083.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表示此效果包含转移控制权的操作，对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理的执行函数
function c91148083.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍表侧表示存在、是否仍受此效果影响，并尝试将其控制权转移给对方
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.GetControl(tc,1-tp)~=0 then
		tc:RegisterFlagEffect(91148083,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 下次的对方的结束阶段时，选择的怪兽破坏，对方场上存在的卡全部从游戏中除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetCondition(c91148083.rmcon)
		e1:SetOperation(c91148083.rmop)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
		-- 将延迟触发的阶段效果注册给玩家，用于后续执行破坏和除外处理
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟效果的触发条件函数，用于判断是否在对方回合
function c91148083.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 延迟效果的执行函数，用于在对方结束阶段破坏该怪兽并除外对方场上的卡
function c91148083.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(91148083)==0 then return end
	-- 因效果破坏那只被转移控制权的怪兽
	Duel.Destroy(tc,REASON_EFFECT)
	-- 获取对方场上所有可以被除外的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	-- 将对方场上的卡片全部以表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
