--聖騎士トリスタン
-- 效果：
-- 「圣骑士 崔斯坦」的②的效果1回合只能使用1次。
-- ①：只要自己场上有这张卡以外的「圣骑士」怪兽存在，对方不能把这张卡以外的自己场上的攻击力未满1800的怪兽作为攻击对象，也不能作为效果的对象。
-- ②：让这张卡把「圣剑」装备魔法卡装备的场合，以场上1张表侧表示的卡为对象发动。那张表侧表示的卡破坏。
function c53550467.initial_effect(c)
	-- 对应效果原文①的前半部分：只要自己场上有这张卡以外的「圣骑士」怪兽存在，对方不能把这张卡以外的自己场上的攻击力未满1800的怪兽作为攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetCondition(c53550467.con)
	e1:SetValue(c53550467.atlimit)
	c:RegisterEffect(e1)
	-- 对应效果原文①的后半部分：也不能作为效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c53550467.con)
	e2:SetTarget(c53550467.tglimit)
	-- 设置Value为aux.tgoval，使该不能成为效果对象的效果只对对方发动的效果生效（对方不能将这些卡选为效果对象）
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 对应效果原文②：②：让这张卡把「圣剑」装备魔法卡装备的场合，以场上1张表侧表示的卡为对象发动。那张表侧表示的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53550467,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_EQUIP)
	e3:SetCountLimit(1,53550467)
	e3:SetCondition(c53550467.descon)
	e3:SetTarget(c53550467.destg)
	e3:SetOperation(c53550467.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡为表侧表示且属于「圣骑士」字段（0x107a），用于检索场上存在的其他圣骑士怪兽
function c53550467.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107a)
end
-- ①效果的条件函数：检查己方怪兽区是否存在至少1张除自身以外的表侧表示「圣骑士」怪兽，作为该保护效果生效的前提
function c53550467.con(e)
	-- 调用Duel.IsExistingMatchingCard，在己方怪兽区检索是否存在至少1张满足cfilter且不是效果持有者自身的「圣骑士」怪兽
	return Duel.IsExistingMatchingCard(c53550467.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 攻击对象限制的判定：若候选攻击对象不是效果持有者自身、表侧表示且攻击力低于1800，则对方不能将其选为攻击对象
function c53550467.atlimit(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:GetAttack()<1800
end
-- 效果对象限制的判定：若候选对象不是效果持有者自身且攻击力低于1800，则对方不能将其选为效果对象（攻击力只对表侧怪兽有意义）
function c53550467.tglimit(e,c)
	return c~=e:GetHandler() and c:GetAttack()<1800
end
-- e3的触发条件：装备事件发生时，检查事件涉及的卡组eg中是否存在至少1张「圣剑」装备魔法（0x207a），以判断是否触发②效果
function c53550467.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 对象筛选函数：选择场上表侧表示的卡作为破坏对象
function c53550467.desfilter(c)
	return c:IsFaceup()
end
-- e3的目标选择与信息设置：合法对象检查后，提示玩家从双方场上选择1张表侧表示的卡为对象，并设置破坏的操作信息
function c53550467.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c53550467.desfilter(chkc) end
	if chk==0 then return true end
	-- 显示选择提示：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从双方场上选择1张表侧表示的卡，并将该卡注册为当前连锁的取对象目标
	local g=Duel.SelectTarget(tp,c53550467.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息为破坏，目标为所选对象，数量为1，供时点和连锁处理检测
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- e3的效果处理：取得对象卡，若该卡仍与本次效果关联且为表侧表示，则将其破坏
function c53550467.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得连锁中记录的第一张也是唯一一张对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 以效果原因（REASON_EFFECT）将对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
