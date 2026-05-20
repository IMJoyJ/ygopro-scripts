--モコモッコ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示。
-- ③：这张卡反转的场合发动。自己抽1张。
function c85401123.initial_effect(c)
	-- ①：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c85401123.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这个卡名的②③的效果1回合各能使用1次。②：自己主要阶段才能发动。这张卡变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85401123,0))  --"变为里侧守备表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,85401123)
	e2:SetTarget(c85401123.sttg)
	e2:SetOperation(c85401123.stop)
	c:RegisterEffect(e2)
	-- 这个卡名的②③的效果1回合各能使用1次。③：这张卡反转的场合发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85401123,1))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1,85401123+1)
	e3:SetTarget(c85401123.drtg)
	e3:SetOperation(c85401123.drop)
	c:RegisterEffect(e3)
end
-- 过滤受到战斗无敌效果影响的怪兽，判断其是否为自身或自身的战斗对象
function c85401123.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 改变表示形式效果的发动准备，确认自身是否可以转为里侧表示，并设置改变表示形式的操作信息
function c85401123.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() end
	-- 设置当前连锁的操作信息为：将1张卡（自身）改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 改变表示形式效果的处理，若自身仍在场且呈表侧表示，则将其变为里侧守备表示
function c85401123.stop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 反转抽卡效果的发动准备，设置抽卡玩家、抽卡数量为1，并设置抽卡的操作信息
function c85401123.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：由发动效果的玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 反转抽卡效果的处理，获取连锁设定的对象玩家和参数，执行抽卡
function c85401123.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和对象参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
