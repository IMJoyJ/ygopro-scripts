--異形神の契約書
-- 效果：
-- ①：自己场上有以下种类的「DDD」怪兽从额外卡组特殊召唤时，各自效果1回合各能发动1次。
-- ●融合：自己回复1000基本分。
-- ●同调：特殊召唤的那些怪兽不会成为对方的效果的对象。
-- ●超量：选自己或者对方的场上·墓地1张卡除外。
-- ●灵摆：自己从卡组抽1张，那之后选1张手卡丢弃。
-- ②：自己准备阶段发动。自己受到2000伤害。
function c60168186.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有以下种类的「DDD」怪兽从额外卡组特殊召唤时，各自效果1回合各能发动1次。●融合：自己回复1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60168186,0))  --"融合：自己回复1000基本分。"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c60168186.effcon)
	e2:SetTarget(c60168186.rectg)
	e2:SetOperation(c60168186.recop)
	e2:SetLabel(TYPE_FUSION)
	c:RegisterEffect(e2)
	-- ①：自己场上有以下种类的「DDD」怪兽从额外卡组特殊召唤时，各自效果1回合各能发动1次。●同调：特殊召唤的那些怪兽不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(60168186,1))  --"同调：特殊召唤的那些怪兽不会成为对方的效果的对象。"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c60168186.effcon)
	e3:SetOperation(c60168186.tgop)
	e3:SetLabel(TYPE_SYNCHRO)
	c:RegisterEffect(e3)
	-- ①：自己场上有以下种类的「DDD」怪兽从额外卡组特殊召唤时，各自效果1回合各能发动1次。●超量：选自己或者对方的场上·墓地1张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(60168186,2))  --"超量：选自己或者对方的场上·墓地1张卡除外。"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c60168186.effcon)
	e4:SetTarget(c60168186.rmtg)
	e4:SetOperation(c60168186.rmop)
	e4:SetLabel(TYPE_XYZ)
	c:RegisterEffect(e4)
	-- ①：自己场上有以下种类的「DDD」怪兽从额外卡组特殊召唤时，各自效果1回合各能发动1次。●灵摆：自己从卡组抽1张，那之后选1张手卡丢弃。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(60168186,3))  --"灵摆：自己从卡组抽1张，那之后选1张手卡丢弃。"
	e5:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c60168186.effcon)
	e5:SetTarget(c60168186.drtg)
	e5:SetOperation(c60168186.drop)
	e5:SetLabel(TYPE_PENDULUM)
	c:RegisterEffect(e5)
	-- ②：自己准备阶段发动。自己受到2000伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(60168186,4))  --"受到2000伤害"
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c60168186.damcon)
	e6:SetTarget(c60168186.damtg)
	e6:SetOperation(c60168186.damop)
	c:RegisterEffect(e6)
end
-- 过滤函数：检查是否为自己场上从额外卡组特殊召唤的表侧表示的指定类型的「DDD」怪兽
function c60168186.cfilter(c,tp,typ)
	return c:IsFaceup() and c:IsType(typ) and c:IsSetCard(0x10af) and c:IsControler(tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果发动条件：特殊召唤的怪兽中存在满足过滤条件的怪兽
function c60168186.effcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c60168186.cfilter,1,nil,tp,e:GetLabel())
end
-- 回复效果的靶向与操作信息设置
function c60168186.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1000
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为：玩家回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 回复效果的处理函数
function c60168186.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和对象参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复对应数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 过滤函数：筛选出从额外卡组特殊召唤的指定类型的「DDD」怪兽
function c60168186.filter(c,tp,typ)
	return c:IsType(typ) and c:IsSetCard(0x10af) and c:IsControler(tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 同调效果的处理函数：赋予特殊召唤的那些怪兽抗性
function c60168186.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(c60168186.filter,nil,tp,e:GetLabel())
	local tc=g:GetFirst()
	while tc do
		-- 不会成为对方的效果的对象。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		-- 设置抗性效果的生效范围为对方卡片的效果
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 除外效果的靶向与操作信息设置
function c60168186.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检查阶段，则判断双方场上或墓地是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 获取双方场上及墓地所有可以除外的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 设置当前连锁的操作信息为：除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 除外效果的处理函数
function c60168186.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送选择除外卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从场上选择，若取消则从场上或墓地选择1张可以除外的卡
	local g=aux.SelectCardFromFieldFirst(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果原因将选中的卡表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 抽卡并丢弃效果的靶向与操作信息设置
function c60168186.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检查阶段，则判断自己是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的操作信息为：自己丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置当前连锁的操作信息为：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡并丢弃效果的处理函数
function c60168186.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因让自己抽1张卡，若成功抽卡则执行后续处理
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		-- 中断当前效果，使后续的丢弃手卡处理与抽卡不视为同时处理
		Duel.BreakEffect()
		-- 以效果原因让玩家选择并丢弃1张手卡
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 伤害效果的发动条件：当前回合玩家为自己
function c60168186.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 伤害效果的靶向与操作信息设置
function c60168186.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为2000
	Duel.SetTargetParam(2000)
	-- 设置当前连锁的操作信息为：对玩家造成2000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,2000)
end
-- 伤害效果的处理函数
function c60168186.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和对象参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对目标玩家造成对应数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
