--ジャンク・アーチャー
-- 效果：
-- 「废品同调士」＋调整以外的怪兽1只以上
-- 1回合1次，选择对方场上存在的1只怪兽才能发动。选择的怪兽从游戏中除外。这个效果除外的怪兽在这个回合的结束阶段时以相同表示形式回到对方场上。
function c42810973.initial_effect(c)
	-- 为该卡指定‘废品同调士’作为其同调素材卡名之一，用于判定素材是否合法。
	aux.AddMaterialCodeList(c,63977008)
	-- 为这张卡添加同调召唤手续：调整必须为‘废品同调士’或拥有其替代效果的怪兽，调整以外怪兽1只以上。
	aux.AddSynchroProcedure(c,c42810973.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应效果原文：‘1回合1次，选择对方场上存在的1只怪兽才能发动。选择的怪兽从游戏中除外。这个效果除外的怪兽在这个回合的结束阶段时以相同表示形式回到对方场上。’
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
-- 同调调整素材的过滤条件：满足‘废品同调士’卡名或拥有指定替代素材效果（20932152）的怪兽均可作为调整素材。
function c42810973.tfilter(c)
	return c:IsCode(63977008) or c:IsHasEffect(20932152)
end
-- 效果发动时的目标处理函数：确认对象合法性，选择对方场上1只可除外的怪兽，并注册除外操作信息。
function c42810973.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 发动合法性检查：确认对方场上存在至少1只可以被除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家显示‘请选择要除外的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方场上选择1只可以除外的怪兽作为效果对象（同时将该卡设置为当前连锁的对象）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：本次处理为除外1只对象怪兽（CATEGORY_REMOVE）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理：取得对象卡，若仍与效果关联则将其暂时除外（REASON_EFFECT+REASON_TEMPORARY），并注册一个结束阶段将其返回场上的效果。
function c42810973.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁中记录的第一张效果对象卡（即被选择要除外的怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否仍与效果关联，若关联且能成功暂时除外，则进行后续的返回处理。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 对应效果原文：‘这个效果除外的怪兽在这个回合的结束阶段时以相同表示形式回到对方场上。’
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetOperation(c42810973.retop)
		-- 将刚才创建的结束阶段返回效果注册到场上（由当前玩家tp控制），使其在回合结束时生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义结束阶段触发时的返回操作：将被记录的对象卡返回场上。
function c42810973.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将效果记录中暂存的怪兽（LabelObject）以离场前的表示形式返回对方场上（结束阶段回归）。
	Duel.ReturnToField(e:GetLabelObject())
end
