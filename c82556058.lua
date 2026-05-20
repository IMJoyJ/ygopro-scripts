--デモニック・モーター・Ω
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。这张卡的攻击力直到回合结束时上升1000。
-- ②：这张卡的①的效果发动的场合，结束阶段发动。这张卡破坏。
-- ③：自己结束阶段发动。在自己场上把1只「马达衍生物」（机械族·地·1星·攻/守200）攻击表示特殊召唤。
function c82556058.initial_effect(c)
	-- 注册卡片记有「马达衍生物」（卡号82556059）的信息
	aux.AddCodeList(c,82556059)
	-- ③：自己结束阶段发动。在自己场上把1只「马达衍生物」（机械族·地·1星·攻/守200）攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82556058,0))  --"特殊召唤1只「马达衍生物」"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c82556058.spcon)
	e1:SetTarget(c82556058.sptg)
	e1:SetOperation(c82556058.spop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。这张卡的攻击力直到回合结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82556058,1))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(c82556058.atkop)
	c:RegisterEffect(e2)
end
-- 衍生物特殊召唤效果的条件函数：必须是自己的结束阶段
function c82556058.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 衍生物特殊召唤效果的目标函数：设置操作信息
function c82556058.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：包含产生衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：包含特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 衍生物特殊召唤效果的运行函数：在场上特殊召唤1只「马达衍生物」
function c82556058.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否能特殊召唤指定的衍生物怪兽，若不能则返回
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,82556059,0,TYPES_TOKEN_MONSTER,200,200,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) then return end
	-- 创建「马达衍生物」卡片对象
	local token=Duel.CreateToken(tp,82556059)
	-- 将衍生物以表侧攻击表示特殊召唤到自己场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end
-- 攻击力上升效果的运行函数：使自身攻击力上升，并注册结束阶段破坏自身的效果
function c82556058.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这张卡的攻击力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果发动的场合，结束阶段发动。这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82556058,2))  --"「魔机马达·Ω」破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c82556058.destg)
	e2:SetOperation(c82556058.desop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end
-- 破坏效果的目标函数：设置破坏自身的操作信息
function c82556058.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 破坏效果的运行函数：将自身破坏
function c82556058.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果破坏这张卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
