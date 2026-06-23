--螺旋砲撃
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己的怪兽区域有「龙骑士 盖亚」存在，对方只能选择「龙骑士 盖亚」作为攻击对象。
-- ②：自己的「龙骑士 盖亚」进行战斗的攻击宣言时，以场上1张卡为对象才能发动。那张卡破坏。
function c29477860.initial_effect(c)
	-- 记录此卡与「龙骑士 盖亚」的关联
	aux.AddCodeList(c,66889139)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 只要自己的怪兽区域有「龙骑士 盖亚」存在，对方只能选择「龙骑士 盖亚」作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c29477860.tgcon)
	e1:SetValue(c29477860.tgtg)
	c:RegisterEffect(e1)
	-- 只要自己的怪兽区域有「龙骑士 盖亚」存在，不能直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c29477860.tgcon)
	c:RegisterEffect(e2)
	-- 自己的「龙骑士 盖亚」进行战斗的攻击宣言时，以场上1张卡为对象才能发动。那张卡破坏。
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
-- 用于判断场上是否存在「龙骑士 盖亚」的过滤函数
function c29477860.tgfilter(c)
	return c:IsFaceup() and c:IsCode(66889139)
end
-- 判断是否满足效果发动条件的函数
function c29477860.tgcon(e)
	-- 检查自己场上是否存在至少1张「龙骑士 盖亚」
	return Duel.IsExistingMatchingCard(c29477860.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 用于设置攻击对象不可选的函数
function c29477860.tgtg(e,c)
	return c:IsFacedown() or not c:IsCode(66889139)
end
-- 判断攻击怪兽是否为己方的「龙骑士 盖亚」
function c29477860.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽
	local ac=Duel.GetAttacker()
	-- 获取当前攻击目标
	local tc=Duel.GetAttackTarget()
	if not ac:IsControler(tp) then ac,tc=tc,ac end
	return ac and ac:IsControler(tp) and ac:IsFaceup() and ac:IsCode(66889139)
end
-- 设置效果发动时的选择目标处理函数
function c29477860.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local xg=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then xg=e:GetHandler() end
	-- 检查是否满足发动条件，即场上存在至少1张可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,xg) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,xg)
	-- 设置效果操作信息，指定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 设置效果发动后的处理函数
function c29477860.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
