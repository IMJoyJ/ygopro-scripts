--冥宮の番人
-- 效果：
-- 通常怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：效果怪兽以外的自己场上的怪兽的攻击力上升500，对方场上的效果怪兽的攻击力下降500。
-- ②：这张卡被对方破坏的场合，以效果怪兽以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c31897444.initial_effect(c)
	-- 为冥宫的番人添加连接召唤手续：要求以2只通常怪兽作为连接素材（连接标记为2）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_NORMAL),2,2)
	c:EnableReviveLimit()
	-- ①：效果怪兽以外的自己场上的怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该攻击力变化效果的作用对象为自己场上非效果怪兽，即“效果怪兽以外的自己场上的怪兽”。
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsType,TYPE_EFFECT)))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetTargetRange(0,LOCATION_MZONE)
	-- 设置该攻击力变化效果的作用对象为对方场上的效果怪兽，使其攻击力下降500。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_EFFECT))
	e2:SetValue(-500)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被对方破坏的场合，以效果怪兽以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31897444,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,31897444)
	e3:SetCondition(c31897444.spcon)
	e3:SetTarget(c31897444.sptg)
	e3:SetOperation(c31897444.spop)
	c:RegisterEffect(e3)
end
-- ②效果的发动条件：这张卡被对方破坏且破坏前由自己控制（rp表示破坏来源方，e:GetHandler():IsPreviousControler(tp)判定此卡之前在自己场上）。
function c31897444.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 墓地对象怪兽的筛选条件：必须是效果怪兽以外的怪兽，且可以特殊召唤。
function c31897444.spfilter(c,e,tp)
	return not c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件与取对象处理：若为连锁处理，则校验选择的对象是否仍为符合条件的墓地怪兽；若为发动判定，则检查自己场上是否有空位以及墓地是否存在符合条件的对象。
function c31897444.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31897444.spfilter(chkc,e,tp) end
	-- 判定发动条件之一：自己主要怪兽区域存在可用的空位，供后续特殊召唤使用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定发动条件之二：自己墓地存在至少1只满足筛选条件的怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c31897444.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示提示信息，要求从符合条件的卡中选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c31897444.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次效果处理的信息：该效果将进行特殊召唤，对象为所选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取得发动时选择的对象怪兽，若其仍与效果关联，则将其特殊召唤到自己场上（表侧攻击表示）。
function c31897444.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这个效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
