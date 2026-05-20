--ホーリー・ジェラル
-- 效果：
-- 场上有「天空的圣域」存在的场合，这张卡被战斗破坏以外的方法送去墓地时，自己回复1000基本分。
function c84177693.initial_effect(c)
	-- 在卡片中注册记载了「天空的圣域」的卡片密码
	aux.AddCodeList(c,56433456)
	-- 场上有「天空的圣域」存在的场合，这张卡被战斗破坏以外的方法送去墓地时，自己回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84177693,0))  --"LP回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c84177693.reccon)
	e1:SetTarget(c84177693.rectg)
	e1:SetOperation(c84177693.recop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：检查是否非战斗破坏送去墓地，且场上是否存在「天空的圣域」
function c84177693.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡送去墓地的原因不是战斗破坏，并且当前场上存在「天空的圣域」
	return not e:GetHandler():IsReason(REASON_BATTLE) and Duel.IsEnvironment(56433456)
end
-- 效果发动目标：设置回复基本分的对象玩家和回复数值，并注册操作信息
function c84177693.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1000
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为：自己回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 效果执行：获取目标玩家和回复数值，执行回复基本分的操作
function c84177693.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复对应的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
