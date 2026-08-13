--TG パワー・グラディエイター
-- 效果：
-- 调整＋调整以外的名字带有「科技属」的怪兽1只以上
-- 这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。场上存在的这张卡被破坏时，从自己卡组抽1张卡。
function c24943456.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的名字带有「科技属」的怪兽1只以上。
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
-- 抽卡效果的发动条件：该卡此前位于场上，且因被破坏而离场。
function c24943456.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 抽卡效果的目标设定：必发效果；将抽卡玩家（tp）设为对象玩家，抽卡数量设为1。
function c24943456.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本连锁的对象玩家设为tp，即由这张卡的持有者/控制者抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将本连锁的对象参数设为1，表示抽1张卡。
	Duel.SetTargetParam(1)
	-- 设置操作信息：效果类别为抽卡，对象玩家为tp，抽卡数量参数为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的处理：从连锁信息中取出对象玩家和数量，实际执行抽卡。
function c24943456.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设置的对象玩家p和对象参数d（即抽卡者与抽卡数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，完成从卡组抽1张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
