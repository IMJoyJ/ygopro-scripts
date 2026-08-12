--ジャンク・デストロイヤー
-- 效果：
-- 「废品同调士」＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤成功时，以最多有那些作为同调素材的怪兽之内除调整以外的怪兽数量的场上的卡为对象才能发动。那些卡破坏。
function c74860293.initial_effect(c)
	-- 将「废品同调士」作为特定素材记述在卡片信息中，以便其他卡片检索或关联
	aux.AddMaterialCodeList(c,63977008)
	-- 添加同调召唤手续：以「废品同调士」为调整，加上1只以上的非调整怪兽
	aux.AddSynchroProcedure(c,c74860293.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功时，以最多有那些作为同调素材的怪兽之内除调整以外的怪兽数量的场上的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74860293,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c74860293.con)
	e1:SetTarget(c74860293.tg)
	e1:SetOperation(c74860293.op)
	c:RegisterEffect(e1)
end
c74860293.material_setcode=0x1017
-- 过滤同调素材中的调整怪兽，必须是「废品同调士」或具有代替其作为素材效果的怪兽
function c74860293.tfilter(c)
	return c:IsCode(63977008) or c:IsHasEffect(20932152)
end
-- 判断发动条件：这张卡是否同调召唤成功
function c74860293.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果发动时的对象选择与合法性检查，选择最多等同于非调整素材数量的场上的卡作为对象
function c74860293.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local mc=e:GetHandler():GetMaterialCount()
	-- 在发动检查阶段，确认素材总数大于1（即至少有1只非调整素材）且场上存在可作为对象的卡
	if chk==0 then return mc>1 and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1到（素材总数-1）张（即最多为非调整素材数量）场上的卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,mc-1,nil)
	-- 设置效果处理信息：操作分类为破坏，目标为选中的卡片组，数量为选中卡片的数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：将仍存在于场上且与效果相关的对象卡破坏
function c74860293.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 因效果将这些卡破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
