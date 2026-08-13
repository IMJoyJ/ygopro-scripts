--百景戦都ゴルディロックス
-- 效果：
-- ①：这张卡往中央以外的主要怪兽区域召唤·特殊召唤的场合破坏。
-- ②：只要这张卡在主要怪兽区域的中央存在，这张卡的攻击力上升3000。
-- ③：1回合1次，指定没有使用的自己的主要怪兽区域1处才能发动。自己的主要怪兽区域的这张卡的位置向指定的区域移动。那之后，和移动前与移动后的怪兽区域以及那些中间的怪兽区域相同纵列存在的除这张卡以外的卡全部破坏。
function c24521754.initial_effect(c)
	-- ①：这张卡往中央以外的主要怪兽区域召唤·特殊召唤的场合破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c24521754.descon)
	e1:SetOperation(c24521754.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在主要怪兽区域的中央存在，这张卡的攻击力上升3000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c24521754.atkcon)
	e3:SetValue(3000)
	c:RegisterEffect(e3)
	-- ③：1回合1次，指定没有使用的自己的主要怪兽区域1处才能发动。自己的主要怪兽区域的这张卡的位置向指定的区域移动。那之后，和移动前与移动后的怪兽区域以及那些中间的怪兽区域相同纵列存在的除这张卡以外的卡全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(24521754,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c24521754.seqcon)
	e4:SetTarget(c24521754.seqtg)
	e4:SetOperation(c24521754.seqop)
	c:RegisterEffect(e4)
end
-- 判断这张卡召唤·特殊召唤成功时是否不在中央主要怪兽区（序号不为2），满足条件则触发①的破坏效果。
function c24521754.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSequence()~=2
end
-- 将这张卡以效果原因破坏，实现①中召唤·特殊召唤到中央以外时破坏的处理。
function c24521754.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以REASON_EFFECT为原因将这张卡自身破坏，作为①的自坏效果。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 判断这张卡是否位于中央主要怪兽区（序号为2），作为②攻击力提升的条件。
function c24521754.atkcon(e)
	return e:GetHandler():GetSequence()==2
end
-- 判断这张卡是否位于自己的主要怪兽区（序号0-4，不含额外怪兽区），作为③可发动的条件之一。
function c24521754.seqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSequence()<5
end
-- ③的发动时处理：选择己方1个未使用的主要怪兽区作为移动目标并保存，同时计算原位置与目标位置之间各纵列上除自身外的卡以及中间列对应的额外怪兽区的卡，统一设为破坏对象并写入操作信息。
function c24521754.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动合法性检查：确认己方主要怪兽区存在至少1个空格，即可选择移动目的地。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
	-- 显示“请选择要移动到的位置”提示信息，引导玩家选择目标格子。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家自己从己方主要怪兽区选择1个未使用空格，返回其位置位标记，用于确定移动目标。
	local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	-- 将玩家选中的目标区域以高亮或提示形式展示给双方。
	Duel.Hint(HINT_ZONE,tp,fd)
	local seq=math.log(fd,2)
	e:SetLabel(seq)
	local pseq=c:GetSequence()
	if pseq>seq then pseq,seq=seq,pseq end
	local dg=Group.CreateGroup()
	local g=nil
	local exg=nil
	for i=pseq,seq do
		-- 检索纵列seq上除该卡以外的所有场上卡牌（含怪兽与魔陷，包含双方场上），用于确定将被破坏的对象。
		g=Duel.GetMatchingGroup(c24521754.seqfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,tp,i)
		dg:Merge(g)
		if i==1 or i==3 then
			-- 检索中间纵列对应的额外怪兽区上存在的卡（如额外怪兽区的连接怪兽），将这些额外区的卡也纳入破坏对象。
			exg=Duel.GetMatchingGroup(c24521754.exfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c,tp,i)
			dg:Merge(exg)
		end
	end
	-- 将已收集的破坏对象组dg及其数量登记到当前连锁的操作信息中，使其他卡能正确响应这次破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 过滤函数：判断卡c是否位于指定纵列seq；若属于对方控制，则按镜像位置4-seq判断，以实现同列判定。
function c24521754.seqfilter(c,tp,seq)
	if c:IsControler(tp) then
		return c:GetSequence()==seq
	else
		return c:GetSequence()==4-seq
	end
end
-- 过滤函数：将中间纵列1/3映射到额外怪兽区5/6，判断卡c是否在同列的额外怪兽区上；对方控制时按镜像位置11-seq判断。
function c24521754.exfilter(c,tp,seq)
	if seq==1 then seq=5 end
	if seq==3 then seq=6 end
	if c:IsControler(tp) then
		return c:GetSequence()==seq
	else
		return c:GetSequence()==11-seq
	end
end
-- ③的处理：先检查该卡仍能移动、目标区可用，然后将其移动到指定区域；若移动成功，再获取原位置与目标位置之间各纵列（含中间列对应的额外怪兽区）上除该卡以外的所有卡，并在此之后进行破坏。
function c24521754.seqop(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetLabel()
	local c=e:GetHandler()
	-- 效果处理时的合法性检查：若该卡已与效果失去联系、免疫此效果、控制权转移或目标区域不可用，则本次效果不处理。
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not c:IsControler(tp) or not Duel.CheckLocation(tp,LOCATION_MZONE,seq) then return end
	local pseq=c:GetSequence()
	if pseq>4 then return end
	-- 将这张卡的场上序号改为目标格子，即执行移动到指定主要怪兽区的操作。
	Duel.MoveSequence(c,seq)
	if c:GetSequence()==seq then
		if pseq>seq then pseq,seq=seq,pseq end
		local dg=Group.CreateGroup()
		local g=nil
		local exg=nil
		for i=pseq,seq do
			-- 移动成功后，再次获得原位置与目标位置之间每个纵列上除该卡以外的所有场上卡，作为实际破坏对象。
			g=Duel.GetMatchingGroup(c24521754.seqfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,tp,i)
			dg:Merge(g)
			if i==1 or i==3 then
				-- 移动成功后，将中间纵列对应的额外怪兽区上的卡也加入破坏对象集合。
				exg=Duel.GetMatchingGroup(c24521754.exfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c,tp,i)
				dg:Merge(exg)
			end
		end
		if dg:GetCount()>0 then
			-- 中断当前效果链，使后续的破坏处理成为一个独立时点，对应“那之后”的语义，同时避免与移动产生同时时点。
			Duel.BreakEffect()
			-- 以效果原因把收集到的对象全部破坏，完成③的“相同纵列存在的除这张卡以外的卡全部破坏”处理。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
