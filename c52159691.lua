--レイダーズ・ウィング
-- 效果：
-- 这个卡名在规则上也当作「幻影骑士团」卡、「急袭猛禽」卡使用。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把自己场上的暗属性超量怪兽1个超量素材取除才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：持有这张卡作为素材中的原本属性是暗属性的超量怪兽得到以下效果。
-- ●这张卡不会成为对方的效果的对象。
function c52159691.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在的场合，把自己场上的暗属性超量怪兽1个超量素材取除才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52159691,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,52159691)
	e1:SetCost(c52159691.spcost)
	e1:SetTarget(c52159691.sptg)
	e1:SetOperation(c52159691.spop)
	c:RegisterEffect(e1)
	-- ②：持有这张卡作为素材中的原本属性是暗属性的超量怪兽得到以下效果。●这张卡不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(c52159691.xmatcon)
	-- 将e2的Value属性设为aux.tgoval，即用该封装函数判定“不会成为对方的效果的对象”抗性是否生效；满足条件时，该卡不能被对方的效果选为对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- 定义选择要取除超量素材的怪兽的过滤函数：要求怪兽表侧表示、暗属性、超量（XYZ）类型，并且当前玩家tp能够以代价（REASON_COST）理由从它上面取除1个超量素材。
function c52159691.cfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ)
		and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
-- ①效果的发动代价处理：检查阶段先确认场上存在符合条件的暗属性超量怪兽；随后提示玩家选择1只，并从那只怪兽身上取除1个超量素材作为发动代价。
function c52159691.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0）时，判断自己场上是否存在至少1张满足cfilter（表侧暗属性超量且可去掉1个素材）的怪兽，以确认能否支付发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c52159691.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家tp发送选择提示，提示文字为“请选择要取除超量素材的怪兽”，并设置选择用途，供后续选择卡片时显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 让tp玩家从自己场上的表侧暗属性超量怪兽中选出1张，作为要取除超量素材的怪兽；GetFirst()取得被选中的唯一一张卡。
	local c=Duel.SelectMatchingCard(tp,c52159691.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的目标/发动条件定义：e:GetHandler()获取这张卡自身；在检查阶段确认我方主要怪兽区有空位，且这张卡能够被特殊召唤。
function c52159691.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查我方主要怪兽区是否存在可用空格，用于判断能否特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将当前连锁的操作信息登记为“特殊召唤”，对象为这张卡，数量为1；供本次效果处理及相关判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与该效果关联，则将其从手卡/墓地以表侧表示特殊召唤到己方场上；特殊召唤成功时，再给这张卡附加一个“从场上离开的场合改为除外”的持续效果，且该效果不会被无效。
function c52159691.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍在效果处理范围内（IsRelateToEffect），并尝试以表侧表示将其特殊召唤；只有特殊召唤成功（返回值>0）才继续执行离场除外的附加效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
-- ②效果的适用条件：判断持有这张卡作为超量素材的超量怪兽的原本属性是否为暗属性；只有原本属性为暗属性时，该超量怪兽才能获得“不会成为对方的效果的对象”的效果。
function c52159691.xmatcon(e)
	return e:GetHandler():GetOriginalAttribute()==ATTRIBUTE_DARK
end
