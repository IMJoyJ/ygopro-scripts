--手錠龍
-- 效果：
-- 这张卡被对方怪兽的攻击破坏送去墓地时，可以把这张卡当作装备卡使用给那只怪兽装备。装备怪兽的攻击力下降1800。装备怪兽被破坏让这张卡送去墓地时，这张卡可以在自己场上特殊召唤。
function c97904474.initial_effect(c)
	-- 这张卡被对方怪兽的攻击破坏送去墓地时，可以把这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97904474,0))  --"装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c97904474.eqcon)
	e1:SetTarget(c97904474.eqtg)
	e1:SetOperation(c97904474.eqop)
	c:RegisterEffect(e1)
	-- 装备怪兽被破坏让这张卡送去墓地时，这张卡可以在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97904474,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c97904474.spcon)
	e2:SetTarget(c97904474.sptg)
	e2:SetOperation(c97904474.spop)
	c:RegisterEffect(e2)
end
-- 判断发动条件：此卡因战斗破坏送去墓地，且是被对方怪兽攻击。
function c97904474.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
		-- 确认此卡是被攻击的怪兽，且进行攻击的对方怪兽表侧表示存在于对方场上并与战斗相关。
		and c==Duel.GetAttackTarget() and bc:IsFaceup() and bc:IsControler(1-tp) and bc:IsRelateToBattle()
end
-- 检查效果发动的目标：确认自己魔陷区有空位。
function c97904474.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔法与陷阱区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 定义装备限制：该装备卡只能装备给该效果指定的怪兽。
function c97904474.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 装备效果的处理：将此卡作为装备卡装备给进行攻击的对方怪兽，并使其攻击力下降1800。
function c97904474.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自己场上没有可用的魔法与陷阱区域空格，则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=c:GetBattleTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToBattle() then
		-- 将此卡作为装备卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		-- 可以把这张卡当作装备卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c97904474.eqlimit)
		c:RegisterEffect(e1)
		-- 装备怪兽的攻击力下降1800。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(-1800)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 判断特殊召唤的发动条件：此卡因失去装备对象而送去墓地，且原装备怪兽是被破坏。
function c97904474.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_LOST_TARGET) and e:GetHandler():GetPreviousEquipTarget():IsReason(REASON_DESTROY)
end
-- 检查特殊召唤的目标：确认自己怪兽区有空位且此卡可以特殊召唤，并设置操作信息。
function c97904474.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息为特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：将此卡在自己场上特殊召唤。
function c97904474.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
