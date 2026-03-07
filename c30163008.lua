--羅天神将
-- 效果：
-- 相同种族的怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己·对方的准备阶段，以这张卡所连接区1只表侧表示怪兽为对象才能发动。种族和那只怪兽相同的1只4星以下的怪兽从手卡往作为这张卡所连接区的自己场上特殊召唤。
-- ②：自己·对方的战斗阶段开始时，以对方场上1张卡为对象才能发动。那张卡破坏。
function c30163008.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求连接区必须有至少2只怪兽且种族相同
	aux.AddLinkProcedure(c,nil,2,nil,c30163008.lcheck)
	-- ①：自己·对方的准备阶段，以这张卡所连接区1只表侧表示怪兽为对象才能发动。种族和那只怪兽相同的1只4星以下的怪兽从手卡往作为这张卡所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c30163008.target)
	e1:SetOperation(c30163008.operation)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段开始时，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,30163008)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c30163008.destg)
	e2:SetOperation(c30163008.desop)
	c:RegisterEffect(e2)
end
-- 连接召唤时检查连接区怪兽种族是否全部相同
function c30163008.lcheck(g)
	-- 检查连接区怪兽种族是否全部相同
	return aux.SameValueCheck(g,Card.GetLinkRace)
end
-- 过滤函数，用于判断目标怪兽是否满足连接区条件并手卡存在符合条件的怪兽
function c30163008.cfilter(c,e,tp,lg,zone)
	return c:IsFaceup() and lg:IsContains(c)
		-- 检查手卡是否存在种族与目标怪兽相同且等级不超过4的怪兽
		and Duel.IsExistingMatchingCard(c30163008.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetRace(),zone)
end
-- 过滤函数，用于判断目标怪兽是否满足连接区条件且种族与指定种族一致
function c30163008.chkfilter(c,e,tp,lg,rc)
	return c:IsFaceup() and lg:IsContains(c) and c:GetRace()&rc==rc
end
-- 过滤函数，用于判断手卡怪兽是否满足等级不超过4且种族与指定种族一致
function c30163008.spfilter(c,e,tp,rac,zone)
	return c:IsLevelBelow(4) and c:IsRace(rac) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果处理时判断是否满足发动条件，包括是否有足够的召唤区域和符合条件的目标怪兽
function c30163008.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local zone=c:GetLinkedZone(tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c30163008.chkfilter(chkc,e,tp,lg,e:GetLabel()) end
	-- 判断目标怪兽所在区域是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		-- 判断是否存在符合条件的目标怪兽
		and Duel.IsExistingTarget(c30163008.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp,lg,zone) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的目标怪兽
	local g=Duel.SelectTarget(tp,c30163008.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp,lg,zone)
	-- 设置效果操作信息，表示将特殊召唤1只手卡怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	e:SetLabel(g:GetFirst():GetRace())
end
-- 效果处理函数，选择并特殊召唤符合条件的怪兽
function c30163008.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local zone=c:GetLinkedZone(tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择符合条件的怪兽
	local sc=Duel.SelectMatchingCard(tp,c30163008.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetRace(),zone):GetFirst()
	if sc then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 破坏效果处理函数，选择并破坏对方场上的卡
function c30163008.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 判断对方场上是否存在可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，表示将破坏1张对方场上的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，对目标卡进行破坏
function c30163008.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
