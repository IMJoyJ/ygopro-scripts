--充電機塊セルトパス
-- 效果：
-- 「机块」怪兽2只
-- ①：连接状态的这张卡不会成为攻击对象，也不会成为对方的效果的对象。
-- ②：这张卡所互相连接区的自己的「机块」连接怪兽在和对方怪兽进行战斗的伤害计算时发动。那只自己怪兽的攻击力只在那次伤害计算时上升这张卡所互相连接区的怪兽数量×1000。
-- ③：1回合1次，和这张卡没有互相连接的自己场上的「机块」连接怪兽被战斗·效果破坏的场合才能发动。自己从卡组抽1张。
function c78225596.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：需要「机块」怪兽2只作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x14b),2,2)
	-- ①：连接状态的这张卡不会成为攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c78225596.imcon)
	-- 设置不会成为攻击对象的效果过滤函数（不受自身免疫效果影响的怪兽不能选择其为攻击对象）
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置不会成为对方效果对象的效果过滤函数（不能成为对方玩家卡片效果的对象）
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：这张卡所互相连接区的自己的「机块」连接怪兽在和对方怪兽进行战斗的伤害计算时发动。那只自己怪兽的攻击力只在那次伤害计算时上升这张卡所互相连接区的怪兽数量×1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(78225596,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c78225596.atkcon)
	e3:SetOperation(c78225596.atkop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，和这张卡没有互相连接的自己场上的「机块」连接怪兽被战斗·效果破坏的场合才能发动。自己从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(78225596,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c78225596.drcon)
	e4:SetTarget(c78225596.drtg)
	e4:SetOperation(c78225596.drop)
	c:RegisterEffect(e4)
	-- 和这张卡没有互相连接的自己场上的「机块」连接怪兽被战斗·效果破坏的场合
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_LEAVE_FIELD_P)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetLabelObject(e4)
	e5:SetOperation(c78225596.chk)
	c:RegisterEffect(e5)
end
-- 过滤满足“自己场上、被战斗或效果破坏、且不与这张卡互相连接的「机块」连接怪兽”的卡片
function c78225596.chkfilter(c,tp,g)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsSetCard(0x14b) and c:IsType(TYPE_LINK)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not g:IsContains(c)
end
-- 在卡片离场前，检查是否有符合条件的怪兽被破坏，并为效果③设置对应的Label标记
function c78225596.chk(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetHandler()) then
		e:GetLabelObject():SetLabel(0)
	else
		local g=e:GetHandler():GetMutualLinkedGroup()
		if eg:IsExists(c78225596.chkfilter,1,nil,tp,g) then
			e:GetLabelObject():SetLabel(1)
		else
			e:GetLabelObject():SetLabel(0)
		end
	end
end
-- 判断自身是否处于连接状态（有连接端指向其他怪兽，或有其他怪兽的连接端指向自身）
function c78225596.imcon(e)
	return e:GetHandler():IsLinkState()
end
-- 判断是否满足攻击力上升效果的发动条件：伤害计算时，进行战斗的自己怪兽是与这张卡互相连接的「机块」连接怪兽，且对方怪兽参与战斗
function c78225596.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetMutualLinkedGroup()
	-- 获取当前进行攻击的怪兽
	local ac=Duel.GetAttacker()
	local bc=ac:GetBattleTarget()
	if not bc then return false end
	if not ac:IsControler(tp) then ac,bc=bc,ac end
	e:SetLabelObject(ac)
	return ac:IsControler(tp) and ac:IsFaceup() and ac:IsType(TYPE_LINK) and ac:IsSetCard(0x14b) and g:IsContains(ac)
		and ac:IsRelateToBattle() and bc:IsControler(1-tp)
end
-- 执行攻击力上升的效果处理：使该进行战斗的自己怪兽的攻击力，只在伤害计算时上升与这张卡互相连接的怪兽数量×1000
function c78225596.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabelObject()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=e:GetHandler():GetMutualLinkedGroup()
	if ac:IsRelateToBattle() and ac:IsFaceup() and ac:IsControler(tp) then
		-- 那只自己怪兽的攻击力只在那次伤害计算时上升这张卡所互相连接区的怪兽数量×1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(g:GetCount()*1000)
		ac:RegisterEffect(e1)
	end
end
-- 检查Label标记是否不为0，以判断是否有符合条件的怪兽被破坏
function c78225596.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()~=0
end
-- 检查玩家是否能抽卡，并设置抽1张卡的操作信息
function c78225596.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息：包含抽卡分类，数量为1张，目标玩家为自己
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡的效果处理：让目标玩家从卡组抽指定张数的卡
function c78225596.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在Target阶段设置的目标玩家和抽卡张数参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行因卡片效果让玩家抽卡的操作
	Duel.Draw(p,d,REASON_EFFECT)
end
