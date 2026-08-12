--破械雙王神ライゴウ
-- 效果：
-- 包含连接怪兽的怪兽2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：「破械双王神 来迎」以外的卡的效果让场上的卡被破坏的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：这张卡以外的怪兽被战斗破坏时，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：自己·对方的结束阶段以场上1张卡为对象才能发动。那张卡破坏。
function c29479265.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用至少2个连接怪兽作为素材
	aux.AddLinkProcedure(c,nil,2,nil,c29479265.lcheck)
	c:EnableReviveLimit()
	-- ①：「破械双王神 来迎」以外的卡的效果让场上的卡被破坏的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29479265,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,29479265)
	e1:SetCondition(c29479265.descon1)
	e1:SetTarget(c29479265.destg)
	e1:SetOperation(c29479265.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡以外的怪兽被战斗破坏时，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29479265,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,29479266)
	e2:SetTarget(c29479265.destg)
	e2:SetOperation(c29479265.desop)
	c:RegisterEffect(e2)
	-- ③：自己·对方的结束阶段以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29479265,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,29479267)
	e3:SetTarget(c29479265.destg)
	e3:SetOperation(c29479265.desop)
	c:RegisterEffect(e3)
end
-- 连接怪兽素材检查函数，判断连接怪兽数量是否满足条件
function c29479265.lcheck(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
end
-- 破坏来源过滤器，用于判断被破坏的卡是否来自效果且在场上被破坏
function c29479265.cfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
-- 效果①的发动条件判断函数，确保不是来自自身效果的破坏且有符合条件的卡被破坏
function c29479265.descon1(e,tp,eg,ep,ev,re,r,rp)
	return (re==nil or not re:GetHandler():IsCode(29479265)) and eg:IsExists(c29479265.cfilter,1,nil)
end
-- 效果②③的处理目标选择函数，选择场上一张卡作为破坏对象
function c29479265.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 判断是否满足选择目标的条件，即场上存在一张可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，表明将要破坏一张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②③的处理函数，对选中的卡进行破坏
function c29479265.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
