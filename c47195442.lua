--四獣層ウォンキー
-- 效果：
-- 4星怪兽×2只以上
-- ①：场上的这张卡不受其他卡的效果影响。
-- ②：这张卡超量召唤的场合或者自己准备阶段发动。从自己卡组上面把3张卡作为这张卡的超量素材。那之后，这张卡作为超量素材中的怪兽数量的以下效果适用。
-- ●4只以下：这张卡的控制权移给对方。
-- ●5只以上：自己受到这张卡持有的超量素材数量×400伤害，自己场上的怪兽全部破坏。
local s,id,o=GetID()
-- 初始化效果，设置XYZ召唤条件、苏生限制和三个效果
function s.initial_effect(c)
	-- 添加XYZ召唤手续，要求满足等级为4且数量不少于2的怪兽作为素材
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：场上的这张卡不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- ②：这张卡超量召唤的场合或者自己准备阶段发动。从自己卡组上面把3张卡作为这张卡的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atcon1)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
	-- ②：这张卡超量召唤的场合或者自己准备阶段发动。从自己卡组上面把3张卡作为这张卡的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atcon2)
	e3:SetTarget(s.attg)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)
end
-- 效果过滤函数，使该卡不受到自身以外的效果影响
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 准备阶段触发条件，判断是否为当前回合玩家
function s.atcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 超量召唤成功时触发条件，判断是否为XYZ召唤
function s.atcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果处理目标函数，检查该卡是否为XYZ怪兽
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
end
-- 效果处理操作函数，从卡组顶部抽取最多3张卡作为超量素材，并根据超量怪兽数量执行不同效果
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家卡组中卡的数量
	local ld=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_DECK,0,nil)
	if ld<1 then return end
	-- 获取玩家卡组最上方的卡数（不超过3张）
	local g=Duel.GetDecktopGroup(tp,math.min(ld,3))
	if c:IsRelateToEffect(e) then
		-- 禁用后续操作的洗牌检测
		Duel.DisableShuffleCheck()
		-- 将指定卡组作为超量素材叠放至该卡上
		Duel.Overlay(c,g)
	end
	-- 中断当前效果处理，使后续效果视为错时点处理
	Duel.BreakEffect()
	if c:GetOverlayGroup():FilterCount(Card.IsType,nil,TYPE_MONSTER)<5 then
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		-- 将该卡的控制权移给对方玩家
		Duel.GetControl(c,1-tp)
	else
		-- 对自身造成相当于超量素材数量×400的伤害
		Duel.Damage(tp,c:GetOverlayCount()*400,REASON_EFFECT)
		-- 获取己方场上的所有怪兽
		local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
		-- 破坏己方场上所有怪兽
		Duel.Destroy(mg,REASON_EFFECT)
	end
end
