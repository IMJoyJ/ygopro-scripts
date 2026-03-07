--ヴェルスパーダ・パラディオン
-- 效果：
-- 包含「圣像骑士」怪兽的效果怪兽2只
-- ①：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
-- ②：这张卡所连接区的怪兽不能攻击。
-- ③：1回合1次，这张卡所连接区有效果怪兽特殊召唤的场合，以这张卡以外的自己或者对方的主要怪兽区域1只怪兽为对象才能发动。那只怪兽的位置向其他的主要怪兽区域移动（不能向从那只怪兽来看的对方场上移动）。
function c39528955.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用至少2张且至多99张满足类型为效果怪兽的连接素材，并且这些素材中必须包含「圣像骑士」卡组的怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,99,c39528955.matcheck)
	-- ①：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c39528955.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c39528955.atklimit)
	c:RegisterEffect(e2)
	-- ③：1回合1次，这张卡所连接区有效果怪兽特殊召唤的场合，以这张卡以外的自己或者对方的主要怪兽区域1只怪兽为对象才能发动。那只怪兽的位置向其他的主要怪兽区域移动（不能向从那只怪兽来看的对方场上移动）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39528955,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c39528955.seqcon)
	e3:SetTarget(c39528955.seqtg)
	e3:SetOperation(c39528955.seqop)
	c:RegisterEffect(e3)
end
-- 检查连接素材中是否包含「圣像骑士」卡组的怪兽
function c39528955.matcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x116)
end
-- 计算连接区中所有正面表示怪兽的原本攻击力总和，作为此卡攻击力的增加量
function c39528955.atkval(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil)
	return g:GetSum(Card.GetBaseAttack)
end
-- 判断目标怪兽是否在连接区中，若是则不能攻击
function c39528955.atklimit(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 筛选出连接区中类型为效果怪兽的怪兽
function c39528955.seqcfilter(c,tp,lg)
	return c:IsType(TYPE_EFFECT) and lg:IsContains(c)
end
-- 判断是否有连接区中的效果怪兽被特殊召唤成功
function c39528955.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c39528955.seqcfilter,1,nil,tp,lg)
end
-- 筛选出可以移动的目标怪兽，即在主要怪兽区且有空位
function c39528955.seqfilter(c)
	local tp=c:GetControler()
	-- 判断目标怪兽是否在主要怪兽区且有空位
	return c:GetSequence()<5 and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
end
-- 选择目标怪兽，要求其在主要怪兽区且满足移动条件
function c39528955.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c39528955.seqfilter(chkc) and chkc~=c end
	-- 判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c39528955.seqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 提示玩家选择要移动的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39528955,1))  --"请选择要移动的怪兽"
	-- 选择满足条件的怪兽作为目标
	Duel.SelectTarget(tp,c39528955.seqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
end
-- 处理效果发动后的操作，获取目标怪兽并进行有效性判断
function c39528955.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	local ttp=tc:GetControler()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e)
		-- 判断目标怪兽是否仍然存在于场上且未被无效化，以及是否有足够的空位
		or Duel.GetLocationCount(ttp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	local p1,p2
	if tc:IsControler(tp) then
		p1=LOCATION_MZONE
		p2=0
	else
		p1=0
		p2=LOCATION_MZONE
	end
	-- 提示玩家选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 选择一个可用的空位作为移动目标
	local seq=math.log(Duel.SelectDisableField(tp,1,p1,p2,0),2)
	if tc:IsControler(1-tp) then seq=seq-16 end
	-- 将目标怪兽移动到指定位置
	Duel.MoveSequence(tc,seq)
end
