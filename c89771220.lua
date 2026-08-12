--天斗輝巧極
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从自己的手卡·场上把「北极天熊北斗星」和「龙辉巧-扶筐增二」各1张除外，把1只「天极辉舰-熊斗龙巧」从额外卡组特殊召唤。场上有「北极天熊-勾陈一」或者「龙辉巧-右枢α」存在的场合，也能把要除外的卡之内1张从卡组除外。
-- ②：自己为让「北极天熊」、「龙辉巧」怪兽的效果发动而把怪兽解放的场合，可以作为代替把墓地的这张卡除外。
function c89771220.initial_effect(c)
	-- 注册卡片关联密码（北极天熊北斗星、龙辉巧-扶筐增二、北极天熊-勾陈一、龙辉巧-右枢α）
	aux.AddCodeList(c,89264428,58793369,97148796,27693363)
	-- ①：从自己的手卡·场上把「北极天熊北斗星」和「龙辉巧-扶筐增二」各1张除外，把1只「天极辉舰-熊斗龙巧」从额外卡组特殊召唤。场上有「北极天熊-勾陈一」或者「龙辉巧-右枢α」存在的场合，也能把要除外的卡之内1张从卡组除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c89771220.target)
	e1:SetOperation(c89771220.activate)
	c:RegisterEffect(e1)
	-- ②：自己为让「北极天熊」、「龙辉巧」怪兽的效果发动而把怪兽解放的场合，可以作为代替把墓地的这张卡除外。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(89771220)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,89771220)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(16471775)
	c:RegisterEffect(e3)
end
-- 过滤场上是否存在「北极天熊-勾陈一」或「龙辉巧-右枢α」的条件函数
function c89771220.deckconfilter(c)
	return c:IsCode(97148796,27693363) and c:IsFaceup()
end
-- 检查场上是否存在「北极天熊-勾陈一」或「龙辉巧-右枢α」的函数
function c89771220.deckcon(tp)
	-- 检查双方场上是否存在满足条件的怪兽
	return Duel.IsExistingMatchingCard(c89771220.deckconfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 过滤手卡·场上·卡组中可以被除外的「北极天熊北斗星」或「龙辉巧-扶筐增二」
function c89771220.cfilter(c)
	return c:IsCode(89264428,58793369) and c:IsAbleToRemove()
end
-- 检查选取的卡片组是否包含2种不同的卡，且从卡组选取的卡不超过1张，并且能特殊召唤额外卡组的怪兽
function c89771220.fselect(g,e,tp)
	return g:GetClassCount(Card.GetCode)==2 and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
		-- 检查额外卡组是否存在可以特殊召唤的「天极辉舰-熊斗龙巧」
		and Duel.IsExistingMatchingCard(c89771220.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end
-- 过滤额外卡组中可以特殊召唤的「天极辉舰-熊斗龙巧」
function c89771220.spfilter(c,e,tp,g)
	return c:IsCode(33250142) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
		-- 检查在将选定的除外卡送去墓地/除外后，额外怪兽区域是否有可用的空位
		and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
-- 效果①的发动准备与合法性检查函数
function c89771220.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_HAND+LOCATION_ONFIELD
	if c89771220.deckcon(tp) then loc=loc|LOCATION_DECK end
	-- 获取当前可用区域内所有满足除外条件的卡片组
	local g=Duel.GetMatchingGroup(c89771220.cfilter,tp,loc,0,nil)
	if chk==0 then return g:CheckSubGroup(c89771220.fselect,2,2,e,tp) end
	-- 设置连锁信息：从手卡、场上或卡组除外2张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK)
	-- 设置连锁信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的处理函数
function c89771220.activate(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_HAND+LOCATION_ONFIELD
	if c89771220.deckcon(tp) then loc=loc|LOCATION_DECK end
	-- 获取当前可用区域内所有满足除外条件的卡片组
	local g=Duel.GetMatchingGroup(c89771220.cfilter,tp,loc,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectSubGroup(tp,c89771220.fselect,false,2,2,e,tp)
	-- 选出2张卡并将其表侧表示除外，若除外成功则继续处理
	if rg and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足特殊召唤条件的「天极辉舰-熊斗龙巧」
		local sg=Duel.SelectMatchingCard(tp,c89771220.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
		if #sg>0 then
			-- 将选定的怪兽无视苏生限制表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,true,POS_FACEUP)
			sg:GetFirst():CompleteProcedure()
		end
	end
end
