--C－クラッシュ・ワイバーン
-- 效果：
-- ①：1回合1次，可以把1个以下效果发动。
-- ●以自己场上1只机械族·光属性怪兽为对象，把这张卡当作装备魔法卡使用来装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备状态的这张卡特殊召唤。
-- ②：装备怪兽不受对方的陷阱卡的效果影响。
-- ③：这张卡从场上送去墓地的场合才能发动。从手卡把1只同盟怪兽特殊召唤。
function c3405259.initial_effect(c)
	-- 为卡片注册同盟怪兽机制，使其具备装备、特殊召唤等效果
	aux.EnableUnionAttribute(c,c3405259.filter)
	-- 装备怪兽不受对方的陷阱卡的效果影响
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(c3405259.efilter)
	c:RegisterEffect(e4)
	-- 这张卡从场上送去墓地的场合才能发动。从手卡把1只同盟怪兽特殊召唤
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c3405259.spcon2)
	e5:SetTarget(c3405259.sptg2)
	e5:SetOperation(c3405259.spop2)
	c:RegisterEffect(e5)
end
c3405259.has_text_type=TYPE_UNION
-- 过滤条件：机械族且光属性的怪兽
function c3405259.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 效果过滤器：对方陷阱卡的效果无法影响装备怪兽
function c3405259.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:GetOwner()~=e:GetOwner()
		and te:IsActiveType(TYPE_TRAP)
end
-- 条件判断：卡片是从场上送去墓地的
function c3405259.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：同盟怪兽且可以特殊召唤
function c3405259.spfilter(c,e,tp)
	return c:IsType(TYPE_UNION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件：手牌有同盟怪兽且场上存在空位
function c3405259.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌是否存在满足条件的同盟怪兽
		and Duel.IsExistingMatchingCard(c3405259.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：准备从手牌特殊召唤一只同盟怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤操作：选择并特殊召唤一只同盟怪兽
function c3405259.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的同盟怪兽
	local g=Duel.SelectMatchingCard(tp,c3405259.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的同盟怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
