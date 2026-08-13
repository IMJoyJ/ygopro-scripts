--H－C ヤールングレイプ
-- 效果：
-- 战士族1星怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上的战士族怪兽在1回合各有1次不会被战斗·效果破坏。
-- ②：把这张卡2个超量素材取除，以自己墓地1只等级或者阶级是4的战士族怪兽为对象才能发动。那只怪兽特殊召唤，这张卡的攻击力上升那个原本攻击力数值。
-- ③：对方怪兽进行战斗的攻击宣言时才能发动。自己基本分回复那只怪兽的攻击力一半的数值。
local s,id,o=GetID()
-- 定义卡片的初始化函数：添加战士族1星怪兽×2的XYZ召唤手续、苏生限制，并注册①的破坏抗性、②的起动特殊召唤/攻击力上升、③的回复LP三个效果。
function c23848752.initial_effect(c)
	-- 添加XYZ召唤手续：用2只战士族1星怪兽叠放来XYZ召唤这张卡。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),1,2)
	c:EnableReviveLimit()
	-- ①：自己场上的战士族怪兽在1回合各有1次不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c23848752.indtg)
	e1:SetValue(c23848752.indct)
	c:RegisterEffect(e1)
	-- ②：把这张卡2个超量素材取除，以自己墓地1只等级或者阶级是4的战士族怪兽为对象才能发动。那只怪兽特殊召唤，这张卡的攻击力上升那个原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,23848752)
	e2:SetCost(c23848752.spcost)
	e2:SetTarget(c23848752.sptg)
	e2:SetOperation(c23848752.spop)
	c:RegisterEffect(e2)
	-- ③：对方怪兽进行战斗的攻击宣言时才能发动。自己基本分回复那只怪兽的攻击力一半的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,23848752+o)
	e3:SetCondition(c23848752.rccon)
	e3:SetOperation(c23848752.rcop)
	c:RegisterEffect(e3)
end
-- ①效果的适用对象判定：自己场上表侧表示的战士族怪兽才能获得免破坏次数。
function c23848752.indtg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- ①效果的免破坏次数计算：当破坏原因为战斗或效果时，提供1次不会被破坏的次数，否则为0。
function c23848752.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
-- ②效果的发动代价：从这张卡上取除2个超量素材。
function c23848752.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- ②效果的特殊召唤对象过滤：自己墓地的战士族怪兽，且等级或阶级为4，并可以被特殊召唤。
function c23848752.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and (c:IsLevel(4) or c:IsRank(4)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标判定：确认自己主要怪兽区有空位，且墓地存在满足条件的战士族怪兽可作为对象。
function c23848752.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23848752.spfilter(chkc,e,tp) end
	-- 检查自己主要怪兽区域是否有空位，作为发动②效果的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己墓地是否存在1只满足条件的战士族怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c23848752.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向发动玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只满足条件的墓地战士族怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c23848752.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，告知系统本效果将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：若场上还有空位，将对象怪兽特殊召唤；若成功且这张卡仍在场上表侧表示，则这张卡的攻击力上升那只怪兽的原本攻击力数值。
function c23848752.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己主要怪兽区域是否有空位，若无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果相关，并将其以表侧表示特殊召唤到自己场上；若成功则继续处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升那个原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ③效果的发动条件：对方怪兽进行攻击宣言，且对方那只攻击怪兽是表侧表示并正在参与战斗。
function c23848752.rccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方正在战斗中的怪兽。
	local tc=Duel.GetBattleMonster(1-tp)
	return tc and tc:IsFaceup() and tc:IsRelateToBattle()
end
-- ③效果处理：获取对方战斗中的怪兽，若其仍在战斗且表侧表示，则回复那只怪兽当前攻击力一半数值的基本分。
function c23848752.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方正在战斗中的怪兽。
	local tc=Duel.GetBattleMonster(1-tp)
	if tc and tc:IsFaceup() and tc:IsRelateToBattle() then
		-- 回复自己等于对方战斗怪兽攻击力一半数值的基本分，原因为效果。
		Duel.Recover(tp,tc:GetAttack()/2,REASON_EFFECT)
	end
end
