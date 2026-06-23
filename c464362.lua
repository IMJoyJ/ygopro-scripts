--デストーイ・シザー・タイガー
-- 效果：
-- 「锋利小鬼·剪刀」＋「毛绒动物」怪兽1只以上
-- ①：「魔玩具·剪刀虎」在自己场上只能有1只表侧表示存在。
-- ②：这张卡融合召唤成功时，以最多有作为这张卡的融合素材的怪兽数量的场上的卡为对象才能发动。那些卡破坏。
-- ③：只要这张卡在怪兽区域存在，自己场上的「魔玩具」怪兽的攻击力上升自己场上的「毛绒动物」怪兽以及「魔玩具」怪兽数量×300。
function c464362.initial_effect(c)
	c:SetUniqueOnField(1,0,464362)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为30068120的怪兽和满足过滤条件的1到127只怪兽作为融合素材
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
	-- 设置效果目标为属于0xad种族的怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xad))
	e3:SetValue(c464362.atkval)
	c:RegisterEffect(e3)
end
-- 判断此卡是否为融合召唤成功
function c464362.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 检测是否满足破坏效果的发动条件，即是否有至少一张场上卡片可作为对象
function c464362.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local ct=e:GetHandler():GetMaterialCount()
	if chk==0 then return ct>0
		-- 检测是否满足破坏效果的发动条件，即是否有至少一张场上卡片可作为对象
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多等于融合素材数量的场上卡片作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏操作，将选中的卡片破坏
function c464362.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标卡片组，并筛选出与当前效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡片组进行破坏处理
	Duel.Destroy(g,REASON_EFFECT)
end
-- 定义攻击力计算过滤条件，即场上表侧表示的「毛绒动物」或「魔玩具」怪兽
function c464362.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa9,0xad)
end
-- 计算满足过滤条件的怪兽数量并乘以300作为攻击力提升值
function c464362.atkval(e,c)
	-- 返回满足过滤条件的怪兽数量乘以300的结果
	return Duel.GetMatchingGroupCount(c464362.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)*300
end
