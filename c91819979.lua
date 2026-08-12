--マジックブラスト
-- 效果：
-- ①：给与对方为自己场上的魔法师族怪兽数量×200伤害。
-- ②：这张卡在墓地存在的场合，自己抽卡阶段的抽卡前才能发动。作为这个回合进行通常抽卡的代替，这张卡加入手卡。
function c91819979.initial_effect(c)
	-- ①：给与对方为自己场上的魔法师族怪兽数量×200伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c91819979.damtg)
	e1:SetOperation(c91819979.damop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，自己抽卡阶段的抽卡前才能发动。作为这个回合进行通常抽卡的代替，这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91819979,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c91819979.thcon)
	e2:SetTarget(c91819979.thtg)
	e2:SetOperation(c91819979.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的魔法师族怪兽
function c91819979.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 伤害效果的发动准备：检查场上是否存在魔法师族怪兽，并设置伤害相关的操作信息
function c91819979.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91819979.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上表侧表示的魔法师族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c91819979.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置效果处理的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的对象参数为（魔法师族怪兽数量×200）的数值
	Duel.SetTargetParam(ct*200)
	-- 设置连锁的操作信息为：给与对方（魔法师族怪兽数量×200）的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
end
-- 伤害效果的效果处理：计算场上魔法师族怪兽数量并给与对方相应数值的伤害
function c91819979.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家（对方）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算当前自己场上表侧表示的魔法师族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c91819979.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 依效果给与目标玩家（对方）相应的伤害
	Duel.Damage(p,ct*200,REASON_EFFECT)
end
-- 回收效果的发动条件：必须是自己的回合
function c91819979.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 回收效果的发动准备：检查是否能进行通常抽卡以及此卡是否能加入手卡，并设置回收操作信息
function c91819979.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己当前是否能进行通常抽卡，且墓地的这张卡是否能加入手卡
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and e:GetHandler():IsAbleToHand() end
	-- 设置连锁的操作信息为：将这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 回收效果的效果处理：放弃通常抽卡，并将这张卡加入手卡并给对方确认
function c91819979.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查自己是否能进行通常抽卡，若不能则不处理
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	-- 使自己放弃本回合抽卡阶段的通常抽卡
	aux.GiveUpNormalDraw(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 将加入手卡的这张卡给对方玩家确认
		Duel.ConfirmCards(1-tp,c)
	end
end
