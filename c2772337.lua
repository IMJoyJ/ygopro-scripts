--賜炎の咎姫
-- 效果：
-- 效果怪兽2只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己不是炎属性怪兽不能特殊召唤。
-- ②：自己主要阶段才能发动。从自己墓地把1只炎属性怪兽特殊召唤。
-- ③：这张卡在墓地存在的状态，对方场上有怪兽特殊召唤的场合，以自己场上1只炎属性怪兽和对方场上1只怪兽为对象才能发动。那些怪兽破坏，这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册墓地状态检查、连接召唤手续、永续召唤限制，并创建①②③效果
function s.initial_effect(c)
	-- 注册卡片进入墓地时的状态监听效果，用于③效果的发动条件判断
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 设置该卡为连接召唤所需至少2只效果怪兽的连接怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- 只要这张卡在怪兽区域存在，自己不是炎属性怪兽不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	-- 自己主要阶段才能发动。从自己墓地把1只炎属性怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"苏生"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 这张卡在墓地存在的状态，对方场上有怪兽特殊召唤的场合，以自己场上1只炎属性怪兽和对方场上1只怪兽为对象才能发动。那些怪兽破坏，这张卡特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏怪兽"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetLabelObject(e0)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 限制非炎属性怪兽的特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 过滤满足特殊召唤条件且为炎属性的墓地怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 判断是否满足②效果的发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的炎属性怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置②效果的处理信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行②效果的处理，选择并特殊召唤墓地中的炎属性怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的炎属性怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断目标怪兽是否为己方控制且非由特定效果召唤
function s.spfilter2(c,tp,se)
	return c:IsControler(tp) and (se==nil or c:GetReasonEffect()~=se)
end
-- 判断③效果的发动条件，即对方有怪兽特殊召唤成功
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.spfilter2,1,nil,1-tp,se)
end
-- 判断目标怪兽是否为正面表示、炎属性且场上存在空位
function s.descheck(c,tp)
	-- 判断目标怪兽是否为正面表示、炎属性且场上存在空位
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and Duel.GetMZoneCount(tp,c)>0
end
-- 判断是否满足③效果的发动条件
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断己方场上是否存在满足条件的炎属性怪兽
	if chk==0 then return Duel.IsExistingTarget(s.descheck,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 判断对方场上是否存在任意怪兽
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择己方满足条件的炎属性怪兽
	local g1=Duel.SelectTarget(tp,s.descheck,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上任意怪兽
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置③效果的处理信息，指定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
	-- 设置③效果的处理信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 执行③效果的处理，破坏选中的怪兽并特殊召唤自身
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中指定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 判断破坏和特殊召唤是否可以执行
		if Duel.Destroy(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 将自身特殊召唤到场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
