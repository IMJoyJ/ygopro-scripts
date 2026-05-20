--メルフィー・マミィ
-- 效果：
-- 兽族2星怪兽×2只以上
-- ①：自己·对方回合1次，可以发动。从自己的手卡·场上选1只兽族怪兽在这张卡下面重叠作为超量素材。
-- ②：这张卡持有的超量素材数量让这张卡得到以下效果。
-- ●3个以上：这张卡不会被战斗破坏。
-- ●4个以上：这张卡的战斗发生的对自己的战斗伤害变成0。
-- ●5个以上：这张卡和攻击表示怪兽进行战斗的攻击宣言时才能发动。给与对方那只攻击表示怪兽的攻击力数值的伤害。
function c76833149.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：兽族2星怪兽2只以上（最多99只）进行叠放。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),2,2,nil,nil,99)
	-- ①：自己·对方回合1次，可以发动。从自己的手卡·场上选1只兽族怪兽在这张卡下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76833149,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1)
	e1:SetTarget(c76833149.ovtg)
	e1:SetOperation(c76833149.ovop)
	c:RegisterEffect(e1)
	-- ●3个以上：这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	e2:SetLabel(3)
	e2:SetCondition(c76833149.indcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetLabel(4)
	c:RegisterEffect(e3)
	-- ●5个以上：这张卡和攻击表示怪兽进行战斗的攻击宣言时才能发动。给与对方那只攻击表示怪兽的攻击力数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(76833149,1))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c76833149.damcon)
	e4:SetTarget(c76833149.damtg)
	e4:SetOperation(c76833149.damop)
	c:RegisterEffect(e4)
end
-- 过滤函数：筛选自己手卡或场上表侧表示的、可以作为超量素材的兽族怪兽。
function c76833149.ovfilter(c,e)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsRace(RACE_BEAST) and c:IsCanOverlay() and (not e or not c:IsImmuneToEffect(e))
end
-- 效果①的发动准备与合法性检测：自身必须是超量怪兽，且手卡或场上存在可作为素材的兽族怪兽。
function c76833149.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查手卡或场上是否存在至少1只除自身以外、满足过滤条件的兽族怪兽。
		and Duel.IsExistingMatchingCard(c76833149.ovfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,e:GetHandler()) end
end
-- 效果①的处理：若自身仍在场，则让玩家从手卡或场上选择1只兽族怪兽重叠作为自身的超量素材。
function c76833149.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 玩家从手卡或场上选择1只满足条件的兽族怪兽。
		local g=Duel.SelectMatchingCard(tp,c76833149.ovfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,c,e)
		local tc=g:GetFirst()
		if tc then
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				-- 若被选作素材的怪兽持有超量素材，则根据规则将那些超量素材送去墓地。
				Duel.SendtoGrave(og,REASON_RULE)
			end
			-- 将选择的怪兽重叠作为这张卡的超量素材。
			Duel.Overlay(c,tc)
		end
	end
end
-- 永续效果的适用条件：这张卡持有的超量素材数量达到设定的数值（3个或4个）以上。
function c76833149.indcon(e)
	local ct=e:GetLabel()
	return ct and e:GetHandler():GetOverlayCount()>=ct
end
-- 效果②（5个以上）的发动条件：这张卡持有5个以上的超量素材，且与对方的表侧攻击表示怪兽进行战斗的攻击宣言时。
function c76833149.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:GetOverlayCount()>=5 and bc and bc:IsPosition(POS_FACEUP_ATTACK)
		-- 检查当前进行攻击宣言的怪兽或被攻击的对象是否为这张卡。
		and (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
end
-- 效果②（5个以上）的靶向与操作信息设置：确认战斗对手怪兽的攻击力，并注册给与对方伤害的操作信息。
function c76833149.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetBattleTarget():GetAttack()
	-- 设置效果处理信息：给与对方玩家相当于该攻击表示怪兽攻击力数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果②（5个以上）的处理：若战斗对手怪兽仍以表侧攻击表示存在于战斗中，则给与对方其攻击力数值的伤害。
function c76833149.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsRelateToBattle() and bc:IsPosition(POS_FACEUP_ATTACK) then
		-- 给与对方玩家相当于该战斗对手怪兽攻击力数值的效果伤害。
		Duel.Damage(1-tp,bc:GetAttack(),REASON_EFFECT)
	end
end
