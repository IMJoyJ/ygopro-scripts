--起動提督デストロイリボルバー
-- 效果：
-- 这张卡不能通常召唤。从手卡以及自己场上的表侧表示的卡之中把2张「零件」怪兽卡送去墓地的场合才能特殊召唤。
-- ①：只要自己场上有「零件」怪兽或者当作装备卡使用的「零件」怪兽存在，这张卡不会被战斗·效果破坏。
-- ②：1回合1次，以这张卡以外的场上1张卡为对象才能发动。那张卡破坏。
function c36322312.initial_effect(c)
	c:EnableReviveLimit()
	-- 对应效果原文‘从手卡以及自己场上的表侧表示的卡之中把2张「零件」怪兽卡送去墓地的场合才能特殊召唤。’：设置该卡的特殊召唤条件，使其只能通过正规手续特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 对应效果原文‘从手卡以及自己场上的表侧表示的卡之中把2张「零件」怪兽卡送去墓地的场合才能特殊召唤。’：定义从手卡把2张「零件」怪兽卡送去墓地来特殊召唤该卡的召唤手续。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c36322312.sprcon)
	e2:SetTarget(c36322312.sprtg)
	e2:SetOperation(c36322312.sprop)
	c:RegisterEffect(e2)
	-- 对应①效果‘只要自己场上有「零件」怪兽或者当作装备卡使用的「零件」怪兽存在，这张卡不会被战斗·效果破坏。’中的‘这张卡不会被战斗破坏’：在满足条件时获得战斗破坏抗性。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c36322312.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
	-- 对应②效果‘1回合1次，以这张卡以外的场上1张卡为对象才能发动。那张卡破坏。’：登记起动效果，取对象破坏场上1张卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(36322312,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c36322312.destg)
	e5:SetOperation(c36322312.desop)
	c:RegisterEffect(e5)
end
-- 筛选可作为召唤素材的卡：位于手牌或自己场上表侧表示、属「零件」系列且原本种类为怪兽，并能作为Cost送去墓地。
function c36322312.sprfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsSetCard(0x51) and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsAbleToGraveAsCost()
end
-- 特殊召唤手续的发动条件：从自己手牌和场上检索满足条件的「零件」素材，确认能选出2张送去墓地后自己场上仍有可用的怪兽区域。
function c36322312.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己手牌和场上所有满足“可作为召唤素材”条件的「零件」怪兽卡集合。
	local g=Duel.GetMatchingGroup(c36322312.sprfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	-- 检查上述素材集合中是否存在2张卡，可以在作为素材送去墓地/除外后仍保证自己场上有至少1个可用的怪兽区域（即允许特殊召唤）。
	return g:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 特殊召唤手续的目标选择：从可用素材集合中选出2张「零件」怪兽卡，选中后保存到效果标签中，供后续作为Cost送去墓地。
function c36322312.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己手牌和场上所有满足“可作为召唤素材”条件的「零件」怪兽卡集合。
	local g=Duel.GetMatchingGroup(c36322312.sprfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	-- 给出“请选择要送去墓地的卡”的选择提示，让玩家进行素材选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家在上述候选中选择2张卡，并附加“送墓后仍有可用怪兽区域”的合法性校验；选择成功则返回所选组，否则失败。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的处理：取出目标阶段保存的2张素材卡，将它们送去墓地，然后清除保存的引用。
function c36322312.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的2张「零件」怪兽卡作为特殊召唤的素材/COST送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断是否存在满足抗性条件的「零件」卡：表侧表示且位于怪兽区域，或是原本为怪兽的「零件」卡正当作装备卡装备在场上。
function c36322312.indfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x51) and (c:IsLocation(LOCATION_MZONE) or (bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:GetEquipTarget()))
end
-- 抗性条件判断：此卡控制者场上有至少1张符合条件的「零件」怪兽/装备卡时，此卡获得战斗·效果破坏抗性。
function c36322312.indcon(e)
	-- 检索此卡控制者场上是否存在至少1张满足条件的「零件」卡（表侧怪兽或装备状态的「零件」怪兽）。
	return Duel.IsExistingMatchingCard(c36322312.indfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- ②效果的发动条件与对象选择：1回合1次，从场上选择此卡以外的1张卡作为对象；选择后设置破坏操作信息。
function c36322312.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	-- 发动时确认场上是否存在此卡以外的可被选择为对象的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 给出“请选择要破坏的卡”的选择提示，让玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张此卡以外的卡作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 将本次操作信息设置为“破坏”分类，登记要破坏的对象组g及数量1，供后续连锁/时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的解决处理：取得发动时选择的对象，若该卡仍与效果关联，则将其破坏。
function c36322312.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将那张对象卡以效果破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
