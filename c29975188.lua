--サイバー・ドラゴン・フィーア
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「电子龙」使用。
-- ②：自己对「电子龙」的召唤·特殊召唤成功的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ③：只要这张卡在怪兽区域存在，自己场上的全部「电子龙」的攻击力·守备力上升500。
function c29975188.initial_effect(c)
	-- 给这张卡注册在怪兽区域和墓地存在时卡名当作「电子龙」的效果。
	aux.EnableChangeCode(c,70095154,LOCATION_MZONE+LOCATION_GRAVE)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己对「电子龙」的召唤·特殊召唤成功的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29975188,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,29975188)
	e2:SetCondition(c29975188.spcon)
	e2:SetTarget(c29975188.sptg)
	e2:SetOperation(c29975188.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：只要这张卡在怪兽区域存在，自己场上的全部「电子龙」的攻击力·守备力上升500。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	-- 指定该永续效果影响的对象为卡名是「电子龙」的怪兽。
	e4:SetTarget(aux.TargetBoolFunction(Card.IsCode,70095154))
	e4:SetValue(500)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
end
-- 定义过滤函数：判断被召唤·特殊召唤的怪兽是否为表侧表示且卡名为「电子龙」，并且召唤玩家是这张卡的控制者。
function c29975188.cfilter(c,tp)
	return c:IsFaceup() and c:IsCode(70095154) and c:IsSummonPlayer(tp)
end
-- 效果发动条件：本次召唤·特殊召唤成功的事件中，存在至少一只满足过滤条件的「电子龙」。
function c29975188.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29975188.cfilter,1,nil,tp)
end
-- 发动时的合法性检查：确认自己主要怪兽区域有空位，且手卡的这张卡能够以表侧守备表示特殊召唤。
function c29975188.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己的主要怪兽区域存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 将本次效果处理信息登记为特殊召唤这张卡，供系统及相关卡牌效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡仍与效果关联，则将其从手卡以表侧守备表示特殊召唤。
function c29975188.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧守备表示特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
