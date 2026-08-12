--ロイヤルナイツ
-- 效果：
-- 这张卡战斗破坏怪兽送去墓地时，自己基本分回复破坏怪兽的守备力的数值。
function c68280530.initial_effect(c)
	-- 这张卡战斗破坏怪兽送去墓地时，自己基本分回复破坏怪兽的守备力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68280530,0))  --"LP回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c68280530.reccon)
	e1:SetTarget(c68280530.rectg)
	e1:SetOperation(c68280530.recop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自身仍与战斗相关，且被破坏的怪兽是送去墓地的怪兽卡
function c68280530.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 设置效果发动的目标：确定回复的玩家为自己，回复的数值为被破坏怪兽的守备力
function c68280530.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local rec=bc:GetDefense()
	if rec<0 then rec=0 end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为回复的数值（被破坏怪兽的守备力）
	Duel.SetTargetParam(rec)
	-- 设置当前连锁的操作信息为：玩家tp回复rec数值的生命值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 执行效果处理：获取设定的对象玩家和回复数值，并执行回复生命值的操作
function c68280530.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和对象参数（回复数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复对应的生命值
	Duel.Recover(p,d,REASON_EFFECT)
end
