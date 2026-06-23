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
	-- ②：只要持有超量素材的这张卡在怪兽区域存在，每次对方把魔法·陷阱卡发动给与对方600伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c26556950.regop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，把这张卡1个超量素材取除才能发动。持有这张卡的守备力以下的守备力的对方场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c26556950.damcon)
	e3:SetOperation(c26556950.damop)
	c:RegisterEffect(e3)
	-- 1回合1次，把这张卡1个超量素材取除才能发动。持有这张卡的守备力以下的守备力的对方场上的怪兽全部破坏。
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
-- 设置此卡为No.84编号
aux.xyz_number[26556950]=84
-- 过滤满足条件的怪兽：表侧表示、超量素材不少于2个、超量怪兽、暗属性、阶级在8~10阶之间
function c26556950.ovfilter(c)
	local rk=c:GetRank()
	return c:IsFaceup() and c:GetOverlayCount()>=2 and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and rk>=8 and rk<=10
end
-- 计算场上所有表侧表示怪兽的阶级总和并乘以200作为守备力提升值
function c26556950.defval(e,c)
	-- 获取场上所有表侧表示的怪兽组成的组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,c:GetControler(),LOCATION_MZONE,0,nil)
	return g:GetSum(Card.GetRank)*200
end
-- 若对方发动魔法或陷阱卡，则记录一个标记用于后续伤害判定
function c26556950.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():RegisterFlagEffect(26556950,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- 判断是否满足触发伤害条件：此卡有超量素材、对方发动、且已记录标记
function c26556950.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayCount()>0 and ep~=tp and c:GetFlagEffect(26556950)~=0 and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 向对方造成600点伤害
function c26556950.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示此卡发动动画提示
	Duel.Hint(HINT_CARD,0,26556950)
	-- 向对方造成600点伤害
	Duel.Damage(1-tp,600,REASON_EFFECT)
end
-- 支付1个超量素材作为发动代价
function c26556950.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足条件的怪兽：表侧表示、守备力不超过指定值
function c26556950.desfilter(c,def)
	return c:IsFaceup() and c:IsDefenseBelow(def)
end
-- 设置破坏效果的目标：对方场上所有守备力不超过此卡守备力的怪兽
function c26556950.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否存在满足破坏条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c26556950.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetDefense()) end
	-- 获取所有满足破坏条件的怪兽组成的组
	local g=Duel.GetMatchingGroup(c26556950.desfilter,tp,0,LOCATION_MZONE,nil,c:GetDefense())
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏操作：将满足条件的怪兽全部破坏
function c26556950.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取所有满足破坏条件的怪兽组成的组
	local g=Duel.GetMatchingGroup(c26556950.desfilter,tp,0,LOCATION_MZONE,nil,c:GetDefense())
	-- 将满足条件的怪兽全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
