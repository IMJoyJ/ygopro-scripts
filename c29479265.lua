--破械雙王神ライゴウ
-- 效果：
-- 包含连接怪兽的怪兽2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：「破械双王神 来迎」以外的卡的效果让场上的卡被破坏的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：这张卡以外的怪兽被战斗破坏时，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：自己·对方的结束阶段以场上1张卡为对象才能发动。那张卡破坏。
function c29479265.initial_effect(c)
	-- 为这张卡添加连接召唤手续：素材为2只以上怪兽，且整个素材组中必须至少包含1只连接怪兽（由lcheck函数确认）。
	aux.AddLinkProcedure(c,nil,2,nil,c29479265.lcheck)
	c:EnableReviveLimit()
	-- ①：「破械双王神 来迎」以外的卡的效果让场上的其他卡被破坏的场合，以场上1张卡为对象才能发动。那张卡破坏。
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
	-- ②：其他怪兽被战斗破坏时，以场上1张卡为对象才能发动。那张卡破坏。
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
-- 连接素材组的检查函数：判断素材组中是否存在至少1只连接怪兽，以保证满足“包含连接怪兽的怪兽2只以上”的召唤条件。
function c29479265.lcheck(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
end
-- 破坏事件的过滤函数：判断一张卡被破坏前是否位于场上，且破坏原因是效果破坏（REASON_EFFECT），用于识别“因卡片效果被破坏的卡”。
function c29479265.cfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
-- 效果①的发动条件：本次破坏并非由本卡（「破械双王神 来迎」）的效果造成，且存在至少1张在场上的卡被效果破坏，满足这些条件才允许发动。
function c29479265.descon1(e,tp,eg,ep,ev,re,r,rp)
	return (re==nil or not re:GetHandler():IsCode(29479265)) and eg:IsExists(c29479265.cfilter,1,nil)
end
-- 破坏效果的发动时点处理函数（①/②/③共用）：检查能否选择场上1张卡为对象，让玩家选择对象，并登记破坏1张卡的操作信息。
function c29479265.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 效果发动合法性检查：确认当前场上（双方怪兽区和魔陷区）至少存在1张可选为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家发出选择提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作玩家从双方场上选择1张卡作为效果对象，并将该卡登记为本连锁的效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息：将为破坏对象组g中的1张卡（分类为破坏效果），供其他连锁或判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理函数（①/②/③共用）：取回效果对象，若该对象仍与该效果相关，则将其破坏。
function c29479265.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果破坏的原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
