--大天使ゼラート
-- 效果：
-- 这张卡不能进行通常召唤。这张卡仅当场上存在「天空的圣域」时，祭掉自己场上1只以表侧表示存在的「杰拉的战士」才能特殊召唤。从手卡将1张光属性怪兽卡弃到墓地，破坏对方场上存在的所有怪兽。此效果仅当自己场上存在「天空的圣域」时才适用。
function c18378582.initial_effect(c)
	-- 记录这张卡的效果外文本中记载着「天空的圣域」（卡号56433456），用于后续环境判定中识别该卡名。
	aux.AddCodeList(c,56433456)
	c:EnableReviveLimit()
	-- 这张卡不能进行通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡仅当场上存在「天空的圣域」时，祭掉自己场上1只以表侧表示存在的「杰拉的战士」才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c18378582.spcon)
	e2:SetTarget(c18378582.sptg)
	e2:SetOperation(c18378582.spop)
	c:RegisterEffect(e2)
	-- 从手卡将1张光属性怪兽卡弃到墓地，破坏对方场上存在的所有怪兽。此效果仅当自己场上存在「天空的圣域」时才适用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18378582,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c18378582.descost)
	e3:SetTarget(c18378582.destg)
	e3:SetOperation(c18378582.desop)
	c:RegisterEffect(e3)
end
-- 定义特殊召唤素材的筛选函数：候选卡必须满足表侧表示、卡名为「杰拉的战士」（66073051），且解放后召唤者场上仍有可用怪兽区域。
function c18378582.rfilter(c,tp)
	-- 判断候选怪兽是否为表侧表示的「杰拉的战士」，并确认解放后场上仍有空位可以放置要特殊召唤的大天使杰拉特。
	return c:IsFaceup() and c:IsCode(66073051) and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤手续的发动条件：当c为nil时只需场上存在「天空的圣域」；否则检查玩家场上是否有至少1只可解放的「杰拉的战士」作为素材。
function c18378582.spcon(e,c)
	-- 当调用参数c为nil（表示仅判断能否发动特殊召唤手续）时，只需确认场上存在「天空的圣域」（卡号56433456）。
	if c==nil then return Duel.IsEnvironment(56433456) end
	-- 检查当前玩家是否存在至少1只可解放且满足rfilter的「杰拉的战士」，并以此作为特殊召唤的素材。
	return Duel.CheckReleaseGroupEx(c:GetControler(),c18378582.rfilter,1,REASON_SPSUMMON,false,nil,c:GetControler())
end
-- 特殊召唤手续的目标选择处理：从可解放的卡中筛选出符合条件的「杰拉的战士」，由玩家选择1张，并记录到效果LabelObject中；未选择则返回false。
function c18378582.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家可解放的卡组，并用rfilter筛出所有可作为特殊召唤素材的表侧表示「杰拉的战士」。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c18378582.rfilter,nil,tp)
	-- 向玩家显示选择提示，要求其选择要解放的卡（HINTMSG_RELEASE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的实际处理：取出之前选择的素材卡并将其解放，以完成特殊召唤。
function c18378582.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的「杰拉的战士」以特殊召唤为由解放。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 定义发动破坏效果所需的丢弃代价的筛选函数：需为光属性、可丢弃且可作为代价送入墓地的手卡怪兽。
function c18378582.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 发动效果的代价处理：先确认手牌存在满足条件的光属性怪兽；若有，则从中选择1张丢弃作为代价。
function c18378582.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0）确认手卡存在至少1张满足cfilter的光属性怪兽，以保证效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c18378582.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家从手卡选择1张满足条件的怪兽，以COST+DISCARD的理由丢弃到墓地。
	Duel.DiscardHand(tp,c18378582.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 设定效果的目标及操作信息：不取对象，以对方场上全部怪兽为破坏目标，并在发动时确认对方场上有怪兽；将破坏信息登记到连锁。
function c18378582.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标检查阶段，确认对方场上至少存在1只怪兽，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上当前存在的所有怪兽，作为这次效果预定要破坏的对象集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 将本次连锁的操作信息设置为破坏效果，对象为对方场上所有怪兽，数量为其张数，以便其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：先确认自己场上存在「天空的圣域」，若存在则破坏对方场上所有怪兽，否则效果不适用。
function c18378582.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前检查场上是否有表侧表示存在的「天空的圣域」（卡号56433456），满足效果文本中此效果仅当自己场上存在「天空的圣域」时才适用的条件。
	if Duel.IsEnvironment(56433456) then
		-- 在效果处理时重新获取对方场上当前存在的所有怪兽，以应对处理前怪兽数量或位置的变化。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 以效果破坏对方场上所有怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
