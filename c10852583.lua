--ヤジロベーダー
-- 效果：
-- ①：这张卡往中央以外的主要怪兽区域召唤·特殊召唤的场合破坏。
-- ②：1回合1次，自己主要阶段才能发动。这张卡向相邻的没有使用的主要怪兽区域移动。
-- ③：每次对方场上只有怪兽1只召唤·特殊召唤发动。那只对方怪兽的位置是和这张卡不同纵列的场合，这张卡向要往那只对方怪兽靠近的相邻的主要怪兽区域移动。那之后，和移动过的这张卡相同纵列的其他卡全部破坏。
function c10852583.initial_effect(c)
	-- ①：这张卡往中央以外的主要怪兽区域召唤·特殊召唤的场合破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c10852583.descon)
	e1:SetOperation(c10852583.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。这张卡向相邻的没有使用的主要怪兽区域移动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10852583,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c10852583.seqcon)
	e3:SetOperation(c10852583.seqop)
	c:RegisterEffect(e3)
	-- ③：每次对方场上只有怪兽1只召唤·特殊召唤发动。那只对方怪兽的位置是和这张卡不同纵列的场合，这张卡向要往那只对方怪兽靠近的相邻的主要怪兽区域移动。那之后，和移动过的这张卡相同纵列的其他卡全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(10852583,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c10852583.mvcon)
	e4:SetTarget(c10852583.mvtg)
	e4:SetOperation(c10852583.mvop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 判断是否在中央怪兽区域（序号为2）以外的位置召唤或特殊召唤
function c10852583.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSequence()~=2
end
-- 将该卡破坏
function c10852583.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行破坏操作
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 判断是否可以向相邻区域移动
function c10852583.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	if seq>4 then return false end
	-- 判断前方是否有可用区域
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 判断后方是否有可用区域
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 执行移动操作
function c10852583.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	local seq=c:GetSequence()
	if seq>4 then return end
	-- 判断前方是否有可用区域
	if (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 判断后方是否有可用区域
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1)) then
		local flag=0
		-- 设置前方区域为可选
		if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=bit.replace(flag,0x1,seq-1) end
		-- 设置后方区域为可选
		if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=bit.replace(flag,0x1,seq+1) end
		flag=bit.bxor(flag,0xff)
		-- 提示选择移动目标区域
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		-- 选择一个可用区域
		local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,flag)
		local nseq=0
		if s==1 then nseq=0
		elseif s==2 then nseq=1
		elseif s==4 then nseq=2
		elseif s==8 then nseq=3
		else nseq=4 end
		-- 将卡移动到指定区域
		Duel.MoveSequence(c,nseq)
	end
end
-- 判断对方召唤是否触发效果
function c10852583.mvcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:GetFirst():IsControler(1-tp)
end
-- 设置效果目标
function c10852583.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=eg:GetFirst()
	tc:CreateEffectRelation(e)
end
-- 执行移动和破坏操作
function c10852583.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp)
		or not tc:IsRelateToEffect(e) or tc:IsControler(tp) then return end
	local seq1=c:GetSequence()
	local seq2=tc:GetSequence()
	if seq1>4 then return end
	if seq2==5 then seq2=1 end
	if seq2==6 then seq2=3 end
	seq2=4-seq2
	-- 判断前方是否有可用区域
	if (seq1>seq2 and Duel.CheckLocation(tp,LOCATION_MZONE,seq1-1))
		-- 判断后方是否有可用区域
		or (seq1<seq2 and Duel.CheckLocation(tp,LOCATION_MZONE,seq1+1)) then
		local nseq=0
		-- 如果前方有可用区域则选择前方
		if seq1>seq2 and Duel.CheckLocation(tp,LOCATION_MZONE,seq1-1) then nseq=seq1-1
		else nseq=seq1+1 end
		-- 将卡移动到指定区域
		Duel.MoveSequence(c,nseq)
		local g=c:GetColumnGroup()
		if g:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 破坏相同纵列的其他卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
