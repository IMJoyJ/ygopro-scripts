--トゥーン・マスク
-- 效果：
-- ①：自己场上有「卡通世界」存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。把持有那只怪兽的等级或者阶级的数值以下的等级的1只卡通怪兽无视召唤条件从手卡·卡组特殊召唤。
function c79447365.initial_effect(c)
	-- 注册卡片关联密码，表示本卡记载了「卡通世界」的卡名
	aux.AddCodeList(c,15259703)
	-- ①：自己场上有「卡通世界」存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。把持有那只怪兽的等级或者阶级的数值以下的等级的1只卡通怪兽无视召唤条件从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c79447365.condition)
	e1:SetTarget(c79447365.target)
	e1:SetOperation(c79447365.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「卡通世界」
function c79447365.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 发动条件：自己场上有表侧表示的「卡通世界」存在
function c79447365.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(c79447365.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：对方场上表侧表示的怪兽，且其等级或阶级以下等级的卡通怪兽存在于手卡或卡组中
function c79447365.filter(c,e,tp)
	local lv=0
	if c:IsType(TYPE_XYZ) then
		lv=c:GetRank()
	else
		lv=c:GetLevel()
	end
	-- 判断怪兽是否表侧表示，且手卡或卡组中是否存在满足特殊召唤条件的卡通怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c79447365.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,lv)
end
-- 过滤条件：等级在指定数值以下、属于卡通怪兽、且可以无视召唤条件特殊召唤
function c79447365.spfilter(c,e,tp,lv)
	return c:IsLevelBelow(lv) and c:IsType(TYPE_TOON) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果发动时的目标选择与合法性检测
function c79447365.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c79447365.filter(chkc,e,tp) end
	-- 在发动效果时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且对方场上存在至少1只满足条件的表侧表示怪兽作为对象
		and Duel.IsExistingTarget(c79447365.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择要作为效果对象的目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c79447365.filter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理的执行函数
function c79447365.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local lv=0
	if tc:IsType(TYPE_XYZ) then
		lv=tc:GetRank()
	else
		lv=tc:GetLevel()
	end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组选择1只等级在对象怪兽等级或阶级以下、且满足条件的卡通怪兽
	local g=Duel.SelectMatchingCard(tp,c79447365.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,lv)
	if g:GetCount()>0 then
		-- 将选择的卡通怪兽无视召唤条件以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
