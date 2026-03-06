--XX－セイバー ヒュンレイ
-- 效果：
-- 调整＋调整以外的「X-剑士」怪兽1只以上
-- ①：这张卡同调召唤时，以场上最多3张魔法·陷阱卡为对象才能发动。那些卡破坏。
function c2203790.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只以上调整以外的「X-剑士」怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x100d),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤时，以场上最多3张魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2203790,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c2203790.descon)
	e1:SetTarget(c2203790.destg)
	e1:SetOperation(c2203790.desop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：此卡必须通过同调召唤方式特殊召唤成功
function c2203790.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的魔法·陷阱卡
function c2203790.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果的目标选择函数，选择场上1~3张魔法·陷阱卡作为对象
function c2203790.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c2203790.filter(chkc) end
	-- 判断是否满足选择对象的条件，即场上是否存在至少1张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c2203790.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1~3张魔法·陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c2203790.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,3,nil)
	-- 设置连锁的操作信息，确定破坏的卡组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数，将选定的卡破坏
function c2203790.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡组中与效果相关的卡进行破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
