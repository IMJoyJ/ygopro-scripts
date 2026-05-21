--混沌の創世神
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把光属性和暗属性的怪兽各1只除外的场合可以特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：从手卡特殊召唤的这张卡存在的场合，从除外的自己以及对方的怪兽之中以合计3只为对象才能发动（同名卡最多1张）。那之内的1只在自己场上特殊召唤，剩余用喜欢的顺序回到持有者卡组最下面。
function c90488465.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把光属性和暗属性的怪兽各1只除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c90488465.spcon)
	e1:SetTarget(c90488465.sptg)
	e1:SetOperation(c90488465.spop)
	c:RegisterEffect(e1)
	-- ①：从手卡特殊召唤的这张卡存在的场合，从除外的自己以及对方的怪兽之中以合计3只为对象才能发动（同名卡最多1张）。那之内的1只在自己场上特殊召唤，剩余用喜欢的顺序回到持有者卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90488465,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,90488465)
	e2:SetCondition(c90488465.tdcon)
	e2:SetTarget(c90488465.tdtg)
	e2:SetOperation(c90488465.tdop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以作为特殊召唤Cost除外的光属性或暗属性怪兽
function c90488465.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 自身特殊召唤规则的特殊召唤条件判定
function c90488465.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取自己墓地中所有满足特殊召唤Cost条件的光属性和暗属性怪兽
	local g=Duel.GetMatchingGroup(c90488465.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查墓地中是否存在光属性和暗属性怪兽各1只的组合
	return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
end
-- 自身特殊召唤规则的特殊召唤选择目标处理
function c90488465.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足特殊召唤Cost条件的光属性和暗属性怪兽
	local g=Duel.GetMatchingGroup(c90488465.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地中选择光属性和暗属性怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 自身特殊召唤规则的特殊召唤操作处理
function c90488465.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选中的2只怪兽表侧表示除外
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 效果①的发动条件：这张卡是从手卡特殊召唤的
function c90488465.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL) and e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 过滤除外状态的、可以成为效果对象且能回到卡组或能特殊召唤的表侧表示怪兽
function c90488465.tdfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e)
		and (c:IsAbleToDeck() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 检查选中的3张卡是否满足“同名卡最多1张（卡名各不相同）”，且其中至少有2张能回到卡组、至少有1张能特殊召唤
function c90488465.fselect(g,e,tp)
	-- 检查卡片组是否卡名各不相同，且包含至少2张可回卡组的卡和至少1张可特殊召唤的卡
	return aux.dncheck(g) and g:IsExists(Card.IsAbleToDeck,2,nil) and g:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false)
end
-- 效果①的发动准备与对象选择
function c90488465.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取双方除外状态的满足条件的表侧表示怪兽
	local dg=Duel.GetMatchingGroup(c90488465.tdfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,e,tp)
	if chkc then return false end
	-- 检查是否能选出符合条件的3张卡，且自己场上有可用的怪兽区域
	if chk==0 then return dg:CheckSubGroup(c90488465.fselect,3,3,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local g=dg:SelectSubGroup(tp,c90488465.fselect,false,3,3,e,tp)
	-- 将选中的3张卡注册为效果的对象
	Duel.SetTargetCard(g)
	-- 设置连锁信息：预计将其中2张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	-- 设置连锁信息：预计将其中1张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤可以特殊召唤的怪兽
function c90488465.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的效果处理（特殊召唤1只，其余回到卡组最下面）
function c90488465.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检查对象卡片是否存在且自己场上仍有可用的怪兽区域
	if tg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=tg:FilterSelect(tp,c90488465.spfilter,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选中的1只怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			tg:Sub(sg)
			-- 将剩余的对象卡片以喜欢的顺序回到持有者卡组最下面
			aux.PlaceCardsOnDeckBottom(tp,tg)
		end
	end
end
