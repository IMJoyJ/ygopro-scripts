--ヴェルスパーダ・パラディオン
-- 效果：
-- 包含「圣像骑士」怪兽的效果怪兽2只
-- ①：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
-- ②：这张卡所连接区的怪兽不能攻击。
-- ③：1回合1次，这张卡所连接区有效果怪兽特殊召唤的场合，以这张卡以外的自己或者对方的主要怪兽区域1只怪兽为对象才能发动。那只怪兽的位置向其他的主要怪兽区域移动（不能向从那只怪兽来看的对方场上移动）。
function c39528955.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：作为连接素材的必须是2~99只效果怪兽，且其中至少包含1只「圣像骑士」怪兽（由matcheck额外检查），对应召唤条件“包含「圣像骑士」怪兽的效果怪兽2只”。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,99,c39528955.matcheck)
	-- 对应效果原文①：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c39528955.atkval)
	c:RegisterEffect(e1)
	-- 对应效果原文②：这张卡所连接区的怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c39528955.atklimit)
	c:RegisterEffect(e2)
	-- 对应效果原文③：1回合1次，这张卡所连接区有效果怪兽特殊召唤的场合，以这张卡以外的自己或者对方的主要怪兽区域1只怪兽为对象才能发动。那只怪兽的位置向其他的主要怪兽区域移动（不能向从那只怪兽来看的对方场上移动）。
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
-- 检查连接素材组中是否存在至少1只卡名为「圣像骑士」系列的怪兽（setname=0x116），用于满足连接召唤素材的额外条件。
function c39528955.matcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x116)
end
-- 将这张卡所连接区的表侧表示怪兽的原本攻击力求和，作为这张卡攻击力的上升数值。
function c39528955.atkval(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil)
	return g:GetSum(Card.GetBaseAttack)
end
-- 判断某只怪兽是否在这张卡所连接区，若是则该怪兽不能攻击。
function c39528955.atklimit(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 筛选条件：c是效果怪兽，并且c位于这张卡所连接区（lg包含c）。
function c39528955.seqcfilter(c,tp,lg)
	return c:IsType(TYPE_EFFECT) and lg:IsContains(c)
end
-- 触发条件：本次特殊召唤成功的怪兽组中，存在至少1只是效果怪兽且位于这张卡所连接区。
function c39528955.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c39528955.seqcfilter,1,nil,tp,lg)
end
-- 筛选可作为移动对象的怪兽：该怪兽位于主要怪兽区域（格子序号0~4），且其控制者场上仍有可用的主要怪兽区域空格。
function c39528955.seqfilter(c)
	local tp=c:GetControler()
	-- 判断该怪兽所在格是主要怪兽区域（序号<5），并且其控制者场上还有可用的主要怪兽区域空格。
	return c:GetSequence()<5 and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
end
-- 发动时的取对象处理：从双方主要怪兽区域选择1只满足移动条件且不是这张卡本身的怪兽作为对象，并给出“请选择要移动的怪兽”的提示。
function c39528955.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c39528955.seqfilter(chkc) and chkc~=c end
	-- 发动确认阶段检查是否存在至少1只满足条件的对象怪兽。
	if chk==0 then return Duel.IsExistingTarget(c39528955.seqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 向当前玩家显示“请选择要移动的怪兽”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39528955,1))  --"请选择要移动的怪兽"
	-- 让玩家从双方主要怪兽区域选择1只满足条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,c39528955.seqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
end
-- 效果处理开始：取得对象怪兽，若该怪兽已与效果失去联系、不受此效果影响，或其控制者场上没有可用空格，则本次效果处理不执行。
function c39528955.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local ttp=tc:GetControler()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e)
		-- 若对象怪兽的控制者场上没有可用的主要怪兽区域空格，则效果不处理。
		or Duel.GetLocationCount(ttp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	local p1,p2
	if tc:IsControler(tp) then
		p1=LOCATION_MZONE
		p2=0
	else
		p1=0
		p2=LOCATION_MZONE
	end
	-- 向当前玩家显示“请选择要移动到的位置”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家选择一个可用的主要怪兽区域空格，并通过取以2为底的对数将位置标记转换为格子序号seq。
	local seq=math.log(Duel.SelectDisableField(tp,1,p1,p2,0),2)
	if tc:IsControler(1-tp) then seq=seq-16 end
	-- 将对象怪兽移动到选定的主要怪兽区域格子，实现移动效果。
	Duel.MoveSequence(tc,seq)
end
