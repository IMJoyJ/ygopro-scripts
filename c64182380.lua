--炎王神 ガルドニクス・エタニティ
-- 效果：
-- 8星怪兽×2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。场上的其他怪兽全部破坏。
-- ②：把这张卡1个超量素材取除，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏，这张卡的攻击力上升500。
-- ③：持有超量素材的这张卡被破坏的场合才能发动。把最多有这张卡持有的超量素材数量的「炎王」怪兽从自己墓地特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①超量召唤成功时破坏场上其他怪兽、②去除素材破坏魔陷并加攻、③持有素材被破坏时特召墓地「炎王」怪兽的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：8星怪兽2只以上
	aux.AddXyzProcedure(c,nil,8,2,nil,nil,99)
	-- ①：这张卡超量召唤的场合才能发动。场上的其他怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.dmcon)
	e1:SetTarget(s.dmtg)
	e1:SetOperation(s.dmop)
	c:RegisterEffect(e1)
	-- ②：把这张卡1个超量素材取除，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏，这张卡的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(s.dscost)
	e2:SetTarget(s.dstg)
	e2:SetOperation(s.dsop)
	c:RegisterEffect(e2)
	-- ③：持有超量素材的这张卡被破坏的场合才能发动。把最多有这张卡持有的超量素材数量的「炎王」怪兽从自己墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o*2)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：这张卡超量召唤成功
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果①的发动准备：检查场上是否存在其他怪兽，并设置破坏的操作信息
function s.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上除这张卡以外的所有怪兽
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if chk==0 then return #g>0 end
	-- 设置破坏的操作信息，目标为获取到的其他怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果①的处理：破坏场上除这张卡以外的所有怪兽
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡以外的所有怪兽（排除自身）
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 破坏获取到的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果②的代价：取除这张卡的1个超量素材
function s.dscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动准备：选择场上1张魔法·陷阱卡作为对象，并设置破坏的操作信息
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置破坏的操作信息，目标为选择的对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的处理：破坏作为对象的卡，若破坏成功且自身在场上表侧表示存在，则自身攻击力上升500
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与效果相关联，将其破坏，并检查破坏是否成功以及自身是否仍在场上表侧表示存在
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(500)
		c:RegisterEffect(e1)
	end
end
-- 效果③的发动条件：这张卡在怪兽区域被破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 过滤条件：墓地中可以特殊召唤的「炎王」怪兽
function s.filter(c,e,tp)
	return c:IsSetCard(0x81) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备：获取被破坏时持有的超量素材数量，检查墓地是否有可特召的「炎王」怪兽，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetPreviousOverlayCountOnField()
	-- 检查被破坏时持有的超量素材数量是否大于0，且自己场上是否有空余的怪兽区域
	if chk==0 then return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只可以特殊召唤的「炎王」怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	e:SetLabel(ct)
	-- 设置特殊召唤的操作信息，目标为自己墓地的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果③的处理：从自己墓地选择最多等同于被破坏时持有素材数量的「炎王」怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1张以上、最多等同于被破坏时持有素材数量的「炎王」怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,e:GetLabel(),nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
