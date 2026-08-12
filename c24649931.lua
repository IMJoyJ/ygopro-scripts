--変幻
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以以自己或对方的魔法与陷阱区域1张表侧表示的怪兽卡为对象，从以下效果选择1个发动。
-- ●作为对象的卡在原本持有者的场上特殊召唤。
-- ●作为对象的卡回到手卡。
-- ●作为对象的卡破坏。那之后，可以把持有那张卡的等级以下的等级的场上1只怪兽破坏。
local s,id,o=GetID()
-- 创建三个效果，分别对应三种发动选项：特殊召唤、返回手牌、破坏并额外破坏一个怪兽
function s.initial_effect(c)
	-- 作为对象的卡在原本持有者的场上特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"作为对象的卡在原本持有者的场上特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)
	-- 作为对象的卡回到手卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"作为对象的卡回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
	-- 作为对象的卡破坏
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"作为对象的卡破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetTarget(s.target3)
	e3:SetOperation(s.activate3)
	c:RegisterEffect(e3)
end
-- 特殊召唤的过滤函数，检查目标是否满足特殊召唤条件
function s.spfilter(c,e,tp)
	-- 目标卡必须是怪兽卡且可以特殊召唤
	return Duel.GetLocationCount(c:GetOwner(),LOCATION_MZONE)>0 and c:GetOriginalType()&TYPE_MONSTER>0 and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置第一个效果的目标选择函数，选择魔法与陷阱区域的怪兽卡
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.spfilter(chkc,e,tp) end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 第一个效果的发动处理函数，执行特殊召唤
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	local tgp=tc:GetOwner()
	-- 检查目标卡是否有效且场上存在召唤空间
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tgp,LOCATION_MZONE)>0 then
		-- 将目标卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tgp,false,false,POS_FACEUP)
	end
end
-- 返回手牌的过滤函数，检查目标是否可以返回手牌
function s.thfilter(c)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:IsAbleToHand() and c:IsFaceup()
end
-- 设置第二个效果的目标选择函数，选择魔法与陷阱区域的怪兽卡
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.thfilter(chkc) end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 设置操作信息，确定返回手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 第二个效果的发动处理函数，执行返回手牌
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 破坏效果的过滤函数，检查目标是否为表侧表示的怪兽
function s.desfilter(c)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:IsFaceup()
end
-- 破坏后额外破坏的过滤函数，检查目标等级是否小于等于被破坏卡的等级
function s.desfilter2(c,tc)
	return c:IsFaceup() and c:IsLevelBelow(tc:GetLevel())
end
-- 设置第三个效果的目标选择函数，选择魔法与陷阱区域的怪兽卡
function s.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.desfilter(chkc) end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 设置操作信息，确定破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 第三个效果的发动处理函数，执行破坏并可能额外破坏一个怪兽
function s.activate3(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 检查目标卡是否被破坏且场上存在满足等级条件的怪兽，且玩家选择继续破坏
		if Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tc) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把场上的怪兽破坏？"
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择满足等级条件的怪兽
			local g=Duel.SelectMatchingCard(tp,s.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc)
			-- 将选中的怪兽破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
