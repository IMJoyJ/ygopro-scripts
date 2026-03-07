--冥宮の番人
-- 效果：
-- 通常怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：效果怪兽以外的自己场上的怪兽的攻击力上升500，对方场上的效果怪兽的攻击力下降500。
-- ②：这张卡被对方破坏的场合，以效果怪兽以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c31897444.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2只通常怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_NORMAL),2,2)
	c:EnableReviveLimit()
	-- ①：效果怪兽以外的自己场上的怪兽的攻击力上升500，对方场上的效果怪兽的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为非效果怪兽（即效果怪兽以外的自己场上的怪兽）
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsType,TYPE_EFFECT)))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetTargetRange(0,LOCATION_MZONE)
	-- 设置效果目标为效果怪兽（即对方场上的效果怪兽）
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_EFFECT))
	e2:SetValue(-500)
	c:RegisterEffect(e2)
	-- ②：这张卡被对方破坏的场合，以效果怪兽以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 判断该卡是否被对方破坏且破坏时控制权属于玩家
function c31897444.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 筛选满足条件的墓地怪兽（非效果怪兽且可特殊召唤）
function c31897444.spfilter(c,e,tp)
	return not c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件，检查是否有满足条件的墓地目标
function c31897444.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31897444.spfilter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c31897444.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c31897444.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，记录将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将选中的卡特殊召唤到场上
function c31897444.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以通常召唤方式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
