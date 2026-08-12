--破滅へのクイック・ドロー
-- 效果：
-- 双方玩家在抽卡阶段开始时手卡是0张的场合，通常抽卡外可以再抽1张。这张卡的控制者在每次自己回合的结束阶段支付700基本分。这个时候基本分700未满的场合，基本分变成0。自己场上表侧表示存在的这张卡从场上离开时，自己受到3000分伤害。
function c77859858.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的这张卡从场上离开时，自己受到3000分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c77859858.checkop)
	c:RegisterEffect(e2)
	-- 自己场上表侧表示存在的这张卡从场上离开时，自己受到3000分伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c77859858.leave)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 双方玩家在抽卡阶段开始时手卡是0张的场合，通常抽卡外可以再抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PREDRAW)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(c77859858.pdraw)
	c:RegisterEffect(e4)
	-- 双方玩家在抽卡阶段开始时手卡是0张的场合，通常抽卡外可以再抽1张。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(77859858,0))  --"抽卡"
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetRange(LOCATION_SZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_DRAW)
	e5:SetCondition(c77859858.drcon)
	e5:SetTarget(c77859858.drtg)
	e5:SetOperation(c77859858.drop)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	-- 这张卡的控制者在每次自己回合的结束阶段支付700基本分。这个时候基本分700未满的场合，基本分变成0。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCountLimit(1)
	e6:SetCondition(c77859858.costcon)
	e6:SetOperation(c77859858.costop)
	c:RegisterEffect(e6)
end
-- 在卡片即将离场时，检测其是否处于未被无效且已启用的状态，并记录在Label中
function c77859858.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsDisabled() or not c:IsStatus(STATUS_EFFECT_ENABLED) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 处理卡片离场效果，若离场前未被无效且由原本控制者控制，则给予其3000点伤害
function c77859858.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==0 and c:IsPreviousControler(tp) then
		-- 给予玩家3000点效果伤害
		Duel.Damage(tp,3000,REASON_EFFECT)
	end
end
-- 在抽卡阶段开始前，检测当前回合玩家的手卡数量是否为0并记录
function c77859858.pdraw(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前回合玩家的手卡数量为0，则将Label设为1
	if Duel.GetFieldGroupCount(ep,LOCATION_HAND,0)==0 then e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 检测是否为规则抽卡，且抽卡前手卡数量是否为0
function c77859858.drcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RULE and e:GetLabelObject():GetLabel()==1
end
-- 设置抽卡效果的对象玩家为当前回合玩家，抽卡数量为1张
function c77859858.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前回合玩家设为效果处理的对象玩家
	Duel.SetTargetPlayer(ep)
	-- 设置效果处理的参数（抽卡数量）为1
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为：让当前回合玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,ep,1)
end
-- 执行抽卡效果，让目标玩家抽指定数量的卡
function c77859858.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 检测当前是否为自己回合的结束阶段
function c77859858.costcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 执行结束阶段的维持基本分支付，若基本分不足700则直接归0
function c77859858.costop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断控制者的基本分是否在700以上
	if Duel.GetLP(tp)>=700 then
		-- 让控制者支付700基本分
		Duel.PayLPCost(tp,700)
	else
		-- 将控制者的基本分变成0
		Duel.SetLP(tp,0)
	end
end
