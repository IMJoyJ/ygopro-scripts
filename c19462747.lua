--BF－弔風のデス
-- 效果：
-- 「黑羽-吊风之戴思」的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功时，可以以自己场上1只「黑羽」怪兽为对象，从以下效果选择1个发动。
-- ●作为对象的怪兽的等级上升1星。
-- ●作为对象的怪兽的等级下降1星。
-- ②：这张卡被送去墓地的回合的结束阶段发动。自己受到1000伤害。
function c19462747.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时，可以以自己场上1只「黑羽」怪兽为对象，从以下效果选择1个发动。
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
	-- ②：这张卡被送去墓地的回合的结束阶段发动。自己受到1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c19462747.regop)
	c:RegisterEffect(e3)
	-- 「黑羽-吊风之戴思」的①的效果1回合只能使用1次。
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
-- 筛选场上表侧表示的黑羽怪兽作为效果对象
function c19462747.filter(c)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsSetCard(0x33)
end
-- 设置效果选择目标，选择场上1只黑羽怪兽作为对象
function c19462747.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19462747.filter(chkc) end
	-- 判断是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c19462747.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只黑羽怪兽作为对象
	local g=Duel.SelectTarget(tp,c19462747.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local op=0
	-- 提示玩家选择要发动的效果
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	if g:GetFirst():IsLevel(1) then
		-- 选择等级上升效果
		op=Duel.SelectOption(tp,aux.Stringid(19462747,1))  --"等级上升"
	else
		-- 选择等级上升或下降效果
		op=Duel.SelectOption(tp,aux.Stringid(19462747,1),aux.Stringid(19462747,2))  --"等级上升/等级下降"
	end
	e:SetLabel(op)
end
-- 将对象怪兽的等级上升或下降1星
function c19462747.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建等级变更效果，使对象怪兽等级上升或下降1星
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
-- 在怪兽被送去墓地时注册标记，用于触发效果
function c19462747.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(19462747,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否满足触发伤害效果的条件
function c19462747.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(19462747)>0
end
-- 设置伤害效果的目标玩家和伤害值
function c19462747.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置伤害效果的伤害值为1000
	Duel.SetTargetParam(1000)
	-- 设置伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 执行伤害效果，使玩家受到1000伤害
function c19462747.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成1000伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
