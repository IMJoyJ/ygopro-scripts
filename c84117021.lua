--魔力隔壁
-- 效果：
-- ①：可以从以下效果选择1个发动。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
-- ●这个回合，魔法师族怪兽的召唤·反转召唤·特殊召唤不会被无效化，在魔法师族怪兽的召唤·反转召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
-- ●以自己场上1只魔法师族怪兽为对象才能发动。这个回合那只怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
function c84117021.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。●这个回合，魔法师族怪兽的召唤·反转召唤·特殊召唤不会被无效化，在魔法师族怪兽的召唤·反转召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。●以自己场上1只魔法师族怪兽为对象才能发动。这个回合那只怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c84117021.target)
	e1:SetOperation(c84117021.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的魔法师族怪兽
function c84117021.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 效果发动时的目标选择与分支判定处理
function c84117021.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c84117021.filter(chkc) end
	if chk==0 then return true end
	local opt=0
	-- 检查自己场上是否存在可以作为对象的表侧表示魔法师族怪兽
	if Duel.IsExistingTarget(c84117021.filter,tp,LOCATION_MZONE,0,1,nil) then
		-- 让玩家选择发动其中一个效果分支
		opt=Duel.SelectOption(tp,aux.Stringid(84117021,0),aux.Stringid(84117021,1))  --"这个回合，魔法师族怪兽的召唤·反转召唤·特殊召唤不会被无效化，在魔法师族怪兽的召唤·反转召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。/以自己场上1只魔法师族怪兽为对象才能发动。这个回合那只怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。"
	end
	-- 将玩家选择的效果分支序号保存为效果的目标参数
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetProperty(0)
	else
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择自己场上1只表侧表示的魔法师族怪兽作为对象
		Duel.SelectTarget(tp,c84117021.filter,tp,LOCATION_MZONE,0,1,1,nil)
	end
end
-- 效果处理，根据选择的分支适用对应的效果，并使对方受到的全部伤害变成0
function c84117021.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时玩家选择的效果分支序号
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if opt==0 then
		-- 这个回合，魔法师族怪兽的召唤·反转召唤·特殊召唤不会被无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
		e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
		-- 设置不会被无效化的怪兽种族为魔法师族
		e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册魔法师族怪兽召唤不会被无效化的效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
		-- 注册魔法师族怪兽特殊召唤不会被无效化的效果
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_DISABLE_FLIP_SUMMON)
		-- 注册魔法师族怪兽反转召唤不会被无效化的效果
		Duel.RegisterEffect(e3,tp)
		-- 在魔法师族怪兽的召唤·反转召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_SUMMON_SUCCESS)
		e4:SetCondition(c84117021.sumcon)
		e4:SetOperation(c84117021.sumsuc)
		e4:SetReset(RESET_PHASE+PHASE_END)
		-- 注册魔法师族怪兽召唤成功时对方不能发动效果的事件监听
		Duel.RegisterEffect(e4,tp)
		local e5=e4:Clone()
		e5:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 注册魔法师族怪兽特殊召唤成功时对方不能发动效果的事件监听
		Duel.RegisterEffect(e5,tp)
		local e6=e4:Clone()
		e6:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		-- 注册魔法师族怪兽反转召唤成功时对方不能发动效果的事件监听
		Duel.RegisterEffect(e6,tp)
		-- 在魔法师族怪兽的召唤·反转召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。/以自己场上1只魔法师族怪兽为对象才能发动。
		local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e7:SetCode(EVENT_CHAIN_END)
		e7:SetOperation(c84117021.limop2)
		-- 注册连锁结束时重置限制对方发动效果状态的事件监听
		Duel.RegisterEffect(e7,tp)
	else
		-- 获取作为效果对象的魔法师族怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			-- 这个回合那只怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_ATTACK_ANNOUNCE)
			e1:SetOperation(c84117021.atkop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册对方受到的伤害变成0的效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册对方受到的效果伤害变成0的效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 检查召唤·反转召唤·特殊召唤成功的怪兽中是否存在魔法师族怪兽
function c84117021.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c84117021.filter,1,nil)
end
-- 魔法师族怪兽召唤成功时的处理，若在非连锁中则直接限制对方发动效果，若在连锁中则注册标记并在连锁结束时限制对方发动效果
function c84117021.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否不处于任何连锁的处理中
	if Duel.GetCurrentChain()==0 then
		-- 限制对方直到连锁结束前不能发动任何卡的效果
		Duel.SetChainLimitTillChainEnd(c84117021.chainlm)
	-- 判定当前是否处于连锁1的处理中
	elseif Duel.GetCurrentChain()==1 then
		-- 给玩家注册全局标识，用于记录需要在连锁结束时限制对方发动效果
		Duel.RegisterFlagEffect(tp,84117021,RESET_PHASE+PHASE_END,0,1)
		-- 在魔法师族怪兽的召唤·反转召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。/这个回合那只怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c84117021.resetop)
		-- 注册在有新连锁发动时重置限制标记的事件监听
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册在效果处理中途被中断时重置限制标记的事件监听
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置限制标记并使自身重置的函数
function c84117021.resetop(e,tp,eg,ep,ev,re,r,rp)
	-- 清除玩家的限制标记
	Duel.ResetFlagEffect(tp,84117021)
	e:Reset()
end
-- 连锁结束时的处理，若存在限制标记则限制对方直到连锁结束前不能发动效果，并清除标记
function c84117021.limop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否存在限制标记
	if Duel.GetFlagEffect(tp,84117021)>0 then
		-- 限制对方直到连锁结束前不能发动任何卡的效果
		Duel.SetChainLimitTillChainEnd(c84117021.chainlm)
	end
	-- 清除玩家的限制标记
	Duel.ResetFlagEffect(tp,84117021)
end
-- 限制对方玩家发动效果的过滤函数（仅允许自己发动效果）
function c84117021.chainlm(e,ep,tp)
	return ep==tp
end
-- 攻击宣言时的处理，注册对方直到伤害步骤结束前不能发动效果的状态
function c84117021.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册对方直到伤害步骤结束前不能发动卡的效果
	Duel.RegisterEffect(e1,tp)
end
