--変幻
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以以自己或对方的魔法与陷阱区域1张表侧表示的怪兽卡为对象，从以下效果选择1个发动。
-- ●作为对象的卡在原本持有者的场上特殊召唤。
-- ●作为对象的卡回到手卡。
-- ●作为对象的卡破坏。那之后，可以把持有那张卡的等级以下的等级的场上1只怪兽破坏。
local s,id,o=GetID()
-- 初始化函数：为“变幻”创建3个可选择的魔法发动效果（e1/e2/e3），分别对应特殊召唤、回手、破坏；三个效果均设为自由时点发动、取对象，并以id+EFFECT_COUNT_CODE_OATH作为共用的誓约次数限制，实现同名卡1回合1次。
function s.initial_effect(c)
	-- ●作为对象的卡在原本持有者的场上特殊召唤。
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
	-- ●作为对象的卡回到手卡。
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
	-- ●作为对象的卡破坏。那之后，可以把持有那张卡的等级以下的等级的场上1只怪兽破坏。
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
-- 定义“特殊召唤效果”的选对象过滤函数：只有在对象卡原本持有者场上存在可用的怪兽区、卡为表侧表示的怪兽卡且能被玩家tp以效果特殊召唤时才可选。
function s.spfilter(c,e,tp)
	-- 过滤条件逐项：原本持有者怪兽区有空位；卡的原类型包含怪兽；表侧表示；该卡可以被tp用本效果特殊召唤。
	return Duel.GetLocationCount(c:GetOwner(),LOCATION_MZONE)>0 and c:GetOriginalType()&TYPE_MONSTER>0 and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果1的发动时点处理函数：先处理连锁对象合法性，再检查是否存在满足条件的对象，存在则提示选择要特殊召唤的卡并选择1张，最后设置特殊召唤的操作信息。
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.spfilter(chkc,e,tp) end
	-- 若在发动时点（chk==0）不存在满足条件的表侧表示怪兽卡，则无法发动。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,tp) end
	-- 给出选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己或对方魔陷区1张满足spfilter的卡作为对象（取对象）。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁将特殊召唤这1张对象卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果1的解决处理函数：取出对象卡和其持有者，若对象仍与效果关联且持有者怪兽区有空位，则以表侧攻击表示特殊召唤到原本持有者场上。
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果1发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	local tgp=tc:GetOwner()
	-- 确认对象卡仍与效果关联（没有中途离场等），且原本持有者场上还有可用的怪兽区。
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tgp,LOCATION_MZONE)>0 then
		-- 将对象卡以表侧表示特殊召唤到其原本持有者的场上（召唤玩家为tp，sumtype=0，不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tgp,false,false,POS_FACEUP)
	end
end
-- 定义“回手效果”的选对象过滤函数：要求是表侧表示的怪兽卡且能够加入手卡。
function s.thfilter(c)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:IsAbleToHand() and c:IsFaceup()
end
-- 定义效果2的发动时点处理函数：检查是否存在可回手的对象，并选择1张魔陷区的表侧怪兽卡，设置回手卡的操作信息。
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.thfilter(chkc) end
	-- 若场上不存在满足回手条件的表侧怪兽卡，则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 给出选择提示：请选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己或对方魔陷区1张满足回手条件的卡作为对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 设置操作信息：本次连锁将处理这1张卡回手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果2的解决处理函数：若对象仍与效果关联，则以效果原因将其送回持有者手卡。
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果2发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 定义“破坏效果”的选对象过滤函数：要求是魔陷区的表侧表示怪兽卡。
function s.desfilter(c)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:IsFaceup()
end
-- 定义后续追加破坏的选卡过滤函数：要求是场上表侧表示且等级不高于对象卡当前等级的怪兽。
function s.desfilter2(c,tc)
	return c:IsFaceup() and c:IsLevelBelow(tc:GetLevel())
end
-- 定义效果3的发动时点处理函数：检查是否存在可破坏的表侧怪兽对象，选择1张并设置操作信息。
function s.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.desfilter(chkc) end
	-- 若场上不存在满足破坏条件的表侧表示怪兽卡，则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 给出选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己或对方魔陷区1张满足破坏条件的表侧怪兽卡作为对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 设置操作信息：将对象卡的效果处理分类标记为回手卡（数量1张；此处按破坏效果原意应为CATEGORY_DESTROY）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果3的解决处理函数：先破坏对象卡；若破坏成功且场上存在等级≤对象卡等级的怪兽，则询问是否追加破坏，选择1只并破坏。
function s.activate3(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果3发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 若对象卡因本效果被破坏，且场上存在等级不高于对象卡（破坏前）等级的表侧怪兽，则询问玩家是否追加破坏。
		if Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tc) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把场上的怪兽破坏？"
			-- 给出追加破坏时的选择提示：请选择要破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择场上1只满足“表侧表示且等级≤对象卡等级”的怪兽。
			local g=Duel.SelectMatchingCard(tp,s.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc)
			-- 将选择的怪兽以效果原因破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
