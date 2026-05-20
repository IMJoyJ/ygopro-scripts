--真の光
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●从自己的手卡·墓地把1只「青眼白龙」特殊召唤。
-- ●同名卡不在自己的场上·墓地存在的1张有「青眼白龙」的卡名记述的魔法·陷阱卡从卡组到自己场上盖放。
-- ②：对方不能把自己的怪兽区域的「青眼白龙」作为效果的对象。
-- ③：魔法与陷阱区域的表侧表示的这张卡被送去墓地的场合发动。自己场上的怪兽全部破坏。
function c62089826.initial_effect(c)
	-- 注册卡片效果中记载了「青眼白龙」的卡片密码
	aux.AddCodeList(c,89631139)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：可以从以下效果选择1个发动。●从自己的手卡·墓地把1只「青眼白龙」特殊召唤。●同名卡不在自己的场上·墓地存在的1张有「青眼白龙」的卡名记述的魔法·陷阱卡从卡组到自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62089826,0))  --"选择效果发动"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,62089826)
	e2:SetTarget(c62089826.target)
	e2:SetOperation(c62089826.operation)
	c:RegisterEffect(e2)
	-- ②：对方不能把自己的怪兽区域的「青眼白龙」作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为卡名是「青眼白龙」的怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsCode,89631139))
	-- 设置不能成为对方卡片效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：魔法与陷阱区域的表侧表示的这张卡被送去墓地的场合发动。自己场上的怪兽全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(62089826,3))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c62089826.descon)
	e4:SetTarget(c62089826.destg)
	e4:SetOperation(c62089826.desop)
	c:RegisterEffect(e4)
end
-- 过滤场上表侧表示或墓地中存在指定卡名的卡片
function c62089826.cfilter(c,code)
	return c:IsCode(code) and (c:IsFaceup() or not c:IsOnField())
end
-- 过滤手卡·墓地中可以特殊召唤的「青眼白龙」
function c62089826.filter1(c,e,tp)
	return c:IsCode(89631139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤卡组中可以盖放且同名卡不在自己场上·墓地存在的记述有「青眼白龙」卡名的魔法·陷阱卡
function c62089826.filter2(c,tp)
	-- 检查卡片是否为记述有「青眼白龙」卡名且可以盖放的魔法·陷阱卡
	return aux.IsCodeListed(c,89631139) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
		-- 检查自己的场上·墓地是否不存在该卡片的同名卡
		and not Duel.IsExistingMatchingCard(c62089826.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- ①效果的发动准备，检测并让玩家选择发动“特殊召唤”或“盖放魔陷”效果，并设置对应的操作信息
function c62089826.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·墓地是否存在可以特殊召唤的「青眼白龙」
		and Duel.IsExistingMatchingCard(c62089826.filter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查卡组中是否存在满足条件的可以盖放的魔法·陷阱卡
	local b2=Duel.IsExistingMatchingCard(c62089826.filter2,tp,LOCATION_DECK,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个效果都满足时，让玩家选择其中一个效果发动
		op=Duel.SelectOption(tp,aux.Stringid(62089826,1),aux.Stringid(62089826,2))  --"特殊召唤/放置魔陷"
	elseif b1 then
		-- 仅满足特殊召唤条件时，玩家只能选择特殊召唤效果
		op=Duel.SelectOption(tp,aux.Stringid(62089826,1))  --"特殊召唤"
	else
		-- 仅满足盖放魔陷条件时，玩家只能选择盖放魔陷效果并调整选项索引
		op=Duel.SelectOption(tp,aux.Stringid(62089826,2))+1  --"放置魔陷"
	end
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置特殊召唤的操作信息，准备从手卡·墓地特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_SSET)
	end
	e:SetLabel(op)
end
-- ①效果的实际处理，根据玩家的选择执行「青眼白龙」的特殊召唤或魔法·陷阱卡的盖放
function c62089826.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 检查自己场上是否有空余的怪兽区域，若无则无法特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡·墓地选择1只满足条件的「青眼白龙」（受「王家之谷」影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c62089826.filter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 提示玩家选择要盖放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 让玩家从卡组选择1张满足条件的魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c62089826.filter2,tp,LOCATION_DECK,0,1,1,nil,tp)
		if g:GetCount()>0 then
			-- 将选中的魔法·陷阱卡在自己场上盖放
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- ③效果的发动条件：魔法与陷阱区域表侧表示的这张卡被送去墓地
function c62089826.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousSequence()<5
end
-- ③效果的发动准备，获取自己场上的所有怪兽并设置破坏的操作信息
function c62089826.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上所有的怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 设置破坏自己场上全部怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- ③效果的实际处理，破坏自己场上的全部怪兽
function c62089826.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上所有的怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if #g>0 then
		-- 因效果将获取到的自己场上的怪兽全部破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
