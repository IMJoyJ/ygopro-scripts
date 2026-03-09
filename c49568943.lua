--VV－真羅万象
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，从卡组把「群豪世界-真罗万象」以外的1张「群豪」场地魔法卡在对方的场地区域表侧表示放置。
-- ②：场地区域有2张卡的场合，回合玩家以自身的魔法与陷阱区域1张怪兽卡为对象才能发动。那张卡在那个正对面的自身的主要怪兽区域特殊召唤。
function c49568943.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，从卡组把「群豪世界-真罗万象」以外的1张「群豪」场地魔法卡在对方的场地区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c49568943.target)
	e1:SetOperation(c49568943.activate)
	c:RegisterEffect(e1)
	-- ②：场地区域有2张卡的场合，回合玩家以自身的魔法与陷阱区域1张怪兽卡为对象才能发动。那张卡在那个正对面的自身的主要怪兽区域特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,49568943)
	e2:SetCondition(c49568943.spcon)
	e2:SetTarget(c49568943.sptg)
	e2:SetOperation(c49568943.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「群豪」场地魔法卡
function c49568943.setfilter(c,tp)
	return c:IsSetCard(0x17d) and not c:IsCode(49568943) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(1-tp)
end
-- 效果处理时的判断条件，检查是否能从卡组选择一张符合条件的场地魔法卡
function c49568943.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的卡组中是否存在至少1张满足setfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c49568943.setfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 发动效果时执行的操作，选择并放置一张符合条件的场地魔法卡到对方场地区域
function c49568943.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场地区的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择一张符合条件的场地魔法卡
	local tc=Duel.SelectMatchingCard(tp,c49568943.setfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取对方场地区域的旧场地魔法卡
		local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
		if fc then
			-- 将对方场地区的旧场地魔法卡送入墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使后续处理视为不同时进行
			Duel.BreakEffect()
		end
		-- 将选中的场地魔法卡移动到对方场地区域并正面表示
		Duel.MoveToField(tc,tp,1-tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
-- 判断场地区域是否有2张卡的条件函数
function c49568943.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场地区域是否正好有2张卡
	return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,LOCATION_FZONE)==2
end
-- 过滤函数，用于筛选可以特殊召唤的怪兽卡
function c49568943.spfilter(c,e,tp)
	local zone=1<<c:GetSequence()
	return c:IsFaceup() and c:GetSequence()<=4 and c:GetOriginalType()&TYPE_MONSTER~=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 设置特殊召唤效果的目标选择逻辑
function c49568943.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c49568943.spfilter(chkc,e,tp) end
	-- 检查是否存在满足特殊召唤条件的怪兽卡作为目标
	if chk==0 then return Duel.IsExistingTarget(c49568943.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一张符合条件的怪兽卡作为特殊召唤的目标
	local g=Duel.SelectTarget(tp,c49568943.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的效果处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤效果的操作函数
function c49568943.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被指定的目标卡
	local tc=Duel.GetFirstTarget()
	local zone=1<<tc:GetSequence()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以特定方式特殊召唤到己方主要怪兽区域
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
