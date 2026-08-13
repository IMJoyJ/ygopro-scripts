--キャッスル・リンク
-- 效果：
-- ①：1回合1次，自己主要阶段以场上1只连接怪兽为对象才能发动。那只怪兽的位置向那只怪兽所连接区的主要怪兽区域移动（不能向从那只怪兽来看的对方场上移动）。
-- ②：1回合1次，自己主要阶段才能发动。选自己的主要怪兽区域2只连接怪兽或者对方的主要怪兽区域2只连接怪兽，那些位置交换。
function c22198672.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段以场上1只连接怪兽为对象才能发动。那只怪兽的位置向那只怪兽所连接区的主要怪兽区域移动（不能向从那只怪兽来看的对方场上移动）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22198672,0))  --"移动位置"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c22198672.seqtg)
	e2:SetOperation(c22198672.seqop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。选自己的主要怪兽区域2只连接怪兽或者对方的主要怪兽区域2只连接怪兽，那些位置交换。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22198672,1))  --"交换位置"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c22198672.chtg)
	e3:SetOperation(c22198672.chop)
	c:RegisterEffect(e3)
end
-- 判断一张怪兽能否作为①效果移动的对象：必须是连接怪兽，且其控制者场上存在与该怪兽连接区对应的可用主要怪兽区域空格。
function c22198672.filter(c)
	if not c:IsType(TYPE_LINK) then return false end
	local p=c:GetControler()
	local zone=c:GetLinkedZone()&0x1f
	-- 计算该连接怪兽控制者的主要怪兽区域中，由该怪兽连接区所指向的区域（仅主怪兽区0-4）是否存在至少1个可用空格，用于判定能否移动。
	return Duel.GetLocationCount(p,LOCATION_MZONE,PLAYER_NONE,0,zone)>0
end
-- ①效果发动时选择对象的处理：先检查是否存在可成为对象的连接怪兽，然后让玩家从双方主要怪兽区域选择1只满足filter的连接怪兽作为效果对象。
function c22198672.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c22198672.filter(chkc) end
	-- 发动合法性检查：确认场上（自己或对方的主要怪兽区域）存在至少1只满足filter条件且能够成为本效果对象的连接怪兽。
	if chk==0 then return Duel.IsExistingTarget(c22198672.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示文字'请选择要移动位置的怪兽'，并缓存用于卡片选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(22198672,2))  --"请选择要移动位置的怪兽"
	-- 让玩家从双方主要怪兽区域选择1只满足filter的连接怪兽，将其设为效果对象（并建立效果关联）。
	Duel.SelectTarget(tp,c22198672.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ①效果处理：取得对象怪兽后，检查其连接区对应的主怪兽区域仍可用，然后让玩家从这些格子中选择一个，将对象怪兽移动到该位置；若对象怪兽控制者为对方，需要将格子位偏移到对方场区域。
function c22198672.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中选定的那1只对象怪兽（即①效果要移动的连接怪兽）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local p=tc:GetControler()
	local zone=tc:GetLinkedZone(p)&0x1f
	-- 效果处理时再确认：该对象怪兽的连接区所指向的主要怪兽区域中仍有可用空格，若因其他效果导致无空格，则不执行移动。
	if Duel.GetLocationCount(p,LOCATION_MZONE,PLAYER_NONE,0,zone)>0 then
		local i=0
		if p~=tp then i=16 end
		-- 显示选择目标位置的提示（HINTMSG_TOZONE），进入选格子的界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
		-- 调用SelectDisableField让玩家在对象怪兽连接区对应的主怪兽区空格中选择1个可移动位置，返回该位置的位标记；~(zone<<i) 用于将非目标区域设为不可选，i是为了适配对方场地的位置偏移。
		local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,~(zone<<i))
		local nseq=math.log(s,2)-i
		-- 将对象怪兽移动到计算出的目标序号（nseq）所在的主要怪兽区域，完成位置移动。
		Duel.MoveSequence(tc,nseq)
	end
end
-- 判断能否作为②效果的第一只交换对象：是连接怪兽、位于主要怪兽区域（主怪兽区0-4），且其控制者的主要怪兽区域还存在另一只可交换的连接怪兽（由chfilter2筛选）。
function c22198672.chfilter1(c)
	return c:IsType(TYPE_LINK) and c:GetSequence()<5
		-- 在c的控制者的主要怪兽区域中检索是否存在至少1只除c以外的连接怪兽（chfilter2），用于保证该玩家场上凑齐同一控制者的2只连接怪兽。
		and Duel.IsExistingMatchingCard(c22198672.chfilter2,c:GetControler(),LOCATION_MZONE,0,1,c)
end
-- 判断是否可作为第二只交换对象：是连接怪兽、位于主要怪兽区域（主怪兽区0-4，排除额外怪兽区）。
function c22198672.chfilter2(c)
	return c:IsType(TYPE_LINK) and c:GetSequence()<5
end
-- ②效果发动条件检测：检查场上（自己或对方的主要怪兽区域）是否存在至少一组（2只连接怪兽）满足交换条件。该效果不取对象，所以不进行目标选择。
function c22198672.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：通过chfilter1判断是否存在至少1只满足条件的连接怪兽（其控制者还有另一只可交换连接怪兽），即存在可应用的交换组合。
	if chk==0 then return Duel.IsExistingMatchingCard(c22198672.chfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- ②效果处理：先由发动者选择第一只连接怪兽（需其控制者场上还有第二只可交换的），再选择同一控制者场上的另一只连接怪兽，最后交换两只怪兽的位置。
function c22198672.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择第一只怪兽的提示（HINTMSG_CONTROL，此处实际用于位置交换选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让发动者从双方主要怪兽区域选择1只满足chfilter1的连接怪兽作为第一只交换对象。
	local g1=Duel.SelectMatchingCard(tp,c22198672.chfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc1=g1:GetFirst()
	if not tc1 then return end
	-- 显示第一只被选中的怪兽的选中动画，并标记该卡已作为选择对象。
	Duel.HintSelection(g1)
	-- 显示选择第二只怪兽的提示（HINTMSG_CONTROL，此处实际用于位置交换选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让发动者从第一只怪兽控制者的主要怪兽区域选择1只除第一只外的、满足chfilter2的连接怪兽作为第二只交换对象，确保两只怪兽在同一玩家场上。
	local g2=Duel.SelectMatchingCard(tp,c22198672.chfilter2,tc1:GetControler(),LOCATION_MZONE,0,1,1,tc1)
	-- 显示第二只被选中的怪兽的选中动画。
	Duel.HintSelection(g2)
	local tc2=g2:GetFirst()
	-- 交换tc1和tc2两只怪兽在场上的位置（不改变控制权）。
	Duel.SwapSequence(tc1,tc2)
end
