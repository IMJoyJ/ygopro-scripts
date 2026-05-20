--レッド・ダストン
-- 效果：
-- 这张卡不能解放，也不能作为融合·同调·超量召唤的素材。场上的这张卡被破坏时，这张卡的控制者受到500分伤害。「红尘妖」在自己场上只能有1只表侧表示存在。
function c61019812.initial_effect(c)
	c:SetUniqueOnField(1,0,61019812)
	-- 这张卡不能解放
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	-- 也不能作为融合·同调·超量召唤的素材
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetValue(c61019812.fuslimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e5)
	-- 场上的这张卡被破坏时，这张卡的控制者受到500分伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(61019812,0))  --"伤害"
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(c61019812.dmcon)
	e6:SetTarget(c61019812.dmtg)
	e6:SetOperation(c61019812.dmop)
	c:RegisterEffect(e6)
end
-- 限制该卡不能作为融合召唤的素材
function c61019812.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 判断此卡是否在场上被破坏以满足效果触发条件
function c61019812.dmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 伤害效果的发动准备，设置目标玩家为该卡被破坏前的控制者，伤害数值为500，并注册操作信息
function c61019812.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 将效果的目标玩家设置为这张卡被破坏前的控制者
	Duel.SetTargetPlayer(c:GetPreviousControler())
	-- 将效果的目标参数（伤害数值）设置为500
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息，表明该效果会给与该卡被破坏前的控制者500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,c:GetPreviousControler(),500)
end
-- 伤害效果的执行，获取目标玩家和伤害数值，并给与该玩家伤害
function c61019812.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和目标参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
