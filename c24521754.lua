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
-- 判断此卡是否在中央怪兽区域（序号为2）以外的位置
function c24521754.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSequence()~=2
end
-- 将此卡因效果破坏
function c24521754.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡因效果破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 判断此卡是否在中央怪兽区域（序号为2）
function c24521754.atkcon(e)
	return e:GetHandler():GetSequence()==2
end
-- 判断此卡是否在主要怪兽区域（序号小于5）
function c24521754.seqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSequence()<5
end
-- 选择目标怪兽区域并计算要移动到的区域序号，然后检索该区域中所有卡并设置破坏目标
function c24521754.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
	-- 提示玩家选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 选择一个可用的怪兽区域
	local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	-- 提示玩家选择的区域
	Duel.Hint(HINT_ZONE,tp,fd)
	local seq=math.log(fd,2)
	e:SetLabel(seq)
	local pseq=c:GetSequence()
	if pseq>seq then pseq,seq=seq,pseq end
	local dg=Group.CreateGroup()
	local g=nil
	local exg=nil
	for i=pseq,seq do
		-- 获取指定区域中所有场上卡
		g=Duel.GetMatchingGroup(c24521754.seqfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,tp,i)
		dg:Merge(g)
		if i==1 or i==3 then
			-- 获取指定区域中所有额外怪兽区卡
			exg=Duel.GetMatchingGroup(c24521754.exfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c,tp,i)
			dg:Merge(exg)
		end
	end
	-- 设置连锁操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 判断指定区域中场上卡的序号是否匹配
function c24521754.seqfilter(c,tp,seq)
	if c:IsControler(tp) then
		return c:GetSequence()==seq
	else
		return c:GetSequence()==4-seq
	end
end
-- 判断指定区域中额外怪兽区卡的序号是否匹配
function c24521754.exfilter(c,tp,seq)
	if seq==1 then seq=5 end
	if seq==3 then seq=6 end
	if c:IsControler(tp) then
		return c:GetSequence()==seq
	else
		return c:GetSequence()==11-seq
	end
end
-- 处理效果发动，移动此卡位置并破坏指定区域中的卡
function c24521754.seqop(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetLabel()
	local c=e:GetHandler()
	-- 检查此卡是否仍然有效并可被移动
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not c:IsControler(tp) or not Duel.CheckLocation(tp,LOCATION_MZONE,seq) then return end
	local pseq=c:GetSequence()
	if pseq>4 then return end
	-- 将此卡移动到指定区域
	Duel.MoveSequence(c,seq)
	if c:GetSequence()==seq then
		if pseq>seq then pseq,seq=seq,pseq end
		local dg=Group.CreateGroup()
		local g=nil
		local exg=nil
		for i=pseq,seq do
			-- 获取指定区域中所有场上卡
			g=Duel.GetMatchingGroup(c24521754.seqfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,tp,i)
			dg:Merge(g)
			if i==1 or i==3 then
				-- 获取指定区域中所有额外怪兽区卡
				exg=Duel.GetMatchingGroup(c24521754.exfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c,tp,i)
				dg:Merge(exg)
			end
		end
		if dg:GetCount()>0 then
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将目标卡因效果破坏
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
