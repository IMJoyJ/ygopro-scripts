--磁石の戦士マグネット・バルキリオン
-- 效果：
-- 这张卡不能通常召唤。从自己的手卡·场上把「磁石战士α」「磁石战士β」「磁石战士γ」各1只解放的场合可以特殊召唤。
-- ①：把这张卡解放，以自己墓地的「磁石战士α」「磁石战士β」「磁石战士γ」各1只为对象才能发动。那些怪兽特殊召唤。
function c75347539.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己的手卡·场上把「磁石战士α」「磁石战士β」「磁石战士γ」各1只解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c75347539.spcon)
	e1:SetTarget(c75347539.sptg)
	e1:SetOperation(c75347539.spop)
	c:RegisterEffect(e1)
	-- ①：把这张卡解放，以自己墓地的「磁石战士α」「磁石战士β」「磁石战士γ」各1只为对象才能发动。那些怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75347539,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c75347539.cost)
	e2:SetTarget(c75347539.target)
	e2:SetOperation(c75347539.operation)
	c:RegisterEffect(e2)
end
-- 创建用于检查「磁石战士α」「磁石战士β」「磁石战士γ」卡号的条件检查函数数组
c75347539.spchecks=aux.CreateChecks(Card.IsCode,{99785935,39256679,11549357})
-- 特殊召唤素材选择的过滤函数，检查怪兽区域空位以及是否能被解放
function c75347539.fselect(g,tp)
	-- 检查玩家场上是否有足够的怪兽区空位，且所选卡片组在手卡·场上均可作为特殊召唤素材解放
	return aux.mzctcheck(g,tp) and Duel.CheckReleaseGroupEx(tp,aux.IsInGroup,#g,REASON_SPSUMMON,true,nil,g)
end
-- 特殊召唤规则的条件判断函数，检查手卡·场上是否存在可解放的「磁石战士α」「磁石战士β」「磁石战士γ」各1只
function c75347539.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家手卡·场上所有可作为特殊召唤素材解放的卡片组
	local g=Duel.GetReleaseGroup(tp,true,REASON_SPSUMMON)
	return g:CheckSubGroupEach(c75347539.spchecks,c75347539.fselect,tp)
end
-- 特殊召唤规则的素材选择处理函数，选择要解放的「磁石战士α」「磁石战士β」「磁石战士γ」各1只并保存
function c75347539.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家手卡·场上所有可作为特殊召唤素材解放的卡片组
	local g=Duel.GetReleaseGroup(tp,true,REASON_SPSUMMON)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=g:SelectSubGroupEach(tp,c75347539.spchecks,true,c75347539.fselect,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行函数，解放选定的素材怪兽
function c75347539.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选定的特殊召唤素材怪兽组
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 效果①的代价处理函数，检查并解放自身
function c75347539.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 墓地「磁石战士」怪兽的过滤函数，检查卡名是否匹配且能否特殊召唤
function c75347539.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的对象选择与发动准备函数，检查怪兽区空位并选择墓地的「磁石战士α」「磁石战士β」「磁石战士γ」各1只作为对象
function c75347539.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上的怪兽区域空位数是否大于等于2
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		-- 检查自己墓地是否存在可以特殊召唤的「磁石战士α」
		and Duel.IsExistingTarget(c75347539.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,99785935)
		-- 检查自己墓地是否存在可以特殊召唤的「磁石战士β」
		and Duel.IsExistingTarget(c75347539.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,39256679)
		-- 检查自己墓地是否存在可以特殊召唤的「磁石战士γ」
		and Duel.IsExistingTarget(c75347539.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,11549357) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地的1只「磁石战士α」作为效果对象
	local g1=Duel.SelectTarget(tp,c75347539.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,99785935)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地的1只「磁石战士β」作为效果对象
	local g2=Duel.SelectTarget(tp,c75347539.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,39256679)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地的1只「磁石战士γ」作为效果对象
	local g3=Duel.SelectTarget(tp,c75347539.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,11549357)
	g1:Merge(g2)
	g1:Merge(g3)
	-- 设置特殊召唤的操作信息，包含选定的3只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,3,0,0)
end
-- 效果①的效果处理函数，将作为对象的怪兽特殊召唤
function c75347539.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取当前连锁中仍对该效果有效的对象怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>=2 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 将选定的怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
