--トリックスター・ブルム
-- 效果：
-- 2星以下的「淘气仙星」怪兽1只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。对方抽1张。
-- ②：这张卡所连接区的表侧表示的「淘气仙星」怪兽被战斗·效果破坏的场合才能发动。给与对方为对方手卡数量×200伤害。
function c77307161.initial_effect(c)
	c:EnableReviveLimit()
	-- 为自身添加连接召唤手续，素材为1只满足过滤条件的怪兽
	aux.AddLinkProcedure(c,c77307161.matfilter,1,1)
	-- ①：这张卡连接召唤的场合才能发动。对方抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77307161,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c77307161.drcon)
	e1:SetTarget(c77307161.drtg)
	e1:SetOperation(c77307161.drop)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的表侧表示的「淘气仙星」怪兽被战斗·效果破坏的场合才能发动。给与对方为对方手卡数量×200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77307161,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,77307161)
	e2:SetCondition(c77307161.damcon)
	e2:SetTarget(c77307161.damtg)
	e2:SetOperation(c77307161.damop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤条件：2星以下的「淘气仙星」怪兽
function c77307161.matfilter(c,lc,sumtype,tp)
	return c:IsLevelBelow(2) and c:IsLinkSetCard(0xfb)
end
-- 效果①的发动条件：此卡是连接召唤成功的场合
function c77307161.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的发动准备与合法性检测（对方是否能抽卡，并设置抽卡参数与操作信息）
function c77307161.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) end
	-- 将效果处理的对象玩家设为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将效果处理的对象参数（抽卡数量）设为1
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息：对方玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 效果①的处理：让目标玩家抽对应数量的卡
function c77307161.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤条件：被战斗或效果破坏、原本是「淘气仙星」怪兽、原本在场上且原本位置处于此卡的连接区内
function c77307161.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if c:IsPreviousControler(1-tp) then seq=seq+16 end
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsSetCard(0xfb)
		and c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
-- 效果②的发动条件：被破坏的卡片中存在满足过滤条件的怪兽
function c77307161.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c77307161.cfilter,1,nil,tp,e:GetHandler():GetLinkedZone())
end
-- 效果②的发动准备与合法性检测（对方手卡是否大于0，并设置伤害参数与操作信息）
function c77307161.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 end
	-- 将效果处理的对象玩家设为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息：给与对方伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果②的处理：给与对方其手卡数量×200的伤害
function c77307161.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 给与目标玩家其手卡数量×200的伤害
	Duel.Damage(p,Duel.GetFieldGroupCount(p,LOCATION_HAND,0)*200,REASON_EFFECT)
end
