--フェスティバルーン
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ②：只要这张卡在怪兽区域存在，每次自己或对方的怪兽攻击宣言，这张卡的攻击力上升1000。
-- ③：自己主要阶段才能发动。这张卡的攻击力下降5000，场上的其他卡全部破坏。
local s,id,o=GetID()
-- 注册卡片效果：①战斗不破，②攻击宣言加攻，③降攻并破坏场上其他卡。
function s.initial_effect(c)
	-- ①：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次自己或对方的怪兽攻击宣言，这张卡的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ③：自己主要阶段才能发动。这张卡的攻击力下降5000，场上的其他卡全部破坏。这个卡名的③的效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤战斗不破坏的对象：自身以及与自身进行战斗的对方怪兽。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 攻击宣言时，展示卡片并使自身攻击力上升1000，然后刷新场地状态。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在决斗界面展示该卡片，提示玩家该效果正在发动。
	Duel.Hint(HINT_CARD,0,id)
	-- 这张卡的攻击力上升1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	-- 立即刷新场上所有卡片的状态和数值。
	Duel.AdjustAll()
end
-- 效果③的发动准备与合法性检测：自身攻击力在5000以上且场上有其他卡存在，并设置破坏的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查发动条件：自身攻击力是否在5000以上，且场上是否存在至少1张除自身以外的卡。
	if chk==0 then return c:IsAttackAbove(5000) and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上除自身以外的所有卡片。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置连锁处理的操作信息：破坏场上除自身以外的所有卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果③的处理：检查自身状态，若自身里侧表示、已离场、攻击力不足5000或已被战斗破坏则不处理。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:GetAttack()<5000
		or c:IsStatus(STATUS_BATTLE_DESTROYED) then
		return
	end
	-- 这张卡的攻击力下降5000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(-5000)
	c:RegisterEffect(e1)
	if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		-- 获取场上除这张卡以外的所有卡片。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
		-- 因效果破坏获取到的所有其他卡片。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
