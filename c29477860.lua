--螺旋砲撃
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己的怪兽区域有「龙骑士 盖亚」存在，对方只能选择「龙骑士 盖亚」作为攻击对象。
-- ②：自己的「龙骑士 盖亚」进行战斗的攻击宣言时，以场上1张卡为对象才能发动。那张卡破坏。
function c29477860.initial_effect(c)
	-- 记录此卡文本中提及的卡号66889139（「龙骑士 盖亚」），用于后续效果处理时识别相关卡名。
	aux.AddCodeList(c,66889139)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要自己的怪兽区域有「龙骑士 盖亚」存在，对方只能选择「龙骑士 盖亚」作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c29477860.tgcon)
	e1:SetValue(c29477860.tgtg)
	c:RegisterEffect(e1)
	-- ①：只要自己的怪兽区域有「龙骑士 盖亚」存在，对方只能选择「龙骑士 盖亚」作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c29477860.tgcon)
	c:RegisterEffect(e2)
	-- ②：自己的「龙骑士 盖亚」进行战斗的攻击宣言时，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29477860,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,29477860)
	e3:SetCondition(c29477860.descon)
	e3:SetTarget(c29477860.destg)
	e3:SetOperation(c29477860.desop)
	c:RegisterEffect(e3)
end
-- 定义过滤器：表侧表示且卡号为66889139（龙骑士 盖亚）。
function c29477860.tgfilter(c)
	return c:IsFaceup() and c:IsCode(66889139)
end
-- 定义条件：自己怪兽区域存在1只满足tgfilter的「龙骑士 盖亚」。
function c29477860.tgcon(e)
	-- 若自己怪兽区域存在表侧表示的「龙骑士 盖亚」则条件成立。
	return Duel.IsExistingMatchingCard(c29477860.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 作为攻击对象限制的判定函数：当候选怪兽为里侧表示或不是「龙骑士 盖亚」时返回true（即禁止被选为攻击对象），从而实现对方只能选择「龙骑士 盖亚」攻击。
function c29477860.tgtg(e,c)
	return c:IsFacedown() or not c:IsCode(66889139)
end
-- 定义②的发动条件：自己的「龙骑士 盖亚」进行攻击宣言时满足（攻击者为己方表侧表示的龙骑士 盖亚）。
function c29477860.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击宣言的怪兽。
	local ac=Duel.GetAttacker()
	-- 获取被攻击的怪兽（可能为nil，用于判断攻击者归属）。
	local tc=Duel.GetAttackTarget()
	if not ac:IsControler(tp) then ac,tc=tc,ac end
	return ac and ac:IsControler(tp) and ac:IsFaceup() and ac:IsCode(66889139)
end
-- 定义②的发动目标选择：选择场上1张卡（通常不能选择自身效果未启用的此卡）作为破坏对象。
function c29477860.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local xg=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then xg=e:GetHandler() end
	-- 效果发动时检查场上是否存在可选为对象的卡（除被排除的卡外至少1张）。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,xg) end
	-- 弹出“请选择要破坏的卡”的提示，供玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1张场上的卡作为效果对象，并记为连锁对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,xg)
	-- 将连锁处理信息设置为“破坏”分类，对象为选择的卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义②效果处理：取得对象卡，若仍与效果关联则将其破坏。
function c29477860.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
