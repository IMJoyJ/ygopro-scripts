--共命の翼ガルーラ
-- 效果：
-- 相同种族·属性而卡名不同的怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的战斗发生的对对方的战斗伤害变成2倍。
-- ②：这张卡被送去墓地的场合才能发动。自己抽1张。
function c11765832.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个满足条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c11765832.ffilter,2,true)
	-- ①：这张卡的战斗发生的对对方的战斗伤害变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	-- 设置战斗伤害变为2倍
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11765832,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,11765832)
	e2:SetTarget(c11765832.target)
	e2:SetOperation(c11765832.operation)
	c:RegisterEffect(e2)
end
-- 匹配属性和种族的过滤函数
function c11765832.matchfilter(c,attr,race)
	return c:IsFusionAttribute(attr) and c:IsRace(race)
end
-- 融合素材过滤函数
function c11765832.ffilter(c,fc,sub,mg,sg)
	-- 如果未设置融合素材组或素材组中没有满足条件的卡，则返回true
	return not sg or sg:FilterCount(aux.TRUE,c)==0
		or (sg:IsExists(c11765832.matchfilter,#sg-1,c,c:GetFusionAttribute(),c:GetRace())
			and not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
-- 效果目标设置函数
function c11765832.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为1
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果发动时的处理函数
function c11765832.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
