--クリアー・キューブ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，「清透世界」的效果对自己不适用。
-- ②：自己在通常召唤外加上只有1次，自己主要阶段可以把有「清透世界」的卡名记述的1只怪兽召唤。
-- ③：表侧表示的这张卡因对方从场上离开的场合才能发动。从卡组把有「清透世界」的卡名记述的1只怪兽特殊召唤。
local s,id,o=GetID()
-- 定义初始化函数：为「清透立方体」注册三个效果。①使「清透世界」的效果对自己不适用，②增加1次通常召唤次数且只能召唤有「清透世界」卡名记述的怪兽，③满足条件下从卡组特殊召唤有「清透世界」卡名记述的怪兽。
function s.initial_effect(c)
	-- 将「清透世界」（33900648）登记为这张卡的记载卡名，用于后续检索/判定“有「清透世界」的卡名记述的怪兽”。
	aux.AddCodeList(c,33900648)
	-- ①：只要这张卡在怪兽区域存在，「清透世界」的效果对自己不适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetCode(97811903)
	c:RegisterEffect(e1)
	-- ②：自己在通常召唤外加上只有1次，自己主要阶段可以把有「清透世界」的卡名记述的1只怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetTarget(s.suntg)
	c:RegisterEffect(e2)
	-- ③：表侧表示的这张卡因对方从场上离开的场合才能发动。从卡组把有「清透世界」的卡名记述的1只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 额外召唤效果的适用对象过滤函数：判定要召唤的怪兽是否为“有「清透世界」卡名记述的怪兽”。
function s.suntg(e,c)
	-- 检查目标怪兽c的效果文本上是否记载着「清透世界」的卡名，是则返回真，从而允许其通过②效果进行追加召唤。
	return aux.IsCodeListed(c,33900648)
end
-- ③效果的发动条件判定：这张卡此前存在于场上、表侧表示，且原本控制者为自己的这张卡因对方玩家而离场。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- ③效果的卡组检索过滤函数：筛选出有「清透世界」卡名记述且可以被特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	-- 目标怪兽必须同时满足：记载着「清透世界」卡名，且在当前状况下可以被效果特殊召唤（检查召唤条件与苏生限制）。
	return aux.IsCodeListed(c,33900648) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动时点处理：若满足条件则在卡组中检索可特殊召唤的目标，并向系统登记本次操作包含特殊召唤（从卡组特殊召唤1只）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查合法性：我方主要怪兽区有空位，且卡组中存在符合条件的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向决斗系统登记操作信息：本次效果将使我方从卡组特殊召唤1只怪兽，供后续效果检测（如星尘龙、王家长眠之谷等）使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果的处理：选择卡组中符合条件的1只怪兽，以表侧攻击表示特殊召唤到我的主要怪兽区；若处理时没有空位则直接结束。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认我方主要怪兽区仍有空位，若已被占用则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”，并附带特殊召唤的选择图标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选出1张满足s.spfilter条件（记载「清透世界」且可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的主要怪兽区（不附加特殊召唤方式，且正常检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
