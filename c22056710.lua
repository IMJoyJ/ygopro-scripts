--ヴァンパイアジェネシス
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的1只「吸血鬼领主」从游戏中除外的场合才能特殊召唤。1回合1次，可以通过从手卡把1只不死族怪兽丢弃去墓地，从自己墓地选择1只比丢弃的不死族怪兽等级低的不死族怪兽特殊召唤。
function c22056710.initial_effect(c)
	-- 将卡号53839837（吸血鬼领主）登记为这张卡的效果外文本记载的卡名，使这张卡相关判定能识别吸血鬼领主。
	aux.AddCodeList(c,53839837)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上存在的1只「吸血鬼领主」从游戏中除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c22056710.hspcon)
	e2:SetTarget(c22056710.hsptg)
	e2:SetOperation(c22056710.hspop)
	c:RegisterEffect(e2)
	-- 1回合1次，可以通过从手卡把1只不死族怪兽丢弃去墓地，从自己墓地选择1只比丢弃的不死族怪兽等级低的不死族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22056710,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c22056710.sptg)
	e3:SetOperation(c22056710.spop)
	c:RegisterEffect(e3)
end
-- 定义特殊召唤手续的过滤器：判断己方场上是否存在卡名是「吸血鬼领主」、可以作为代价除外，且除外后己方仍有可用怪兽区的卡。
function c22056710.hspfilter(c,tp)
	-- 被选择卡需同时满足：卡名是「吸血鬼领主」、可以作为代价除外、且该卡离开后己方主怪兽区仍有空位。
	return c:IsCode(53839837) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 定义规则特殊召唤的发动条件：空值视为满足；否则检查该卡控制者的场上是否存在符合hspfilter的可除外「吸血鬼领主」。
function c22056710.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前控制者场上是否存在至少1张满足hspfilter条件的「吸血鬼领主」。
	return Duel.IsExistingMatchingCard(c22056710.hspfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 定义特殊召唤手续的选择阶段：从己方场上所有满足条件的「吸血鬼领主」中选择1张要除外的卡，并将其记录到效果LabelObject中。
function c22056710.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取己方场上所有满足hspfilter条件的「吸血鬼领主」作为候选集合。
	local g=Duel.GetMatchingGroup(c22056710.hspfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 向玩家发出“请选择要除外的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义特殊召唤手续的除外操作：取得之前选择记录的卡，将其正面表示除外以完成特殊召唤代价。
function c22056710.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的「吸血鬼领主」以表侧表示除外，作为这次特殊召唤的代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 定义手牌丢弃代价的过滤器：判断手牌中是否有不死族怪兽可以丢弃，并且丢进墓地后，墓地中存在等级低于该怪兽的不死族怪兽可以特殊召唤。
function c22056710.cfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsDiscardable()
		-- 进一步确认丢弃该手牌后，墓地存在至少1只等级低于丢弃怪兽等级、能被特殊召唤的不死族怪兽作为目标。
		and Duel.IsExistingTarget(c22056710.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetOriginalLevel())
end
-- 定义墓地特殊召唤目标的过滤器：目标需是不死族、等级大于0且低于丢弃怪兽的原始等级，并且满足特殊召唤条件及苏生限制。
function c22056710.spfilter(c,e,tp,lv)
	local clv=c:GetLevel()
	return clv>0 and clv<lv and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义起动效果的目标阶段：效果发动前需确认己方主怪兽区有空位，且手牌中存在可作为代价丢弃的不死族怪兽；发动后选择丢弃怪兽，再选择墓地中的特殊召唤对象。
function c22056710.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动时检查己方主怪兽区是否存在空位，若没有空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手牌中是否有满足cfilter条件（可丢弃且墓地有可特殊召唤对象）的不死族怪兽，否则不能发动。
		and Duel.IsExistingMatchingCard(c22056710.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向玩家发出“请选择要丢弃的手牌”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌中选择1只满足cfilter条件的不死族怪兽作为这次效果的代价。
	local g1=Duel.SelectMatchingCard(tp,c22056710.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的手牌不死族怪兽送去墓地，作为效果的代价（丢弃处理）。
	Duel.SendtoGrave(g1,REASON_COST+REASON_DISCARD)
	-- 向玩家发出“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足spfilter条件（不死族且等级低于丢弃怪兽）的不死族怪兽作为特殊召唤的对象。
	local g2=Duel.SelectTarget(tp,c22056710.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,g1:GetFirst():GetOriginalLevel())
	-- 设置当前连锁的操作信息：本次效果将进行特殊召唤，对象为已选择的墓地怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
-- 定义效果处理阶段：取得连锁对象，若其仍然与效果相关且是不死族怪兽，则将其特殊召唤到自己场上。
function c22056710.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的墓地特殊召唤对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_ZOMBIE) then
		-- 将目标不死族怪兽以表侧表示特殊召唤到自己场上，不检查召唤条件但保留苏生限制，表示形式为正面守备或攻击（默认正面表示）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
