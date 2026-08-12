--ソドレミコード・グレーシア
-- 效果：
-- ←4 【灵摆】 4→
-- ①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「七音服」魔法·陷阱卡加入手卡。
-- ②：自己的灵摆区域有偶数的灵摆刻度存在，自己的「七音服」灵摆怪兽攻击的场合，对方直到伤害步骤结束时怪兽的效果不能发动。
function c91598270.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（包括灵摆召唤和作为灵摆卡发动等基本规则）
	aux.EnablePendulumAttribute(c)
	-- ①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c91598270.limcon)
	e1:SetOperation(c91598270.limop)
	c:RegisterEffect(e1)
	-- ①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetOperation(c91598270.limop2)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「七音服」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91598270,0))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,91598270)
	e3:SetTarget(c91598270.srtg)
	e3:SetOperation(c91598270.srop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ②：自己的灵摆区域有偶数的灵摆刻度存在，自己的「七音服」灵摆怪兽攻击的场合，对方直到伤害步骤结束时怪兽的效果不能发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetCondition(c91598270.actcon)
	e5:SetValue(c91598270.aclimit)
	c:RegisterEffect(e5)
end
-- 过滤条件：自己场上表侧表示的、通过灵摆召唤特殊召唤的「七音服」灵摆怪兽
function c91598270.limfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 限制效果发动条件：特殊召唤的怪兽中存在满足过滤条件的「七音服」灵摆怪兽
function c91598270.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c91598270.limfilter,1,nil,tp)
end
-- 限制效果执行：在灵摆召唤成功时，根据当前连锁情况限制对方的效果发动
function c91598270.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否没有正在处理的连锁（即灵摆召唤成功时没有触发其他入连锁的效果）
	if Duel.GetCurrentChain()==0 then
		-- 限制对方直到连锁结束前不能发动特定卡的效果
		Duel.SetChainLimitTillChainEnd(c91598270.chainlm)
	-- 判断当前连锁数是否为1（即灵摆召唤成功时有其他诱发效果发动并组成了连锁1）
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(91598270,RESET_EVENT+RESETS_STANDARD,0,1)
		-- ①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。 / ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「七音服」魔法·陷阱卡加入手卡。 / ②：自己的灵摆区域有偶数的灵摆刻度存在，自己的「七音服」灵摆怪兽攻击的场合，对方直到伤害步骤结束时怪兽的效果不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c91598270.resetop)
		-- 注册全局效果：在有新连锁发动时重置限制标记
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册全局效果：在效果处理被中断时重置限制标记
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置函数：清除卡片的限制标记并重置此重置效果自身
function c91598270.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(91598270)
	e:Reset()
end
-- 连锁结束时的处理：如果卡片带有限制标记，则在连锁结束时应用连锁限制
function c91598270.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(91598270)~=0 then
		-- 限制对方直到连锁结束前不能发动特定卡的效果
		Duel.SetChainLimitTillChainEnd(c91598270.chainlm)
	end
end
-- 连锁限制条件：对方不能发动怪兽的效果、魔法或陷阱卡（不含已表侧表示存在的魔陷的效果发动）
function c91598270.chainlm(e,ep,tp)
	return ep==tp or e:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 过滤条件：卡组中的「七音服」魔法·陷阱卡，且能加入手牌
function c91598270.srfilter(c)
	return c:IsSetCard(0x162) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 检索效果的靶向：检查卡组中是否存在可检索的卡，并设置检索操作信息
function c91598270.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「七音服」魔陷卡
	if chk==0 then return Duel.IsExistingMatchingCard(c91598270.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行：从卡组选择1张「七音服」魔陷卡加入手牌并给对方确认
function c91598270.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，要求选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「七音服」魔陷卡
	local g=Duel.SelectMatchingCard(tp,c91598270.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：灵摆刻度为偶数的卡
function c91598270.pfilter(c)
	return c:GetCurrentScale()%2==0
end
-- 封锁效果发动条件：自己场上的「七音服」灵摆怪兽进行攻击，且自己的灵摆区域存在偶数刻度的卡
function c91598270.actcon(e)
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	local tp=e:GetHandlerPlayer()
	return a and a:IsControler(tp) and a:IsSetCard(0x162) and a:IsType(TYPE_PENDULUM)
		-- 检查自己的灵摆区域是否存在至少1张偶数刻度的卡
		and Duel.IsExistingMatchingCard(c91598270.pfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- 限制发动的卡类型：怪兽的效果
function c91598270.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
