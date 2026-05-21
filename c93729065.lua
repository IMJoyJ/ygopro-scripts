--スターヴ・ヴェネミー・ドラゴン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：每次场上的卡被送去墓地，每有1张给这张卡放置1个蛊指示物。
-- ②：龙族·暗属性怪兽以外的场上的怪兽的攻击力下降场上的蛊指示物数量×200。
-- ③：1回合1次，可以把战斗发生的对自己的战斗伤害变成0。
-- 【怪兽效果】
-- 暗属性怪兽＋灵摆怪兽
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。直到结束阶段，这张卡当作和那只怪兽同名卡使用，得到相同效果。那之后，作为对象的怪兽的攻击力·守备力下降500，效果无效化，给与对方500伤害。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c93729065.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片注册灵摆怪兽属性（不注册灵摆卡“卡的发动”的效果）
	aux.EnablePendulumAttribute(c,false)
	-- 注册融合召唤手续，融合素材为暗属性怪兽和灵摆怪兽各1只
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),aux.FilterBoolFunction(Card.IsFusionType,TYPE_PENDULUM),true)
	-- ①：每次场上的卡被送去墓地，每有1张给这张卡放置1个蛊指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(c93729065.counter)
	c:RegisterEffect(e1)
	-- ②：龙族·暗属性怪兽以外的场上的怪兽的攻击力下降场上的蛊指示物数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c93729065.atktg)
	e2:SetValue(c93729065.atkval)
	c:RegisterEffect(e2)
	-- ③：1回合1次，可以把战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93729065,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(c93729065.rdcon)
	e3:SetOperation(c93729065.rdop)
	c:RegisterEffect(e3)
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。直到结束阶段，这张卡当作和那只怪兽同名卡使用，得到相同效果。那之后，作为对象的怪兽的攻击力·守备力下降500，效果无效化，给与对方500伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(93729065,1))
	e4:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,93729065)
	e4:SetCost(c93729065.copycost)
	e4:SetTarget(c93729065.copytg)
	e4:SetOperation(c93729065.copyop)
	c:RegisterEffect(e4)
	-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(93729065,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(c93729065.pencon)
	e5:SetTarget(c93729065.pentg)
	e5:SetOperation(c93729065.penop)
	c:RegisterEffect(e5)
end
-- 过滤送去墓地前存在于场上的卡片
function c93729065.cfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 统计送去墓地的场上卡片数量，并给这张卡放置对应数量的蛊指示物
function c93729065.counter(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c93729065.cfilter,nil)
	if ct>0 then
		e:GetHandler():AddCounter(0x104f,ct)
	end
end
-- 过滤非龙族·暗属性的怪兽作为攻击力下降的对象
function c93729065.atktg(e,c)
	return not (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK))
end
-- 计算攻击力下降的数值，为场上蛊指示物数量×(-200)
function c93729065.atkval(e,c)
	-- 获取双方场上蛊指示物的总数并乘以-200作为攻击力改变量
	return Duel.GetCounter(0,1,1,0x104f)*-200
end
-- 判定即将产生对自己的战斗伤害，且本回合尚未发动过该效果
function c93729065.rdcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and e:GetHandler():GetFlagEffect(93729066)==0
end
-- 询问玩家是否将战斗伤害变成0，若是则将伤害变为0并注册单回合限制标记
function c93729065.rdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家是否选择发动效果将本次战斗伤害变成0
	if Duel.SelectYesNo(tp,aux.Stringid(93729065,3)) then  --"是否要把战斗伤害变成0？"
		-- 提示发动了“凶饿蛊龙”的效果（显示卡片发动动画）
		Duel.Hint(HINT_CARD,0,93729065)
		-- 将玩家在本次战斗中受到的战斗伤害变成0
		Duel.ChangeBattleDamage(tp,0)
		e:GetHandler():RegisterFlagEffect(93729066,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 检查并注册单回合内该效果只能使用1次的限制标记
function c93729065.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(93729065)==0 end
	e:GetHandler():RegisterFlagEffect(93729065,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤对方场上表侧表示且非衍生物的怪兽
function c93729065.copyfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
end
-- 选择对方场上1只表侧表示怪兽为对象，并设置无效化和伤害的操作信息
function c93729065.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c93729065.copyfilter(chkc) end
	-- 检查对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c93729065.copyfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c93729065.copyfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为无效化选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	-- 设置当前连锁的操作信息为给与对方500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 复制对象怪兽的名字和效果，之后使对象怪兽攻击力·守备力下降500、效果无效，并给与对方500伤害
function c93729065.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使与对象怪兽相关的连锁都无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local cid=0
		-- 直到结束阶段，这张卡当作和那只怪兽同名卡使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(tc:GetOriginalCodeRule())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		if not tc:IsType(TYPE_TRAPMONSTER) then
			cid=c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		end
		-- 得到相同效果。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(93729065,4))  --"结束复制效果"
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		e2:SetLabelObject(e1)
		e2:SetLabel(cid)
		e2:SetOperation(c93729065.rstop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
		-- 中断当前效果处理，使后续的下降攻防、无效化和伤害处理与前面的复制效果不视为同时处理
		Duel.BreakEffect()
		-- 那之后，作为对象的怪兽的攻击力·守备力下降500
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetValue(-500)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e4)
		-- 检查对象怪兽是否满足可以被无效化的条件（表侧表示、未被无效的效果怪兽）
		if aux.NegateMonsterFilter(tc) then
			-- 效果无效化
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetCode(EFFECT_DISABLE)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e5)
			-- 效果无效化
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_SINGLE)
			e6:SetCode(EFFECT_DISABLE_EFFECT)
			e6:SetValue(RESET_TURN_SET)
			e6:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e6)
		end
		-- 给与对方500点效果伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
-- 结束阶段重置复制的名字和效果的处理函数
function c93729065.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	if cid~=0 then
		c:ResetEffect(cid,RESET_COPY)
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 手动为自身卡片显示被选中的动画效果，提示玩家该卡的效果已被重置
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家提示“结束复制效果”
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 判定怪兽区域的这张卡被破坏且表侧表示
function c93729065.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 检查自己的灵摆区域是否有空位
function c93729065.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方左侧或右侧的灵摆区域是否可用
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 将这张卡在自己的灵摆区域放置
function c93729065.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示移动到己方的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
