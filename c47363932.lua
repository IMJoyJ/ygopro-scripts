--スクラップ・ワイバーン
-- 效果：
-- 包含「废铁」怪兽的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「废铁」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，选自己场上1张卡破坏。
-- ②：这张卡已在怪兽区域存在的状态，场上的表侧表示的「废铁」怪兽被效果破坏的场合才能发动。从卡组把1只「废铁」怪兽特殊召唤。那之后，选场上1张卡破坏。
function c47363932.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2个满足条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,2,c47363932.lcheck)
	c:EnableReviveLimit()
	-- ①：以自己墓地1只「废铁」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，选自己场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47363932,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,47363932)
	e1:SetTarget(c47363932.sptg1)
	e1:SetOperation(c47363932.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，场上的表侧表示的「废铁」怪兽被效果破坏的场合才能发动。从卡组把1只「废铁」怪兽特殊召唤。那之后，选场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47363932,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,47363933)
	e2:SetCondition(c47363932.spcon2)
	e2:SetTarget(c47363932.sptg2)
	e2:SetOperation(c47363932.spop2)
	c:RegisterEffect(e2)
end
-- 连接素材必须包含「废铁」怪兽
function c47363932.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x24)
end
-- 过滤满足条件的「废铁」怪兽
function c47363932.spfilter(c,e,tp)
	return c:IsSetCard(0x24) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标为己方墓地的「废铁」怪兽
function c47363932.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47363932.spfilter(chkc,e,tp) end
	-- 检查己方场上是否有特殊召唤怪兽的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方墓地是否存在满足条件的「废铁」怪兽
		and Duel.IsExistingTarget(c47363932.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽并设置为效果对象
	local g1=Duel.SelectTarget(tp,c47363932.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 获取己方场上的所有卡作为破坏对象
	local g2=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	-- 设置操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
	-- 设置操作信息：破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end
-- 处理效果的发动和执行
function c47363932.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效并进行特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上一张卡作为破坏对象
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前连锁效果处理
			Duel.BreakEffect()
			-- 显示选中卡被选为对象的动画
			Duel.HintSelection(g)
			-- 将选中的卡破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 过滤被效果破坏且满足条件的「废铁」怪兽
function c47363932.cfilter(c)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousSetCard(0x24) and c:IsPreviousPosition(POS_FACEUP)
end
-- 判断是否满足效果发动条件
function c47363932.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47363932.cfilter,1,nil)
end
-- 设置效果目标为卡组中的「废铁」怪兽
function c47363932.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有特殊召唤怪兽的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方卡组是否存在满足条件的「废铁」怪兽
		and Duel.IsExistingMatchingCard(c47363932.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 获取双方场上的所有卡作为破坏对象
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果的发动和执行
function c47363932.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有特殊召唤怪兽的空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一只「废铁」怪兽
	local g1=Duel.SelectMatchingCard(tp,c47363932.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 判断是否成功特殊召唤并继续处理
	if g1:GetCount()>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上一张卡作为破坏对象
		local g2=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g2:GetCount()>0 then
			-- 中断当前连锁效果处理
			Duel.BreakEffect()
			-- 显示选中卡被选为对象的动画
			Duel.HintSelection(g2)
			-- 将选中的卡破坏
			Duel.Destroy(g2,REASON_EFFECT)
		end
	end
end
