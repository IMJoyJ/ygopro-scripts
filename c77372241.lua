--フレムベル・グルニカ
-- 效果：
-- 这张卡战斗破坏怪兽送去墓地时，给与对方基本分破坏怪兽的等级×200的数值的伤害。
function c77372241.initial_effect(c)
	-- 这张卡战斗破坏怪兽送去墓地时，给与对方基本分破坏怪兽的等级×200的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77372241,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c77372241.damcon)
	e1:SetTarget(c77372241.damtg)
	e1:SetOperation(c77372241.damop)
	c:RegisterEffect(e1)
end
-- 判断是否仅有1张怪兽被本卡战斗破坏并送去墓地，并用Label记录该怪兽的等级
function c77372241.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	e:SetLabel(tc:GetLevel())
	return eg:GetCount()==1 and tc:GetReasonCard()==e:GetHandler()
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
end
-- 设置效果发动的目标玩家与伤害数值，并注册伤害操作信息
function c77372241.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设为效果处理的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将伤害数值（被破坏怪兽的等级×200）设为效果处理的对象参数
	Duel.SetTargetParam(e:GetLabel()*200)
	-- 设置当前连锁的操作信息，分类为伤害，对象为对方玩家，参数为计算出的伤害数值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel()*200)
end
-- 效果处理，获取设定的对象玩家与伤害数值，并给与对方玩家效果伤害
function c77372241.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
