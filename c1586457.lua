--ディープ・スペース・クルーザー・ナイン
-- 效果：
-- 这张卡可以从手卡把这张卡以外的1只机械族怪兽送去墓地，从手卡特殊召唤。
function c1586457.initial_effect(c)
	-- 这张卡可以从手卡把这张卡以外的1只机械族怪兽送去墓地，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1586457.spcon)
	e1:SetTarget(c1586457.sptg)
	e1:SetOperation(c1586457.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：判定卡片是否为机械族怪兽，且可以作为代价从手卡送去墓地。
function c1586457.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤规则的条件：若c为空则视为满足条件；否则需我方主要怪兽区有空位，且手牌中存在这张卡以外的符合条件的机械族怪兽作为代价。
function c1586457.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查我方主要怪兽区是否存在可用的空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在这张卡以外的、满足代价条件的机械族怪兽。
		and Duel.IsExistingMatchingCard(c1586457.filter,tp,LOCATION_HAND,0,1,c)
end
-- 特殊召唤规则的目标选择：从手牌符合条件的机械族怪兽中选择1张作为送墓代价，并将选择结果存入LabelObject。
function c1586457.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得手牌中所有满足条件（机械族且可作为代价送墓）且不是这张卡本身的怪兽集合。
	local g=Duel.GetMatchingGroup(c1586457.filter,tp,LOCATION_HAND,0,c)
	-- 向玩家发送选择提示，要求选择一张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的处理：取出之前选择作为代价的怪兽，将其送入墓地以进行特殊召唤。
function c1586457.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽送入墓地，作为这张卡从手卡特殊召唤的代价。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
