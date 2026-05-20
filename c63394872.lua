--ポジションチェンジ
-- 效果：
-- ①：1回合1次，以自己的主要怪兽区域1只怪兽为对象，指定那相邻的没有使用的怪兽区域1处才能发动。那只自己怪兽的位置向相邻的指定的区域移动。
function c63394872.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己的主要怪兽区域1只怪兽为对象，指定那相邻的没有使用的怪兽区域1处才能发动。那只自己怪兽的位置向相邻的指定的区域移动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63394872,0))  --"位置移动"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c63394872.seqtg)
	e2:SetOperation(c63394872.seqop)
	c:RegisterEffect(e2)
end
-- 过滤出位于主要怪兽区域，且其左侧或右侧相邻的怪兽区域为空置状态的怪兽
function c63394872.filter(c,tp)
	local seq=c:GetSequence()
	if seq>4 then return false end
	-- 检查该怪兽是否不在最左侧（序号大于0）且其左侧相邻的怪兽区域为空置状态
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 或者该怪兽是否不在最右侧（序号小于4）且其右侧相邻的怪兽区域为空置状态
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 用于重构对象（成为效果对象）时的过滤函数，判断怪兽是否在主要怪兽区域且与指定的目标区域相邻
function c63394872.chkfilter(c,cseq)
	local seq=c:GetSequence()
	return seq<5 and math.abs(seq-cseq)==1
end
-- 效果发动的Target（目标过滤与选择）函数，处理选择己方主要怪兽区域的一只怪兽以及指定其相邻的空置怪兽区域
function c63394872.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c63394872.chkfilter(chkc,e:GetLabel()) end
	-- 在发动效果的准备阶段，检查自己场上是否存在至少一只符合“相邻格子有空位”条件的主要怪兽区域怪兽
	if chk==0 then return Duel.IsExistingTarget(c63394872.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要移动位置的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(63394872,1))  --"请选择移动位置的怪兽"
	-- 让玩家选择自己主要怪兽区域的一只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c63394872.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local seq=g:GetFirst():GetSequence()
	local flag=0
	-- 如果所选怪兽不在最左侧且其左侧相邻格子为空，则将左侧格子的位置标记加入可选标记中
	if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
	-- 如果所选怪兽不在最右侧且其右侧相邻格子为空，则将右侧格子的位置标记加入可选标记中
	if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
	-- 提示玩家选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家在刚才计算出的可选相邻空置格子（通过对flag取反来限定可选格子）中选择一个位置
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~flag)
	local nseq=math.log(s,2)
	e:SetLabel(nseq)
	-- 在界面上高亮显示玩家选择的移动目标区域
	Duel.Hint(HINT_ZONE,tp,s)
end
-- 效果发动的Operation（操作执行）函数，将作为对象的怪兽移动到指定的相邻怪兽区域
function c63394872.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	local seq=e:GetLabel()
	local tseq=tc:GetSequence()
	-- 检查该怪兽是否仍在该效果的对象中、控制权未发生改变、仍在主要怪兽区域、与目标区域相邻，且目标区域仍为空置状态，若不满足则不处理
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tseq>4 or math.abs(tseq-seq)~=1 or not Duel.CheckLocation(tp,LOCATION_MZONE,seq) then return end
	-- 将该怪兽移动到指定的相邻怪兽区域
	Duel.MoveSequence(tc,seq)
end
