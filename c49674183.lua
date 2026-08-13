--魔天使ローズ・ソーサラー
-- 效果：
-- 这张卡可以让「魔天使 蔷薇之巫师」以外的自己场上表侧表示存在的1只植物族怪兽回到手卡，从手卡特殊召唤。这个方法特殊召唤的这张卡从场上离开的场合从游戏中除外。
function c49674183.initial_effect(c)
	-- 这张卡可以让「魔天使 蔷薇之巫师」以外的自己场上表侧表示存在的1只植物族怪兽回到手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c49674183.spcon)
	e1:SetTarget(c49674183.sptg)
	e1:SetOperation(c49674183.spop)
	c:RegisterEffect(e1)
end
-- 过滤出符合条件的植物族怪兽：表侧表示、植物族、不是「魔天使 蔷薇之巫师」自身、可以作为cost返回手卡，且将其返回后我方场上仍有可用的怪兽区空格。
function c49674183.spfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and not c:IsCode(49674183) and c:IsAbleToHandAsCost()
		-- 确认将该怪兽返回手卡后，玩家tp的场上仍有至少1个可用怪兽区空格，以满足从手卡特殊召唤此卡所需的空位。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则效果的发动条件：若c为空则允许进行规则召唤的询问；若c存在，则检查自己场上是否存在至少1张满足spfilter的植物族怪兽。
function c49674183.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1张满足spfilter条件的表侧表示植物族怪兽（「魔天使 蔷薇之巫师」以外且可作为cost返回手卡）。
	return Duel.IsExistingMatchingCard(c49674183.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤规则效果的目标选择处理：从我方表侧表示植物族怪兽中选出1张作为返回手卡的cost，将其记录到效果e的LabelObject；选择成功返回true，否则返回false。
function c49674183.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得我方场上所有满足spfilter条件的卡，作为可选择返回手卡的候选集合。
	local g=Duel.GetMatchingGroup(c49674183.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 向玩家tp发出选择提示，提示信息为“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则效果的处理：将之前选择的植物族怪兽返回手卡，完成特殊召唤的手续，并给这张卡赋予“用这个方法特殊召唤的这张卡从场上离开的场合从游戏中除外”的效果。
function c49674183.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的植物族怪兽返回持有者手卡，这是该卡从手卡特殊召唤所需的cost/手续。
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
	-- 这个方法特殊召唤的这张卡从场上离开的场合从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1,true)
end
