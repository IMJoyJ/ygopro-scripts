--E・HERO サンダー・ジャイアント－ボルティック・サンダー
-- 效果：
-- 属性不同的「元素英雄」怪兽×2
-- 这张卡不用融合召唤不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，若对方场上的卡数量比自己场上的卡多则能发动。场上的其他卡全部破坏。
-- ②：把用通常怪兽为素材作融合召唤的这张卡解放，以自己墓地1只「元素英雄」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡的初始效果：赋予融合召唤限制（只能用融合召唤）、设定由2只属性不同的「元素英雄」怪兽作为融合素材的融合手续、注册①破坏全场其他卡的效果、②解放自身苏生墓地「元素英雄」的起动效果，以及用于检测融合素材是否为通常怪兽的材料检查效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：使用2只属性不同的「元素英雄」怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定为aux.fuslimit，即仅当通过融合召唤时才能特殊召唤，实现‘不用融合召唤不能特殊召唤’的限制。
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ①：这张卡特殊召唤的场合，若对方场上的卡数量比自己场上的卡多则能发动。场上的其他卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：把用通常怪兽为素材作融合召唤的这张卡解放，以自己墓地1只「元素英雄」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 用通常怪兽为素材作融合召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	c:RegisterEffect(e3)
end
s.material_setcode=0x8
-- 融合素材过滤器：素材必须是「元素英雄」怪兽，且与已选素材的属性均不同，从而保证使用2只属性不同的「元素英雄」怪兽。
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x3008) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 素材检查效果：当这张卡融合召唤成功时，检查其融合素材中是否存在通常怪兽；若存在，则为这张卡注册一个标记（flag），用于记录‘用通常怪兽为素材作融合召唤’，该标记会在离场后清除，并在客户端显示提示文字。
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	if mg:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then
		c:RegisterFlagEffect(id,RESET_EVENT+0x4fe0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"用通常怪兽为素材作融合召唤"
	end
end
-- ①效果的发动条件：比较我方场上的卡数和对方场上的卡数，若对方场上的卡数量比自己场上的卡多，则条件成立（即可以发动）。
function s.descon(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计我方场上卡片数量少于对方场上卡片数量，用于满足①效果的发动条件。
	return Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)<Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
end
-- ①效果的发动目标处理：首先确认场上存在除这张卡以外的卡；然后获取场上所有其他卡（包括双方怪兽和魔陷），并设置将把这些卡全部破坏。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时（chk==0）检查场上是否存在除这张卡以外的其他卡片，以此作为可以发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 取得场上除这张卡以外的所有卡片，作为将被破坏的集合（不取对象，处理时也可能包括新出现的卡）。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置操作信息，声明本次效果将破坏目标集合中的所有卡片，破坏数量为当前集合的卡片数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ①效果处理：再次取得场上除自身以外的所有卡片，用效果将它们全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，获取场上除自身以外的所有卡片（使用aux.ExceptThisCard排除发动效果的这张卡）。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将所有这些卡片以‘效果’的原因破坏（REASON_EFFECT）。
	Duel.Destroy(sg,REASON_EFFECT)
end
-- ②效果的代价判定：确认解放这张卡后我方怪兽区有可用区域、这张卡可以解放，并且这张卡带有‘用通常怪兽为素材作融合召唤’的标记；满足后以解放作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查解放这张卡后我方场上是否有可用的怪兽区域（供后续特殊召唤使用）。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and e:GetHandler():IsReleasable()
		and e:GetHandler():GetFlagEffect(id)>0 end
	-- 解放这张卡作为发动②效果的费用（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 墓地「元素英雄」怪兽的过滤器：需要是「元素英雄」字段怪兽，并且满足当前效果所能进行的特殊召唤条件（包括苏生限制等）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的取对象处理：从自己墓地选择1只符合条件的「元素英雄」怪兽作为对象；发动前确认解放后有空位且墓地存在这样的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 检查解放这张卡后我方场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查自己墓地是否存在满足spfilter过滤条件的「元素英雄」怪兽作为可以选择的特殊召唤对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示选择提示，要求其选择要特殊召唤的怪兽卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「元素英雄」怪兽作为效果对象，并将其设定为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，声明本次效果将特殊召唤对象怪兽1只（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取得对象怪兽，若其仍在墓地且与连锁相关，并且不受王家长眠之谷的影响，则将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍与本次连锁相关（未被无效/离场），并且其墓地效果不受王家长眠之谷禁止，从而可以特殊召唤。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的怪兽区（不检查召唤条件，不限制召唤类型）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
