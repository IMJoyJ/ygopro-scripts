--三相魔神コーディウス
-- 效果：
-- 同调怪兽＋超量怪兽＋连接怪兽
-- 这个卡名的效果1回合只能使用1次。
-- ①：只在融合召唤的这张卡在场上表侧表示存在才有1次，可以支付2000的倍数的基本分，从以下效果选择支付的基本分每2000为1个的数量发动。
-- ●从自己墓地选1张魔法·陷阱卡加入手卡。
-- ●选对方场上3张卡破坏。
-- ●这个回合，其他的自己怪兽不能攻击，这张卡的攻击力上升双方基本分差的一半数值。
function c70219023.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为同调怪兽、超量怪兽、连接怪兽各1只，且不能使用融合代替素材
	aux.AddFusionProcMix(c,false,true,c70219023.fusfilter1,c70219023.fusfilter2,c70219023.fusfilter3)
	-- ①：只在融合召唤的这张卡在场上表侧表示存在才有1次，可以支付2000的倍数的基本分，从以下效果选择支付的基本分每2000为1个的数量发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(c70219023.regcon)
	e1:SetOperation(c70219023.regop)
	c:RegisterEffect(e1)
end
c70219023.material_type=TYPE_SYNCHRO
-- 过滤融合素材中的同调怪兽
function c70219023.fusfilter1(c)
	return c:IsFusionType(TYPE_SYNCHRO)
end
-- 过滤融合素材中的超量怪兽
function c70219023.fusfilter2(c)
	return c:IsFusionType(TYPE_XYZ)
end
-- 过滤融合素材中的连接怪兽
function c70219023.fusfilter3(c)
	return c:IsFusionType(TYPE_LINK)
end
-- 检查这张卡是否是通过融合召唤特殊召唤的
function c70219023.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 为融合召唤成功的这张卡注册一个在场上表侧表示存在时只能发动1次的起动效果
function c70219023.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 可以支付2000的倍数的基本分，从以下效果选择支付的基本分每2000为1个的数量发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY+CATEGORY_ATKCHANGE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,70219023)
	e1:SetTarget(c70219023.target)
	e1:SetOperation(c70219023.operation)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地可以加入手牌的魔法、陷阱卡
function c70219023.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与支付基本分Cost处理，根据支付的基本分数量（每2000分选择1个）来决定适用的效果分支
function c70219023.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local off=1
	local ops={}
	local opval={}
	-- 检查自己墓地是否存在可以加入手牌的魔法、陷阱卡
	if Duel.IsExistingMatchingCard(c70219023.thfilter,tp,LOCATION_GRAVE,0,1,nil) then
		ops[off]=aux.Stringid(70219023,1)  --"从自己墓地选1张魔法·陷阱卡加入手卡"
		opval[off]=1
		off=off+1
	end
	-- 检查对方场上是否存在至少3张卡
	if Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,3,nil) then
		ops[off]=aux.Stringid(70219023,2)  --"选对方场上3张卡破坏"
		opval[off]=2
		off=off+1
	end
	local ops_lp_equal={table.unpack(ops)}
	local opval_lp_equal={table.unpack(opval)}
	ops[off]=aux.Stringid(70219023,3)  --"这张卡的攻击力上升"
	opval[off]=4
	off=off+1
	if chk==0 then return off>1 end
	local op=0
	local pay=0
	-- 循环检查玩家是否能继续支付每2000分（最多支付6000分，即选择3个效果）
	while pay<6000 and Duel.CheckLPCost(tp,pay+2000,true) do
		local sel
		local selval
		-- 检查支付基本分后双方基本分差值是否不为0（若为0则无法选择攻击力上升的效果）
		if Duel.GetLP(tp)-pay-2000-Duel.GetLP(1-tp)~=0 then
			-- 让玩家从当前可用的效果选项中选择一个
			sel=Duel.SelectOption(tp,table.unpack(ops))+1
			selval=opval[sel]
		else
			-- 在支付后双方基本分相等的情况下，让玩家从不包含“攻击力上升”效果的选项中选择一个
			sel=Duel.SelectOption(tp,table.unpack(ops_lp_equal))+1
			selval=opval_lp_equal[sel]
		end
		if pay==0 then
			ops[off]=aux.Stringid(70219023,4)  --"不继续选择"
			opval[off]=0
			ops_lp_equal[off-1]=aux.Stringid(70219023,4)  --"不继续选择"
			opval_lp_equal[off-1]=0
		end
		if selval==0 then break end
		table.remove(ops,sel)
		table.remove(opval,sel)
		table.remove(ops_lp_equal,sel)
		table.remove(opval_lp_equal,sel)
		op=op|selval
		pay=pay+2000
	end
	-- 让玩家支付所选效果对应的累计基本分
	Duel.PayLPCost(tp,pay,true)
	e:SetLabel(op)
	e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(70219023,0))  --"已发动过效果"
end
-- 效果处理，根据玩家在发动时选择并支付基本分所决定的效果分支，依次执行对应的效果
function c70219023.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op&1~=0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 过滤并选择自己墓地1张不受王家长眠之谷影响的魔法、陷阱卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c70219023.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
	end
	if op&2~=0 then
		-- 中断当前效果，使后续的破坏处理与之前的加入手牌处理不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的3张卡
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,3,3,nil)
		-- 选中对方场上的3张卡并显示选择动画
		Duel.HintSelection(g)
		-- 破坏选中的对方场上的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
	if op&4~=0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 中断当前效果，使后续的攻击力上升及攻击限制处理与之前的破坏处理不视为同时进行
		Duel.BreakEffect()
		-- 计算双方当前基本分差值的一半（向下取整）
		local atk=math.floor(math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))/2)
		-- 这张卡的攻击力上升双方基本分差的一半数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 这个回合，其他的自己怪兽不能攻击
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetCode(EFFECT_CANNOT_ATTACK)
		e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e0:SetTargetRange(LOCATION_MZONE,0)
		e0:SetTarget(c70219023.ftarget)
		e0:SetLabel(c:GetFieldID())
		e0:SetReset(RESET_PHASE+PHASE_END)
		-- 在全局注册“其他自己怪兽不能攻击”的效果
		Duel.RegisterEffect(e0,tp)
	end
end
-- 过滤出除这张卡以外的其他自己场上的怪兽
function c70219023.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
