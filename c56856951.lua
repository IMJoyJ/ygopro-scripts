--メテオ・プロミネンス
-- 效果：
-- 对方基本分比3000高的场合，把2张手卡送去墓地才能发动。给与对方基本分2000分伤害。这张卡在墓地存在的场合，可以作为自己的抽卡阶段时进行通常抽卡的代替，把这张卡加入手卡。
function c56856951.initial_effect(c)
	-- 对方基本分比3000高的场合，把2张手卡送去墓地才能发动。给与对方基本分2000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c56856951.damcon)
	e1:SetCost(c56856951.damcost)
	e1:SetTarget(c56856951.damtg)
	e1:SetOperation(c56856951.damop)
	c:RegisterEffect(e1)
	-- 这张卡在墓地存在的场合，可以作为自己的抽卡阶段时进行通常抽卡的代替，把这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56856951,0))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c56856951.thcon)
	e2:SetTarget(c56856951.thtg)
	e2:SetOperation(c56856951.thop)
	c:RegisterEffect(e2)
end
-- 伤害效果的发动条件判定函数
function c56856951.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方玩家的当前生命值是否大于3000
	return Duel.GetLP(1-tp)>3000
end
-- 伤害效果的发动代价（Cost）处理函数
function c56856951.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少2张可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 玩家选择并以发动代价将2张手牌送去墓地
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,2,2,REASON_COST)
end
-- 伤害效果的发动目标（Target）处理函数
function c56856951.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设定为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数设定为2000（伤害数值）
	Duel.SetTargetParam(2000)
	-- 设置效果处理的操作信息为“给与对方玩家2000点伤害”
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
-- 伤害效果的实际效果处理（Operation）函数
function c56856951.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和对象参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 依效果对目标玩家造成相应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 墓地回收效果的发动条件判定函数
function c56856951.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合是否为自己的回合
	return tp==Duel.GetTurnPlayer()
end
-- 墓地回收效果的发动目标（Target）处理函数
function c56856951.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否能进行通常抽卡，且墓地的这张卡是否能加入手牌
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and e:GetHandler():IsAbleToHand() end
	-- 设置效果处理的操作信息为“将墓地的这张卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 墓地回收效果的实际效果处理（Operation）函数
function c56856951.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查玩家是否能进行通常抽卡，若不能则不处理
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	-- 使玩家放弃本回合抽卡阶段的通常抽卡
	aux.GiveUpNormalDraw(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的这张卡
		Duel.ConfirmCards(1-tp,c)
	end
end
