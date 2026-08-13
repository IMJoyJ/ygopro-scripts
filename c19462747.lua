--BF－弔風のデス
-- 效果：
-- 「黑羽-吊风之戴思」的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功时，可以以自己场上1只「黑羽」怪兽为对象，从以下效果选择1个发动。
-- ●作为对象的怪兽的等级上升1星。
-- ●作为对象的怪兽的等级下降1星。
-- ②：这张卡被送去墓地的回合的结束阶段发动。自己受到1000伤害。
function c19462747.initial_effect(c)
	-- 「黑羽-吊风之戴思」的①的效果1回合只能使用1次。①：这张卡召唤成功时，可以以自己场上1只「黑羽」怪兽为对象，从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19462747,0))  --"等级变更"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,19462747)
	e1:SetTarget(c19462747.target)
	e1:SetOperation(c19462747.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的回合……
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c19462747.regop)
	c:RegisterEffect(e3)
	-- ……的结束阶段发动。自己受到1000伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(19462747,3))  --"受到伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(c19462747.damcon)
	e4:SetTarget(c19462747.damtg)
	e4:SetOperation(c19462747.damop)
	c:RegisterEffect(e4)
end
-- 过滤可作为对象的「黑羽」怪兽：必须是表侧表示、等级大于0、且属于「黑羽」字段。
function c19462747.filter(c)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsSetCard(0x33)
end
-- 效果发动时的目标选择与选项处理：检查是否存在符合条件的对象，选择1只对象怪兽，并选择“等级上升”或“等级下降”选项，将选项存入效果标签。
function c19462747.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19462747.filter(chkc) end
	-- 发动时检查自己场上是否存在至少1只符合条件的「黑羽」怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c19462747.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家弹出“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只符合条件的「黑羽」怪兽作为效果对象，并设置为连锁对象。
	local g=Duel.SelectTarget(tp,c19462747.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local op=0
	-- 给玩家弹出“请选择要发动的效果”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	if g:GetFirst():IsLevel(1) then
		-- 当对象怪兽等级为1时，只提供“等级上升”选项，因为等级下降会导致等级变为0而不合法。
		op=Duel.SelectOption(tp,aux.Stringid(19462747,1))  --"等级上升"
	else
		-- 当对象怪兽等级大于1时，提供“等级上升”和“等级下降”两个选项供玩家选择。
		op=Duel.SelectOption(tp,aux.Stringid(19462747,1),aux.Stringid(19462747,2))  --"等级上升/等级下降"
	end
	e:SetLabel(op)
end
-- 效果处理：若对象怪兽仍表侧表示且与效果有联系，则给对象注册一个等级变更效果，根据之前选择的选项使其等级上升1星或下降1星。
function c19462747.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- ●作为对象的怪兽的等级上升1星。●作为对象的怪兽的等级下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		if e:GetLabel()==0 then
			e1:SetValue(1)
		else
			e1:SetValue(-1)
		end
		tc:RegisterEffect(e1)
	end
end
-- 给这张卡标记“本回合被送去墓地”的Flag，该标记在结束阶段时重置。
function c19462747.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(19462747,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 伤害效果的发动条件：这张卡拥有本回合被送去墓地的标记。
function c19462747.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(19462747)>0
end
-- 伤害效果的目标设定：将受到伤害的玩家设为自己，伤害值设为1000，并登记伤害效果的操作信息。
function c19462747.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的对象玩家设置为自己，即由自己受到伤害。
	Duel.SetTargetPlayer(tp)
	-- 将连锁的对象参数设置为1000，即伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记本次连锁的伤害操作信息，用于发动时点/无效等效果的检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 伤害效果的实际处理：根据之前设定的玩家和伤害值执行效果伤害。
function c19462747.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的方式给予对象玩家1000点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
