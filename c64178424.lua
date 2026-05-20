--転生炎獣の意志
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己主要阶段才能发动。从自己的手卡·墓地选1只「转生炎兽」怪兽特殊召唤。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以用和自身同名的怪兽为素材作连接召唤的自己场上1只「转生炎兽」连接怪兽为对象才能发动。从自己的手卡·墓地选最多有那只怪兽的连接标记数量的「转生炎兽」怪兽守备表示特殊召唤。
function c64178424.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。从自己的手卡·墓地选1只「转生炎兽」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64178424,0))  --"特殊召唤1只怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,64178424)
	e2:SetTarget(c64178424.sptg)
	e2:SetOperation(c64178424.spop)
	c:RegisterEffect(e2)
	-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以用和自身同名的怪兽为素材作连接召唤的自己场上1只「转生炎兽」连接怪兽为对象才能发动。从自己的手卡·墓地选最多有那只怪兽的连接标记数量的「转生炎兽」怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64178424,1))  --"特殊召唤连接标记数量的怪兽"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,64178424)
	e3:SetCost(c64178424.spcost)
	e3:SetTarget(c64178424.sptg2)
	e3:SetOperation(c64178424.spop2)
	c:RegisterEffect(e3)
	if not c64178424.global_check then
		c64178424.global_check=true
		-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：自己主要阶段才能发动。从自己的手卡·墓地选1只「转生炎兽」怪兽特殊召唤。②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以用和自身同名的怪兽为素材作连接召唤的自己场上1只「转生炎兽」连接怪兽为对象才能发动。从自己的手卡·墓地选最多有那只怪兽的连接标记数量的「转生炎兽」怪兽守备表示特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c64178424.valcheck)
		-- 注册全局效果，用于在决斗中持续检测怪兽的连接召唤素材。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查连接召唤的素材，如果素材中存在与自身同名的怪兽，则给该怪兽注册一个特定的标记（Flag）。
function c64178424.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,c:GetCode()) then
		c:RegisterFlagEffect(64178424,RESET_EVENT+0x4fe0000,0,1)
	end
end
-- 过滤函数：检查卡片是否为「转生炎兽」怪兽，且能否被特殊召唤。
function c64178424.spfilter(c,e,tp)
	return c:IsSetCard(0x119) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测（Target函数）。
function c64178424.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或墓地是否存在至少1只满足特殊召唤条件的「转生炎兽」怪兽。
		and Duel.IsExistingMatchingCard(c64178424.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示此效果将从手卡或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的效果处理（Operation函数）。
function c64178424.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的「转生炎兽」怪兽（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c64178424.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动代价（Cost函数）：将魔法与陷阱区域表侧表示的这张卡送去墓地。
function c64178424.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 执行代价：将自身送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数：检查是否为自己场上表侧表示、以同名怪兽为素材连接召唤的「转生炎兽」连接怪兽。
function c64178424.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x119) and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(64178424)~=0
end
-- 过滤函数：检查卡片是否为「转生炎兽」怪兽，且能否以守备表示特殊召唤。
function c64178424.spfilter2(c,e,tp)
	return c:IsSetCard(0x119) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备与合法性检测（Target函数）。
function c64178424.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c64178424.filter(chkc) end
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在符合条件的「转生炎兽」连接怪兽作为效果对象。
		and Duel.IsExistingTarget(c64178424.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己的手卡或墓地是否存在至少1只可以守备表示特殊召唤的「转生炎兽」怪兽。
		and Duel.IsExistingMatchingCard(c64178424.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只符合条件的「转生炎兽」连接怪兽作为效果对象并进行取对象操作。
	Duel.SelectTarget(tp,c64178424.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁处理的操作信息，表示此效果将从手卡或墓地特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的效果处理（Operation函数）。
function c64178424.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 计算可以特殊召唤的最大数量（取空怪兽区域数量与对象怪兽连接标记数量的较小值）。
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),tc:GetLink())
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择最多等同于计算出数量的「转生炎兽」怪兽（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c64178424.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
