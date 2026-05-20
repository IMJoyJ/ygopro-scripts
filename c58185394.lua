--G・コザッキー
-- 效果：
-- 场上没有「平庸鬼」表侧表示存在的场合，这张卡破坏。场上表侧表示存在的这张卡被破坏的场合，给与那个时候的控制者基本分为这张卡的原本攻击力数值的伤害。
function c58185394.initial_effect(c)
	-- 场上没有「平庸鬼」表侧表示存在的场合，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c58185394.sdcon)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的这张卡被破坏的场合，给与那个时候的控制者基本分为这张卡的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58185394,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c58185394.dmcon)
	e2:SetTarget(c58185394.dmtg)
	e2:SetOperation(c58185394.dmop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示的「平庸鬼」
function c58185394.sdfilter(c)
	return c:IsFaceup() and c:IsCode(99171160)
end
-- 自身破坏效果的判定条件：这张卡未处于战斗破坏确定状态，且场上没有表侧表示的「平庸鬼」
function c58185394.sdcon(e)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查场上是否存在表侧表示的「平庸鬼」，若不存在则满足条件
		and not Duel.IsExistingMatchingCard(c58185394.sdfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 伤害效果的发动条件：这张卡在场上表侧表示存在并被破坏
function c58185394.dmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP)
end
-- 伤害效果的靶向与操作信息注册：设定目标玩家为前控制者，伤害数值为2500
function c58185394.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 将效果的目标玩家设定为这张卡被破坏前的控制者
	Duel.SetTargetPlayer(c:GetPreviousControler())
	-- 将效果的目标参数设定为2500（这张卡的原本攻击力）
	Duel.SetTargetParam(2500)
	-- 注册操作信息：给与目标玩家2500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,c:GetPreviousControler(),2500)
end
-- 伤害效果的执行：获取目标玩家和伤害数值，并对其造成效果伤害
function c58185394.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
