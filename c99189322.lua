--アルカナコール
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「秘仪之力」的怪兽发动。把墓地存在的1只名字带有「秘仪之力」的怪兽从游戏中除外。直到结束阶段时，选择怪兽的投掷硬币所得效果变成从游戏中除外的怪兽的投掷硬币所得效果相同的效果。
function c99189322.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「秘仪之力」的怪兽发动；把墓地存在的1只名字带有「秘仪之力」的怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c99189322.target)
	e1:SetOperation(c99189322.activate)
	c:RegisterEffect(e1)
end
-- 作为场上对象过滤器：要求怪兽表侧表示、属于「秘仪之力」系列（0x5），且带有投掷硬币所得效果的标志（FLAG_ID_REVERSAL_OF_FATE），即已经因投掷硬币而获得效果的怪兽。
function c99189322.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x5) and c:GetFlagEffect(FLAG_ID_REVERSAL_OF_FATE)~=0
end
-- 作为墓地对象过滤器：要求怪兽属于「秘仪之力」系列（0x5），并且当前能够被除外。
function c99189322.rfilter(c)
	return c:IsSetCard(0x5) and c:IsAbleToRemove()
end
-- 发动时的合法条件检查：处理连锁对象信息后，确认自己场上存在符合条件的目标怪兽，且墓地存在可除外的「秘仪之力」怪兽，满足才可发动。
function c99189322.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1张表侧表示且已获得投掷硬币效果的「秘仪之力」怪兽，作为发动条件之一。
	if chk==0 then return Duel.IsExistingTarget(c99189322.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查墓地是否存在至少1张可除外的「秘仪之力」怪兽，作为发动条件之一。
		and Duel.IsExistingTarget(c99189322.rfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 给玩家发送提示消息“请选择表侧表示的卡”，用于选择场上表侧表示怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上主要怪兽区域选择1张符合条件的表侧「秘仪之力」怪兽，并设为当前连锁的对象。
	Duel.SelectTarget(tp,c99189322.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 给玩家发送提示消息“请选择要除外的卡”，用于选择墓地要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从双方墓地选择1张符合条件的「秘仪之力」怪兽，并设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c99189322.rfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	local tc=g:GetFirst()
	-- 将当前连锁的操作信息登记为“除外所选择的墓地怪兽”，效果分类标记为除外（CATEGORY_REMOVE）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,tc:GetControler(),LOCATION_GRAVE)
	e:SetLabelObject(g:GetFirst())
end
-- 效果处理：取出墓地怪兽和场上怪兽对象，修正顺序后，先将墓地怪兽除外；若场上怪兽仍相关且满足条件，则将其投掷硬币效果替换为被除外怪兽的对应效果，并注册结束阶段时的恢复效果。
function c99189322.activate(e,tp,eg,ep,ev,re,r,rp)
	local regc=e:GetLabelObject()
	-- 获取当前连锁处理中的对象列表，即发动时选择的场上怪兽和墓地怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==regc then tc=g:GetNext() end
	if not regc:IsRelateToEffect(e) then return end
	-- 将墓地怪兽以表侧表示除外（效果原因），若除外失败或该卡未进入除外区则中止后续处理。
	if Duel.Remove(regc,POS_FACEUP,REASON_EFFECT)==0 or not regc:IsLocation(LOCATION_REMOVED) then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetFlagEffect(FLAG_ID_REVERSAL_OF_FATE)~=0 and tc:GetFlagEffect(FLAG_ID_ARCANA_COIN)~=0 then
		local cid=tc:ReplaceEffect(regc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterFlagEffect(99189322,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,0,1)
		-- 直到结束阶段时，选择怪兽的投掷硬币所得效果变成从游戏中除外的怪兽的投掷硬币所得效果相同的效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(cid)
		e1:SetLabelObject(tc)
		e1:SetOperation(c99189322.rec_effect)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将结束阶段时用于恢复原始效果的事件效果注册给当前玩家。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段时的恢复处理：若对象怪兽仍带着标记，则将之前被替换成的效果重置，使其恢复原有的投掷硬币所得效果。
function c99189322.rec_effect(e,tp,eg,ep,ev,re,r,rp)
	local cid=e:GetLabel()
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(99189322)==0 then return end
	tc:ResetEffect(cid,RESET_COPY)
end
