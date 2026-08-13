--A BF－驟雨のライキリ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
-- ②：1回合1次，以最多有这张卡以外的自己场上的「黑羽」怪兽数量的对方场上的卡为对象才能发动。那些卡破坏。
function c16051717.initial_effect(c)
	-- 为这张卡添加同调召唤手续，要求素材为1只调整 + 1只以上调整以外的怪兽，即“调整＋调整以外的怪兽1只以上”。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c16051717.tncon)
	e1:SetOperation(c16051717.tnop)
	c:RegisterEffect(e1)
	-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c16051717.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以最多有这张卡以外的自己场上的「黑羽」怪兽数量的对方场上的卡为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c16051717.destg)
	e3:SetOperation(c16051717.desop)
	c:RegisterEffect(e3)
end
c16051717.treat_itself_tuner=true
-- 检查这张卡的同调素材中是否存在「黑羽」怪兽，若有则将e1的标签设为1，否则设为0，用于判定是否满足①的条件。
function c16051717.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x33) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 该效果的发动条件：此卡同调召唤成功，且e2的素材检查已确认使用了「黑羽」怪兽作为素材（标签为1）。
function c16051717.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- 给这张卡注册一个不可无效的持续效果，使其追加调整类型，从而“当作调整使用”。
function c16051717.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 筛选自己场上表侧表示且卡名包含「黑羽」的怪兽，用于②决定可选对方卡的数量。
function c16051717.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
-- ②的发动条件：自己场上有这张卡以外的「黑羽」怪兽存在，且对方场上有可以作为对象的卡。
function c16051717.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查是否存在满足条件的「黑羽」怪兽（这张卡以外）作为数量依据。
	if chk==0 then return Duel.IsExistingMatchingCard(c16051717.filter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		-- 检查对方场上是否存在至少1张可以成为对象的卡。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取这张卡以外的自己场上的「黑羽」怪兽数量，作为可选对象的数量上限。
	local ct=Duel.GetMatchingGroupCount(c16051717.filter,tp,LOCATION_MZONE,0,e:GetHandler())
	-- 向玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1至ct张卡作为效果对象，ct为「黑羽」怪兽数量。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设定本次连锁的处理信息为破坏所选对象，用于后续效果处理及对应判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果处理时，取回对象卡，过滤仍与效果相关的卡后将其破坏。
function c16051717.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的效果对象卡组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将相关对象卡破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
