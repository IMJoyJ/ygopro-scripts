--旋壊のヴェスペネイト
-- 效果：
-- 5星怪兽×2
-- 「旋坏之贯破黄蜂巢」1回合1次也能在自己场上的4阶超量怪兽上面重叠来超量召唤。这张卡在超量召唤的回合不能作为超量召唤的素材。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：超量召唤的这张卡被对方破坏的场合，以自己墓地1只5星以下的怪兽为对象才能发动。那只怪兽特殊召唤。
function c39317553.initial_effect(c)
	aux.AddXyzProcedure(c,nil,5,2,c39317553.ovfilter,aux.Stringid(39317553,0),2,c39317553.xyzop)  --"是否在4阶超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 效果原文内容：这张卡在超量召唤的回合不能作为超量召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetCondition(c39317553.xyzcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：超量召唤的这张卡被对方破坏的场合，以自己墓地1只5星以下的怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39317553,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,39317553)
	e3:SetCondition(c39317553.spcon)
	e3:SetTarget(c39317553.sptg)
	e3:SetOperation(c39317553.spop)
	c:RegisterEffect(e3)
end
-- 规则层面操作：判断怪兽是否为表侧表示且等级为4。
function c39317553.ovfilter(c)
	return c:IsFaceup() and c:IsRank(4)
end
-- 规则层面操作：检查是否已使用过此卡的②效果，若未使用则注册效果标识。
function c39317553.xyzop(e,tp,chk)
	-- 规则层面操作：检查是否已使用过此卡的②效果。
	if chk==0 then return Duel.GetFlagEffect(tp,39317553)==0 end
	-- 规则层面操作：注册全局标识效果，用于限制②效果1回合只能使用1次。
	Duel.RegisterFlagEffect(tp,39317553,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 规则层面操作：判断此卡是否在超量召唤的回合被特殊召唤。
function c39317553.xyzcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 规则层面操作：判断此卡是否被对方破坏且在己方场上。
function c39317553.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 规则层面操作：筛选墓地里等级为5或以下且可特殊召唤的怪兽。
function c39317553.spfilter(c,e,tp)
	return c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：设置选择目标的条件，确保目标为墓地中的怪兽。
function c39317553.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39317553.spfilter(chkc,e,tp) end
	-- 规则层面操作：检查己方场上是否有怪兽区可用。
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		-- 规则层面操作：检查己方墓地是否存在满足条件的怪兽。
		and Duel.IsExistingTarget(c39317553.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面操作：向玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：选择目标怪兽。
	local g=Duel.SelectTarget(tp,c39317553.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面操作：设置连锁的操作信息，确定特殊召唤的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
-- 规则层面操作：执行特殊召唤操作。
function c39317553.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：检查己方场上是否有怪兽区可用。
	if Duel.GetMZoneCount(tp)<1 then return end
	-- 规则层面操作：获取当前连锁的目标怪兽。
	local c=Duel.GetFirstTarget()
	if c and c:IsRelateToEffect(e) then
		-- 规则层面操作：将目标怪兽特殊召唤到己方场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
