--ステルスロイド
-- 效果：
-- 自己场上有这张卡以外的名字带有「机人」的怪兽存在的场合，这张卡进行战斗的自己回合的战斗阶段结束时，把场上1张魔法或者陷阱卡破坏。
function c98049038.initial_effect(c)
	-- 自己场上有这张卡以外的名字带有「机人」的怪兽存在的场合，这张卡进行战斗的自己回合的战斗阶段结束时，把场上1张魔法或者陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98049038,0))  --"魔陷破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c98049038.descon)
	e1:SetTarget(c98049038.destg)
	e1:SetOperation(c98049038.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的名字带有「机人」的怪兽
function c98049038.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x16)
end
-- 检查发动条件：自己回合的战斗阶段结束时，此卡进行过战斗，且自己场上有此卡以外的名字带有「机人」的怪兽存在
function c98049038.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己回合，以及此卡在本次战斗阶段中是否进行过战斗
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetBattledGroupCount()>0
		-- 检查自己场上是否存在此卡以外的表侧表示的名字带有「机人」的怪兽
		and Duel.IsExistingMatchingCard(c98049038.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤条件：魔法或陷阱卡
function c98049038.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的对象选择与操作信息注册
function c98049038.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c98049038.desfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法或陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c98049038.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为“破坏选中的卡片”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：再次检查条件并破坏选中的卡片
function c98049038.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	-- 效果处理时，若自己场上已没有此卡以外的名字带有「机人」的怪兽，则效果不适用
	if not Duel.IsExistingMatchingCard(c98049038.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then return end
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
