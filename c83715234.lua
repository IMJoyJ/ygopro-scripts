--ムーン・スクレイパー
-- 效果：
-- 自己场上的岩石族怪兽的表示形式变更时，可以选择对方场上1张魔法·陷阱卡破坏。这个效果1回合只能使用1次。
function c83715234.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的岩石族怪兽的表示形式变更时，可以选择对方场上1张魔法·陷阱卡破坏。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83715234,0))  --"魔陷破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c83715234.descon)
	e2:SetTarget(c83715234.destg)
	e2:SetOperation(c83715234.desop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表示形式发生变更（攻守表示切换或表里表示切换）的岩石族怪兽
function c83715234.cfilter(c,tp)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return c:IsControler(tp) and c:IsRace(RACE_ROCK) and not c:IsStatus(STATUS_CONTINUOUS_POS) and ((np<3 and pp>3) or (pp<3 and np>3))
end
-- 判定是否有自己场上的岩石族怪兽变更了表示形式
function c83715234.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c83715234.cfilter,1,nil,tp)
end
-- 过滤魔法或陷阱卡
function c83715234.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动的靶向检测与合法性判定，确认此卡未在连锁中且对方场上存在可选择的魔法·陷阱卡
function c83715234.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c83715234.desfilter(chkc) end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 判定对方场上是否存在可以作为效果对象的魔法·陷阱卡
		and Duel.IsExistingTarget(c83715234.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c83715234.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，表示该效果的处理为破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理的执行函数，获取并破坏作为对象的卡片
function c83715234.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
