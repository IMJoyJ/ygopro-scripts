--グラナドラ
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，自己回复1000基本分。这张卡被破坏送去墓地时，自己受到2000点伤害。
function c13944422.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，自己回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13944422,0))  --"回复1000"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c13944422.rectg)
	e1:SetOperation(c13944422.recop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 这张卡被破坏送去墓地时，自己受到2000点伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(13944422,1))  --"伤害2000"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c13944422.damcon)
	e4:SetTarget(c13944422.damtg)
	e4:SetOperation(c13944422.damop)
	c:RegisterEffect(e4)
end
-- 回复效果的目标设定函数：效果发动时无条件允许，将回复玩家设为自己（tp），回复数值设为1000，并登记回复1000LP的操作信息。
function c13944422.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次回复效果的受益玩家（对象玩家）设定为效果发动者（tp），即自己。
	Duel.SetTargetPlayer(tp)
	-- 将回复数值参数设定为1000。
	Duel.SetTargetParam(1000)
	-- 设置操作信息：效果分类为回复，对象玩家为tp，回复数值为1000，不指定卡片目标。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 回复效果的处理函数：从连锁信息中取出对象玩家和回复数值，执行回复LP。
function c13944422.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和参数（回复对象及回复数值），分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p回复d点LP（此处为1000）。
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 伤害效果的发动条件：这张卡被送去墓地时必须是因为被破坏，才触发此效果。
function c13944422.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 伤害效果的目标设定函数：发动时无条件允许，将受到伤害的玩家设为自己（tp），伤害数值设为2000，并登记伤害效果的操作信息。
function c13944422.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次伤害效果的受伤玩家（对象玩家）设定为效果发动者（tp），即自己。
	Duel.SetTargetPlayer(tp)
	-- 将伤害数值参数设定为2000。
	Duel.SetTargetParam(2000)
	-- 设置操作信息：效果分类为伤害，对象玩家为tp，伤害数值为2000，不指定卡片目标。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,2000)
end
-- 伤害效果的处理函数：从连锁信息中取出对象玩家和伤害数值，执行造成伤害。
function c13944422.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和参数（受伤玩家及伤害数值），分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对玩家p造成d点伤害（此处为2000）。
	Duel.Damage(p,d,REASON_EFFECT)
end
