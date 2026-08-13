--デストーイ・シザー・タイガー
-- 效果：
-- 「锋利小鬼·剪刀」＋「毛绒动物」怪兽1只以上
-- ①：「魔玩具·剪刀虎」在自己场上只能有1只表侧表示存在。
-- ②：这张卡融合召唤成功时，以最多有作为这张卡的融合素材的怪兽数量的场上的卡为对象才能发动。那些卡破坏。
-- ③：只要这张卡在怪兽区域存在，自己场上的「魔玩具」怪兽的攻击力上升自己场上的「毛绒动物」怪兽以及「魔玩具」怪兽数量×300。
function c464362.initial_effect(c)
	c:SetUniqueOnField(1,0,464362)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：需要1只「锋利小鬼·剪刀」＋1只以上「毛绒动物」怪兽作为融合素材（素材数量最多127只）。
	aux.AddFusionProcCodeFunRep(c,30068120,aux.FilterBoolFunction(Card.IsFusionSetCard,0xa9),1,127,true,true)
	-- ②：这张卡融合召唤成功时，以最多有作为这张卡的融合素材的怪兽数量的场上的卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c464362.descon)
	e2:SetTarget(c464362.destg)
	e2:SetOperation(c464362.desop)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，自己场上的「魔玩具」怪兽的攻击力上升自己场上的「毛绒动物」怪兽以及「魔玩具」怪兽数量×300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 将攻击力加成效果的对象限定为自己场上表侧表示的「魔玩具」怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xad))
	e3:SetValue(c464362.atkval)
	c:RegisterEffect(e3)
end
-- ②效果的发动条件：这张卡融合召唤成功。
function c464362.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 取对象阶段先确认候选卡在场上；发动合法性检查需满足素材数量大于0，且场上存在至少1张可选择为对象的卡。
function c464362.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local ct=e:GetHandler():GetMaterialCount()
	if chk==0 then return ct>0
		-- 确认双方场上存在至少1张可被选择为对象的卡，否则效果不能发动。
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家显示“请选择要破坏的卡”的UI选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 由发动玩家从双方场上选择1到ct张（ct为融合素材数量）的卡作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置连锁操作信息：声明本效果将破坏所选择的卡，数量为选定的卡数，供后续连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，取出仍与该效果关联的对象卡并将其破坏。
function c464362.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取发动时选择的对象卡组，并过滤出仍然与此效果有关联的卡（排除已离场或失去联系的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将过滤后的卡以效果原因破坏（送去墓地）。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 定义攻击力上升值计算用的过滤条件：表侧表示且属于「毛绒动物」(0xa9)或「魔玩具」(0xad)字段。
function c464362.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa9,0xad)
end
-- 计算攻击力上升值：统计控制者场上符合条件的怪兽数量，再乘以300。
function c464362.atkval(e,c)
	-- 返回攻击力上升数值＝该卡控制者场上表侧表示的「毛绒动物/魔玩具」怪兽数量×300。
	return Duel.GetMatchingGroupCount(c464362.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)*300
end
