--寝ガエル
-- 效果：
-- 这张卡不能作为融合·同调·超量·连接召唤的素材。
-- ①：这张卡召唤·反转召唤成功的场合发动。这张卡变成守备表示。
-- ②：1回合1次，以对方的主要怪兽区域1只怪兽为对象才能发动。守备表示的这张卡向作为对象的对方怪兽的相邻的怪兽区域转移控制权。那之后，对方的主要怪兽区域的「寝青蛙」只有2只的场合，得到那2只的中间存在的全部怪兽的控制权。
function c47346782.initial_effect(c)
	-- 这张卡不能作为融合召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(c47346782.fuslimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e4)
	-- ①：这张卡召唤成功的场合发动。这张卡变成守备表示。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(47346782,0))
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetTarget(c47346782.postg)
	e5:SetOperation(c47346782.posop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e6)
	-- ②：1回合1次，以对方的主要怪兽区域1只怪兽为对象才能发动。守备表示的这张卡向作为对象的对方怪兽的相邻的怪兽区域转移控制权。那之后，对方的主要怪兽区域的「寝青蛙」只有2只的场合，得到那2只的中间存在的全部怪兽的控制权。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(47346782,1))
	e7:SetCategory(CATEGORY_CONTROL)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetTarget(c47346782.cttg)
	e7:SetOperation(c47346782.ctop)
	c:RegisterEffect(e7)
end
-- 判断是否为融合召唤类型。
function c47346782.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 设置连锁操作信息为改变表示形式。
function c47346782.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	-- 设置连锁操作信息为改变表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 将自身从攻击表示变为守备表示。
function c47346782.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将自身从攻击表示变为守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 判断目标怪兽是否能作为控制权转移的目标。
function c47346782.ctfilter1(c,tp)
	local seq=c:GetSequence()
	if seq>4 then return false end
	-- 判断目标怪兽左侧区域是否为空。
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 判断目标怪兽右侧区域是否为空。
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 设置连锁操作信息为改变控制权。
function c47346782.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c47346782.ctfilter1(chkc,1-tp) end
	-- 检索满足条件的对方怪兽。
	if chk==0 then return Duel.IsExistingTarget(c47346782.ctfilter1,tp,0,LOCATION_MZONE,1,nil,1-tp)
		and e:GetHandler():IsControlerCanBeChanged() end
	-- 提示玩家选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择一个满足条件的对方怪兽作为目标。
	local g=Duel.SelectTarget(tp,c47346782.ctfilter1,tp,0,LOCATION_MZONE,1,1,nil,1-tp)
	-- 设置连锁操作信息为改变控制权。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 筛选场上的「寝青蛙」。
function c47346782.ctfilter2(c)
	return c:GetSequence()<5 and c:IsFaceup() and c:IsCode(47346782)
end
-- 筛选位于两隻「寝青蛙」之间的怪兽。
function c47346782.ctfilter3(c,seq1,seq2)
	local seq=c:GetSequence()
	return seq>seq1 and seq<seq2 and c:IsControlerCanBeChanged()
end
-- 执行控制权转移效果。
function c47346782.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or not c:IsPosition(POS_FACEUP_DEFENSE) then return end
	-- 获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not tc:IsControler(1-tp) then return end
	local seq=tc:GetSequence()
	if seq>4 then return end
	-- 判断目标怪兽左侧区域是否为空。
	if (seq>0 and Duel.CheckLocation(1-tp,LOCATION_MZONE,seq-1))
		-- 判断目标怪兽右侧区域是否为空。
		or (seq<4 and Duel.CheckLocation(1-tp,LOCATION_MZONE,seq+1)) then
		local zone=0
		-- 设置可移动到的区域为左侧。
		if seq>0 and Duel.CheckLocation(1-tp,LOCATION_MZONE,seq-1) then zone=bit.replace(zone,0x1,seq-1) end
		-- 设置可移动到的区域为右侧。
		if seq<4 and Duel.CheckLocation(1-tp,LOCATION_MZONE,seq+1) then zone=bit.replace(zone,0x1,seq+1) end
		-- 尝试将自身转移控制权给对方。
		if Duel.GetControl(c,1-tp,0,0,zone)==0 then return end
		-- 获取场上的所有「寝青蛙」。
		local g1=Duel.GetMatchingGroup(c47346782.ctfilter2,tp,0,LOCATION_MZONE,nil)
		if g1:GetCount()==2 then
			local seq1=g1:GetFirst():GetSequence()
			local seq2=g1:GetNext():GetSequence()
			if seq1>seq2 then seq1,seq2=seq2,seq1 end
			-- 获取两隻「寝青蛙」之间的所有怪兽。
			local g2=Duel.GetMatchingGroup(c47346782.ctfilter3,tp,0,LOCATION_MZONE,nil,seq1,seq2)
			if g2:GetCount()>0 then
				-- 中断当前效果处理。
				Duel.BreakEffect()
				-- 获得中间怪兽的控制权。
				Duel.GetControl(g2,tp)
			end
		end
	end
end
