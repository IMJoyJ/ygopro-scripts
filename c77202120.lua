--アサルト・シンクロン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡特殊召唤。那之后，自己受到700伤害。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：自己场上的表侧表示的龙族同调怪兽被解放的场合或者被除外的场合，把墓地的这张卡除外，以那1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c77202120.initial_effect(c)
	-- 注册一个用于检测自身是否已在墓地的效果，用于后续效果的合法性验证
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：自己主要阶段才能发动。这张卡从手卡特殊召唤。那之后，自己受到700伤害。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77202120,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,77202120)
	e1:SetTarget(c77202120.sptg)
	e1:SetOperation(c77202120.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的表侧表示的龙族同调怪兽被解放的场合或者被除外的场合，把墓地的这张卡除外，以那1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77202120,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,77202121)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetLabelObject(e0)
	e2:SetCondition(c77202120.condition)
	e2:SetTarget(c77202120.target)
	e2:SetOperation(c77202120.activate)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 效果①的发动检测与效果处理信息设置
function c77202120.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置给与自己700伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,700)
end
-- 效果①的效果处理（特殊召唤、受到伤害并适用额外卡组特殊召唤限制）
function c77202120.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 如果这张卡特殊召唤成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断效果处理，使后续处理不视为同时进行
		Duel.BreakEffect()
		-- 给与自己700点效果伤害
		Duel.Damage(tp,700,REASON_EFFECT)
		-- 只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是同调怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c77202120.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end
-- 限制自己不能从额外卡组特殊召唤同调怪兽以外的怪兽
function c77202120.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤满足“自己场上表侧表示的龙族同调怪兽被解放或除外”条件的卡片
function c77202120.cfilter(c,tp,se)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 效果②的发动条件检测（是否有符合条件的龙族同调怪兽被解放或除外）
function c77202120.condition(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c77202120.cfilter,1,nil,tp,se)
end
-- 过滤可以作为效果②特殊召唤对象的龙族同调怪兽
function c77202120.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备，选择被解放或除外的龙族同调怪兽作为对象
function c77202120.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测自己场上是否有可用的怪兽区域空格，且是否存在可特殊召唤的对象
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c77202120.spfilter,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tg
	if #eg==1 then
		tg=eg:Clone()
	else
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tg=eg:FilterSelect(tp,c77202120.spfilter,1,1,nil,e,tp)
	end
	-- 将选中的卡片设置为当前连锁的效果对象
	Duel.SetTargetCard(tg)
	-- 设置特殊召唤该对象怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,0,0)
end
-- 效果②的效果处理（特殊召唤作为对象的怪兽）
function c77202120.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
