--賜炎の咎姫
-- 效果：
-- 效果怪兽2只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己不是炎属性怪兽不能特殊召唤。
-- ②：自己主要阶段才能发动。从自己墓地把1只炎属性怪兽特殊召唤。
-- ③：这张卡在墓地存在的状态，对方场上有怪兽特殊召唤的场合，以自己场上1只炎属性怪兽和对方场上1只怪兽为对象才能发动。那些怪兽破坏，这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册：为这张卡注册墓地标记效果、连接召唤手续（2只以上效果怪兽）、苏生限制、①自肃效果、②墓地苏生效果、③墓地诱发破坏并特殊召唤自身的效果。
function s.initial_effect(c)
	-- 为这张卡注册“已在墓地”的标记检测效果，用于③效果发动时判断此卡在对方特殊召唤前是否已存在于墓地。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 添加连接召唤手续：使用2只以上效果怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己不是炎属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从自己墓地把1只炎属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"苏生"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的状态，对方场上有怪兽特殊召唤的场合，以自己场上1只炎属性怪兽和对方场上1只怪兽为对象才能发动。那些怪兽破坏，这张卡特殊召唤。
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
-- ①自肃效果的条件函数：当特殊召唤的怪兽不是炎属性时，禁止该特殊召唤（对己方玩家适用）。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end
-- ②效果选择墓地炎属性怪兽的过滤条件：该怪兽是炎属性且能被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- ②效果的发动条件判定：自己主要怪兽区有空位，且墓地存在符合条件的炎属性怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只可特殊召唤的炎属性怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行特殊召唤，来源为墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：从自己墓地选择1只炎属性怪兽，以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己场上没有可用怪兽区域，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的炎属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果发动的过滤条件：特殊召唤的怪兽由对方控制，且不是由导致此卡进入墓地的那个效果所特殊召唤。
function s.spfilter2(c,tp,se)
	return c:IsControler(tp) and (se==nil or c:GetReasonEffect()~=se)
end
-- ③效果的发动条件：此卡在墓地存在，且对方场上有怪兽特殊召唤成功，并且该特殊召唤满足spfilter2的过滤条件。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.spfilter2,1,nil,1-tp,se)
end
-- ③选择自己场上炎属性怪兽作为对象的过滤条件：该怪兽表侧表示且为炎属性，并且将其破坏后自己场上仍有可用的怪兽区域。
function s.descheck(c,tp)
	-- 怪兽需为表侧炎属性，且破坏后自己场上仍有空位。
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and Duel.GetMZoneCount(tp,c)>0
end
-- ③效果发动条件确认：己方场上存在1只可破坏的炎属性怪兽、对方场上有1只怪兽，且此卡可被特殊召唤。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在1只满足条件的炎属性怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.descheck,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查对方场上是否存在1只可作为对象的怪兽。
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 显示选择提示，要求玩家选择要破坏的卡（己方怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只符合条件的炎属性怪兽作为对象。
	local g1=Duel.SelectTarget(tp,s.descheck,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 显示选择提示，要求玩家选择要破坏的卡（对方怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为对象。
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：本效果将破坏选中的2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
	-- 设置操作信息：效果处理时将从墓地特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- ③效果处理：获取对象卡，破坏仍关联的对象；若破坏成功且此卡仍可行，则将此卡从墓地特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本连锁选中的对象卡，并筛选出仍与效果关联的卡作为实际破坏对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 判定条件：对象卡确实被效果破坏、此卡仍与效果关联且自己有可用怪兽区域。
		if Duel.Destroy(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 将此卡从墓地以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
