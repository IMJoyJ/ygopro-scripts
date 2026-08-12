--アシンメタファイズ
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从手卡把1张「玄化」卡除外，自己从卡组抽1张。
-- ②：1回合1次，自己的「玄化」卡被除外的场合发动。那个回合的以下效果适用。
-- ●自己回合：「玄化」怪兽以外的场上的全部怪兽的攻击力·守备力下降500。
-- ●对方回合：「玄化」怪兽以外的场上的全部怪兽的表示形式变更。
function c66719533.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。从手卡把1张「玄化」卡除外，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66719533,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c66719533.drtg)
	e2:SetOperation(c66719533.drop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己的「玄化」卡被除外的场合发动。那个回合的以下效果适用。 ●自己回合：「玄化」怪兽以外的场上的全部怪兽的攻击力·守备力下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(66719533,1))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c66719533.atkcon)
	e3:SetOperation(c66719533.atkop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(66719533,2))
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetCondition(c66719533.poscon)
	e4:SetTarget(c66719533.postg)
	e4:SetOperation(c66719533.posop)
	c:RegisterEffect(e4)
end
-- 过滤手卡中可除外的「玄化」卡片
function c66719533.drfilter(c)
	return c:IsSetCard(0x105) and c:IsAbleToRemove()
end
-- 效果①的发动准备（检查是否能抽卡以及手卡是否有可除外的「玄化」卡）
function c66719533.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以效果抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 并且检查自己手卡中是否存在至少1张可以除外的「玄化」卡
		and Duel.IsExistingMatchingCard(c66719533.drfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为：从自己手卡除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	-- 设置连锁的操作信息为：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的效果处理（除外手卡「玄化」卡并抽卡）
function c66719533.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和参数（即自己和抽卡数量1）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给玩家发送“选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己手卡中1张满足过滤条件的「玄化」卡
	local g=Duel.SelectMatchingCard(tp,c66719533.drfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 如果成功选择并表侧表示除外了该卡
	if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		-- 执行效果抽卡
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
-- 过滤被除外的卡中属于自己且表侧表示的「玄化」卡
function c66719533.effilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x105) and c:IsControler(tp) and c:IsPreviousControler(tp)
end
-- 检查被除外的卡中是否存在自己的「玄化」卡
function c66719533.effcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c66719533.effilter,1,nil,tp)
end
-- 效果②在自己回合发动时的条件判断（自己的「玄化」卡被除外且当前是自己回合）
function c66719533.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否满足“自己的「玄化」卡被除外”且“当前是自己回合”的条件
	return c66719533.effcon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetTurnPlayer()==tp
end
-- 过滤场上表侧表示的「玄化」怪兽以外的怪兽
function c66719533.filter(c)
	return c:IsFaceup() and not c:IsSetCard(0x105)
end
-- 效果②在自己回合适用时的效果处理（场上「玄化」以外的怪兽攻防下降500）
function c66719533.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方场上所有表侧表示的「玄化」怪兽以外的怪兽
	local g=Duel.GetMatchingGroup(c66719533.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历这些怪兽
	for tc in aux.Next(g) do
		-- 「玄化」怪兽以外的场上的全部怪兽的攻击力·守备力下降500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 效果②在对方回合发动时的条件判断（自己的「玄化」卡被除外且当前是对方回合）
function c66719533.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否满足“自己的「玄化」卡被除外”且“当前是对方回合”的条件
	return c66719533.effcon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetTurnPlayer()~=tp
end
-- 过滤场上里侧表示的怪兽或「玄化」怪兽以外的怪兽
function c66719533.posfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x105)
end
-- 效果②在对方回合发动时的效果准备（收集需要改变表示形式的怪兽并设置操作信息）
function c66719533.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有里侧表示或「玄化」怪兽以外的怪兽
	local g=Duel.GetMatchingGroup(c66719533.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁的操作信息为：改变这些怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果②在对方回合适用时的效果处理（场上「玄化」以外的怪兽表示形式变更）
function c66719533.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取当前场上所有里侧表示或「玄化」怪兽以外的怪兽
	local sg=Duel.GetMatchingGroup(c66719533.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		-- 改变这些怪兽的表示形式
		Duel.ChangePosition(sg,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
