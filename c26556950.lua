--No.84 ペイン・ゲイナー
-- 效果：
-- 11星怪兽×2
-- 这张卡也能在持有超量素材2个以上的自己的8～10阶的暗属性超量怪兽上面重叠来超量召唤。
-- ①：这张卡的守备力上升自己场上的超量怪兽的阶级合计×200。
-- ②：只要持有超量素材的这张卡在怪兽区域存在，每次对方把魔法·陷阱卡发动给与对方600伤害。
-- ③：1回合1次，把这张卡1个超量素材取除才能发动。持有这张卡的守备力以下的守备力的对方场上的怪兽全部破坏。
function c26556950.initial_effect(c)
	aux.AddXyzProcedure(c,nil,11,2,c26556950.ovfilter,aux.Stringid(26556950,0),2)  --"请选择8～10阶的暗属超量怪兽"
	c:EnableReviveLimit()
	-- ①：这张卡的守备力上升自己场上的超量怪兽的阶级合计×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(c26556950.defval)
	c:RegisterEffect(e1)
	-- ②：只要持有超量素材的这张卡在怪兽区域存在，每次对方把魔法·陷阱卡发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c26556950.regop)
	c:RegisterEffect(e2)
	-- ②：给与对方600伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c26556950.damcon)
	e3:SetOperation(c26556950.damop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，把这张卡1个超量素材取除才能发动。持有这张卡的守备力以下的守备力的对方场上的怪兽全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(26556950,1))  --"破坏怪兽"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c26556950.descost)
	e4:SetTarget(c26556950.destg)
	e4:SetOperation(c26556950.desop)
	c:RegisterEffect(e4)
end
-- 将这张卡登记为“No.84”怪兽，使其在规则上被视为“No.84”字段的超量怪兽，以对应卡名中的“No.84”及相关的No.支援效果。
aux.xyz_number[26556950]=84
-- 定义额外的超量召唤手续中可作为叠放素材的怪兽：自己的表侧表示、持有超量素材2个以上、阶级8～10的暗属性超量怪兽，用于实现“这张卡也能在持有超量素材2个以上的自己的8～10阶的暗属性超量怪兽上面重叠来超量召唤”；此卡常规超量召唤条件为“11星怪兽×2”，在另一处代码（aux.AddXyzProcedure）中实现。
function c26556950.ovfilter(c)
	local rk=c:GetRank()
	return c:IsFaceup() and c:GetOverlayCount()>=2 and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and rk>=8 and rk<=10
end
-- 计算这张卡通过①效果获得的守备力上升值：自己场上表侧表示的超量怪兽的阶级合计×200。
function c26556950.defval(e,c)
	-- 获取这张卡控制者场上所有表侧表示的怪兽，作为统计阶级合计的对象集合（非超量怪兽的阶级视为0）。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,c:GetControler(),LOCATION_MZONE,0,nil)
	return g:GetSum(Card.GetRank)*200
end
-- 若对方发动魔法·陷阱卡（且不是自己发动的），给这张卡设置一个专用标记，用于在连锁结束时确认本次发动并触发伤害效果。
function c26556950.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():RegisterFlagEffect(26556950,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- 判定是否发动②效果的伤害：这张卡持有超量素材且在怪兽区域，且对方确实发动了魔法·陷阱卡（ep~=tp，并存在之前登记的标记）。
function c26556950.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayCount()>0 and ep~=tp and c:GetFlagEffect(26556950)~=0 and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 处理②效果的伤害结算：展示卡图并给予对方玩家600点效果伤害。
function c26556950.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示这张卡的卡图动画，作为伤害来源的提示。
	Duel.Hint(HINT_CARD,0,26556950)
	-- 给予对方玩家（1-tp）600点效果伤害，原因为效果伤害。
	Duel.Damage(1-tp,600,REASON_EFFECT)
end
-- 作为③效果的发动代价：从这张卡上取除1个超量素材；chk==0时仅检查是否能够取除，实际发动时执行取除。
function c26556950.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选符合条件的怪兽：表侧表示且守备力不高于指定数值（即这张卡当前的守备力），用于确定③效果要破坏的对方怪兽。
function c26556950.desfilter(c,def)
	return c:IsFaceup() and c:IsDefenseBelow(def)
end
-- ③效果的发动目标处理：检查对方场上是否存在符合守备力条件的怪兽；若存在，则取得全部符合条件的怪兽并设置破坏的操作信息。
function c26556950.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时检查对方场上是否存在至少1只表侧且守备力不高于这张卡当前守备力的怪兽，作为发动合法性的判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c26556950.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetDefense()) end
	-- 在目标阶段获取对方场上所有符合守备力条件的表侧怪兽集合，用于登记操作信息。
	local g=Duel.GetMatchingGroup(c26556950.desfilter,tp,0,LOCATION_MZONE,nil,c:GetDefense())
	-- 将本次效果处理中要破坏的对象及数量登记到当前连锁的操作信息中，使其他卡（如“星尘龙”等）可以对应这个破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ③效果处理时，若这张卡仍与效果相关且表侧表示，则重新获取对方场上符合守备力条件的怪兽，并将它们全部破坏。
function c26556950.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 在效果处理时重新获取对方场上当前所有表侧且守备力不高于这张卡当前守备力的怪兽，避免因时点变化导致目标不准确。
	local g=Duel.GetMatchingGroup(c26556950.desfilter,tp,0,LOCATION_MZONE,nil,c:GetDefense())
	-- 以效果原因将获取到的对方怪兽全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
