--TG パワー・グラディエイター
-- 效果：
-- 调整＋调整以外的名字带有「科技属」的怪兽1只以上
-- 这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。场上存在的这张卡被破坏时，从自己卡组抽1张卡。
function c24943456.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的名字带有「科技属」的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x27),1)
	c:EnableReviveLimit()
	-- 这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	-- 场上存在的这张卡被破坏时，从自己卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24943456,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c24943456.drcon)
	e2:SetTarget(c24943456.drtg)
	e2:SetOperation(c24943456.drop)
	c:RegisterEffect(e2)
end
-- 效果发动时判断该卡是否因破坏而离场
function c24943456.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 设置抽卡效果的目标玩家和抽卡数量
function c24943456.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果，从卡组抽取1张卡
function c24943456.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽取指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
