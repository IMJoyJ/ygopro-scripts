--ジャンク・アーチャー
-- 效果：
-- 「废品同调士」＋调整以外的怪兽1只以上
-- 1回合1次，选择对方场上存在的1只怪兽才能发动。选择的怪兽从游戏中除外。这个效果除外的怪兽在这个回合的结束阶段时以相同表示形式回到对方场上。
function c42810973.initial_effect(c)
	-- 为怪兽添加允许使用的素材卡牌代码，此处添加了废品同调士的卡号作为可选素材
	aux.AddMaterialCodeList(c,63977008)
	-- 设置该怪兽的同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,c42810973.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，选择对方场上存在的1只怪兽才能发动。选择的怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42810973,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c42810973.target)
	e1:SetOperation(c42810973.operation)
	c:RegisterEffect(e1)
end
c42810973.material_setcode=0x1017
-- 定义用于同调召唤的调整过滤函数，允许废品同调士或具有特定效果的卡作为调整
function c42810973.tfilter(c)
	return c:IsCode(63977008) or c:IsHasEffect(20932152)
end
-- 设置效果的发动目标选择阶段，选择对方场上1只可除外的怪兽
function c42810973.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 检查是否满足发动条件，即对方场上是否存在可除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只可除外的怪兽作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果的处理信息，确定要除外的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 设置效果的发动处理阶段，将目标怪兽除外并注册结束阶段返回效果
function c42810973.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然存在于场上且成功除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 在结束阶段时将除外的怪兽以相同表示形式返回对方场上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetOperation(c42810973.retop)
		-- 将结束阶段返回效果注册到游戏环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义结束阶段返回效果的处理函数
function c42810973.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将指定的怪兽以相同表示形式返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
