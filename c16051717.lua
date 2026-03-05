--A BF－驟雨のライキリ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
-- ②：1回合1次，以最多有这张卡以外的自己场上的「黑羽」怪兽数量的对方场上的卡为对象才能发动。那些卡破坏。
function c16051717.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
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
	-- ②：1回合1次，以最多有这张卡以外的自己场上的「黑羽」怪兽数量的对方场上的卡为对象才能发动。那些卡破坏。
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
-- 检查同调召唤所用的素材中是否存在黑羽怪兽，若存在则将标签设为1，否则设为0
function c16051717.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x33) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断是否为同调召唤且标签为1（即使用了黑羽怪兽作为素材）
function c16051717.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- 若满足条件，则为自身添加调整属性
function c16051717.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为自身添加调整属性
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 过滤场上正面表示的黑羽怪兽
function c16051717.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
-- 设置效果发动时的取对象处理，检查是否能选择对方场上的卡作为破坏对象
function c16051717.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查自己场上是否存在至少1只黑羽怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c16051717.filter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		-- 检查对方场上是否存在至少1张卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 计算自己场上黑羽怪兽数量，作为最多可破坏的对方场上的卡的数量
	local ct=Duel.GetMatchingGroupCount(c16051717.filter,tp,LOCATION_MZONE,0,e:GetHandler())
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多与自己场上的黑羽怪兽数量相同的对方场上的卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置效果处理信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将选定的卡破坏
function c16051717.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将对象卡组中与当前效果相关的卡进行破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
