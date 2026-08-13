--XX－セイバー ヒュンレイ
-- 效果：
-- 调整＋调整以外的「X-剑士」怪兽1只以上
-- ①：这张卡同调召唤时，以场上最多3张魔法·陷阱卡为对象才能发动。那些卡破坏。
function c2203790.initial_effect(c)
	-- 为这张卡添加同调召唤手续：把1只调整以外的“X-剑士”怪兽（字段0x100d）作为非调整素材，调整不限制，合计素材数量为1以上，以同调召唤方式特殊召唤。
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
-- 发动条件判定：只有当这张卡是以同调召唤方式特殊召唤成功时才满足条件，即确认其召唤类型为同调召唤。
function c2203790.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 卡片筛选函数：筛选出场上表侧或里侧表示的魔法卡或陷阱卡。
function c2203790.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动目标处理：确认场上存在可作为对象的魔法·陷阱卡后，提示玩家选择1~3张，将其设为对象，并设置破坏这些卡的操作信息。
function c2203790.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c2203790.filter(chkc) end
	-- 效果发动合法性检查：判断场上是否至少存在1张魔法·陷阱卡可以选择为对象。
	if chk==0 then return Duel.IsExistingTarget(c2203790.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送选择提示消息，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从双方场上选择1~3张魔法·陷阱卡作为这张卡效果的对象。
	local g=Duel.SelectTarget(tp,c2203790.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,3,nil)
	-- 设置连锁处理的操作信息：声明本次效果将破坏所选择的这些卡，数量为对象卡的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：获取效果发动时选择的对象卡，筛选出仍然与效果相关的卡，然后将其全部破坏。
function c2203790.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得本效果发动时选择的对象卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将经过关系筛选后仍然有效的对象卡以“效果”的原因破坏送入墓地。
	Duel.Destroy(sg,REASON_EFFECT)
end
