--E・HERO サンダー・ジャイアント－ボルティック・サンダー
-- 效果：
-- 属性不同的「元素英雄」怪兽×2
-- 这张卡不用融合召唤不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，若对方场上的卡数量比自己场上的卡多则能发动。场上的其他卡全部破坏。
-- ②：把用通常怪兽为素材作融合召唤的这张卡解放，以自己墓地1只「元素英雄」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，启用复活限制，添加融合召唤手续，设置特殊召唤条件为必须融合召唤，注册破坏效果和特殊召唤效果，注册融合素材检查效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个满足s.ffilter条件的怪兽作为融合素材，允许融合召唤时使用额外卡
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- 创建效果e0，设置为特殊召唤条件效果，禁止无效和复制，设置为融合召唤限制
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置效果e0的值为aux.fuslimit函数，表示必须通过融合召唤方式特殊召唤
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- 创建效果e1，设置为触发效果，特殊召唤成功时发动，破坏对方场上卡牌
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
	-- 创建效果e2，设置为起动效果，解放此卡并支付代价，从墓地特殊召唤一只元素英雄怪兽
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
	-- 创建效果e3，设置为融合素材检查效果，用于检测是否使用通常怪兽作为融合素材
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	c:RegisterEffect(e3)
end
s.material_setcode=0x8
-- 融合过滤函数，判断怪兽是否为元素英雄卡组且属性不重复
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x3008) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 融合素材检查函数，若使用通常怪兽作为融合素材则注册标志位
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	if mg:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then
		c:RegisterFlagEffect(id,RESET_EVENT+0x4fe0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"用通常怪兽为素材作融合召唤"
	end
end
-- 破坏效果发动条件函数，判断对方场上的卡数量是否多于己方
function s.descon(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 返回对方场上的卡数量是否多于己方场上的卡数量
	return Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)<Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
end
-- 破坏效果目标函数，检查是否有场上卡可破坏并设置操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有场上卡可破坏
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上所有卡的集合
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置操作信息为破坏效果，目标为场上所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 破坏效果处理函数，破坏场上所有卡（除自身外）
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有卡的集合（除自身外）
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将目标卡破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 特殊召唤代价函数，检查是否有空怪兽区、此卡可解放且已使用通常怪兽作为融合素材
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有空怪兽区
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and e:GetHandler():IsReleasable()
		and e:GetHandler():GetFlagEffect(id)>0 end
	-- 解放此卡作为代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤过滤函数，判断是否为元素英雄卡组且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤目标函数，检查是否有墓地元素英雄怪兽可特殊召唤并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 检查是否有空怪兽区
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查是否有墓地元素英雄怪兽可特殊召唤
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤效果，目标为选择的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果处理函数，将目标卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且未受王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
