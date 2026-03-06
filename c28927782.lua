--ドラグニティ・ドライブ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。这个回合，自己不是「龙骑兵团」怪兽不能特殊召唤。
-- ●以自己的魔法与陷阱区域1张「龙骑兵团」怪兽卡为对象才能发动。那张卡守备表示特殊召唤。
-- ●以自己场上1只「龙骑兵团」怪兽为对象才能发动。从自己墓地选1只「龙骑兵团」怪兽当作装备卡使用给作为对象的自己怪兽装备。
function c28927782.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：可以从以下效果选择1个发动。这个回合，自己不是「龙骑兵团」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,28927782)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c28927782.eftg)
	e2:SetOperation(c28927782.efop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检查场上是否存在满足条件的「龙骑兵团」怪兽。
function c28927782.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x29) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数，用于检查场上是否存在满足条件的「龙骑兵团」怪兽。
function c28927782.eqfilter1(c,tp)
	-- 检查场上是否存在满足条件的「龙骑兵团」怪兽。
	return c:IsFaceup() and c:IsSetCard(0x29) and Duel.IsExistingMatchingCard(c28927782.eqfilter2,tp,LOCATION_GRAVE,0,1,nil,c,tp)
end
-- 过滤函数，用于检查墓地是否存在满足条件的「龙骑兵团」怪兽。
function c28927782.eqfilter2(c,tc,tp)
	return c:IsSetCard(0x29) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 判断当前是否为选择对象阶段，若为0则选择魔法与陷阱区域的「龙骑兵团」怪兽，否则选择场上的「龙骑兵团」怪兽。
function c28927782.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c28927782.spfilter(chkc,e,tp)
		else return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28927782.eqfilter1(chkc,tp) end
	end
	-- 判断是否满足第一个效果的发动条件：魔法与陷阱区域是否存在「龙骑兵团」怪兽可特殊召唤。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c28927782.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp)
	-- 判断是否满足第二个效果的发动条件：场地上是否存在「龙骑兵团」怪兽可装备。
	local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(c28927782.eqfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 让玩家选择发动效果的选项，选项为“特殊召唤”或“装备”。
		op=Duel.SelectOption(tp,aux.Stringid(28927782,1),aux.Stringid(28927782,2))  --"特殊召唤/装备"
	elseif b1 then
		-- 让玩家选择发动效果的选项，选项为“特殊召唤”。
		op=Duel.SelectOption(tp,aux.Stringid(28927782,1))  --"特殊召唤"
	-- 让玩家选择发动效果的选项，选项为“装备”。
	else op=Duel.SelectOption(tp,aux.Stringid(28927782,2))+1 end  --"装备"
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的魔法与陷阱区域的「龙骑兵团」怪兽作为对象。
		local g=Duel.SelectTarget(tp,c28927782.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
		-- 设置操作信息，表示将特殊召唤一张卡。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(0)
		-- 提示玩家选择表侧表示的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择满足条件的场上的「龙骑兵团」怪兽作为对象。
		Duel.SelectTarget(tp,c28927782.eqfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
		-- 设置操作信息，表示将从墓地取出一张卡。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
	end
end
-- 效果处理函数，根据选择的选项执行不同的效果。
function c28927782.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		-- 获取当前连锁中选择的第一个目标卡。
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 将目标卡以守备表示特殊召唤到场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	else
		-- 检查场上是否有足够的装备区域。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 获取当前连锁中选择的第一个目标卡。
		local ec=Duel.GetFirstTarget()
		if ec:IsRelateToEffect(e) and ec:IsFaceup() then
			-- 提示玩家选择要装备的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 从墓地中选择满足条件的「龙骑兵团」怪兽作为装备卡。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28927782.eqfilter2),tp,LOCATION_GRAVE,0,1,1,nil,ec,tp)
			local tc=g:GetFirst()
			-- 将选中的卡装备给目标怪兽。
			if not tc or not Duel.Equip(tp,tc,ec) then return end
			-- 设置装备限制效果，确保装备卡只能装备给特定怪兽。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c28927782.eqlimit2)
			e1:SetLabelObject(ec)
			tc:RegisterEffect(e1)
		end
	end
	-- 设置永续效果，使本回合内自己不能特殊召唤非「龙骑兵团」怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c28927782.splimit)
	-- 将效果注册到游戏环境中。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标，使非「龙骑兵团」怪兽不能特殊召唤。
function c28927782.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x29)
end
-- 装备限制函数，确保装备卡只能装备给特定怪兽。
function c28927782.eqlimit2(e,c)
	return c==e:GetLabelObject()
end
