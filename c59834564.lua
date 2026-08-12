--嚇灼の魔神
-- 效果：
-- ①：自己场上有炎属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合，以自己场上2只炎属性怪兽为对象发动。那些自己的炎属性怪兽破坏。
function c59834564.initial_effect(c)
	-- ①：自己场上有炎属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c59834564.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合，以自己场上2只炎属性怪兽为对象发动。那些自己的炎属性怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59834564,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c59834564.destg)
	e2:SetOperation(c59834564.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的炎属性怪兽
function c59834564.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 特殊召唤规则的条件判定
function c59834564.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在炎属性怪兽
		and	Duel.IsExistingMatchingCard(c59834564.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 破坏效果的发动准备与对象选择
function c59834564.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c59834564.filter(chkc) end
	if chk==0 then return true end
	-- 检查自己场上是否存在至少2只可作为对象的炎属性怪兽
	if Duel.IsExistingTarget(c59834564.filter,tp,LOCATION_MZONE,0,2,nil) then
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择自己场上2只炎属性怪兽作为效果对象
		local g=Duel.SelectTarget(tp,c59834564.filter,tp,LOCATION_MZONE,0,2,2,nil)
		-- 设置效果处理信息为破坏这2只怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	end
end
-- 破坏效果的实际处理
function c59834564.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local dg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍存在于场上的对象怪兽因效果破坏
	Duel.Destroy(dg,REASON_EFFECT)
end
