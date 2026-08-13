--寝ガエル
-- 效果：
-- 这张卡不能作为融合·同调·超量·连接召唤的素材。
-- ①：这张卡召唤·反转召唤成功的场合发动。这张卡变成守备表示。
-- ②：1回合1次，以对方的主要怪兽区域1只怪兽为对象才能发动。守备表示的这张卡向作为对象的对方怪兽的相邻的怪兽区域转移控制权。那之后，对方的主要怪兽区域的「寝青蛙」只有2只的场合，得到那2只的中间存在的全部怪兽的控制权。
function c47346782.initial_effect(c)
	-- 这张卡不能作为融合·同调·超量·连接召唤的素材。
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
	-- ①：这张卡召唤·反转召唤成功的场合发动。这张卡变成守备表示。
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
-- 融合素材限制的判定函数：仅当被用作素材的召唤方式为融合召唤时返回true，使这张卡不能作为融合素材。
function c47346782.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- ①效果的发动判定：召唤·反转召唤成功时必然满足发动条件，并登记本效果将改变自身表示形式。
function c47346782.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	-- 设置操作信息，标明本效果处理时将对这张卡进行表示形式变更（变为守备表示）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联且当前为攻击表示，则将其变更为表侧守备表示。
function c47346782.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将这张卡的表示形式变更为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 筛选可以被选为对象的对方怪兽：必须位于对方主要怪兽区域（序号0-4），且其左侧或右侧相邻的主要怪兽区域有可用空格（供这张卡转移过去）。
function c47346782.ctfilter1(c,tp)
	local seq=c:GetSequence()
	if seq>4 then return false end
	-- 检查对象怪兽左侧（seq>0）是否存在相邻空格，有则满足可转移条件之一。
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 检查对象怪兽右侧（seq<4）是否存在相邻空格，有则满足可转移条件之一。
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- ②效果的发动条件与取对象判定：选择对方主要怪兽区域1只满足相邻空格条件的怪兽为对象，同时要求这张「寝青蛙」的控制权可以转移。
function c47346782.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c47346782.ctfilter1(chkc,1-tp) end
	-- 发动检查：对方主要怪兽区域存在至少1只满足条件的对象，且这张卡自身控制权可以被改变。
	if chk==0 then return Duel.IsExistingTarget(c47346782.ctfilter1,tp,0,LOCATION_MZONE,1,nil,1-tp)
		and e:GetHandler():IsControlerCanBeChanged() end
	-- 向操作玩家显示“请选择要改变控制权的怪兽”的提示，用于选择对象时的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方主要怪兽区域1只符合条件的怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c47346782.ctfilter1,tp,0,LOCATION_MZONE,1,1,nil,1-tp)
	-- 设置操作信息，标明本效果处理时将改变这张卡的控制权。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 筛选对方主要怪兽区域中表侧表示且卡名为「寝青蛙」的怪兽，用于后续判断其数量是否为2只。
function c47346782.ctfilter2(c)
	return c:GetSequence()<5 and c:IsFaceup() and c:IsCode(47346782)
end
-- 筛选位于两只「寝青蛙」所在区域序号之间、且控制权可以被变更的全部怪兽。
function c47346782.ctfilter3(c,seq1,seq2)
	local seq=c:GetSequence()
	return seq>seq1 and seq<seq2 and c:IsControlerCanBeChanged()
end
-- ②效果处理：将这张卡转移到对象怪兽相邻的空区域；成功后若对方主要怪兽区域表侧表示的「寝青蛙」恰好为2只，则获得这两只之间全部怪兽的控制权。
function c47346782.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or not c:IsPosition(POS_FACEUP_DEFENSE) then return end
	-- 取得本效果发动时选择的那只对方怪兽作为处理对象。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not tc:IsControler(1-tp) then return end
	local seq=tc:GetSequence()
	if seq>4 then return end
	-- 判断对象怪兽左侧区域（seq-1）是否有空格，以决定这张卡能否转移到左侧。
	if (seq>0 and Duel.CheckLocation(1-tp,LOCATION_MZONE,seq-1))
		-- 判断对象怪兽右侧区域（seq+1）是否有空格，以决定这张卡能否转移到右侧。
		or (seq<4 and Duel.CheckLocation(1-tp,LOCATION_MZONE,seq+1)) then
		local zone=0
		-- 若左侧相邻区域可用，则将可转移区域zone的第seq-1位设为1，指定转移到左侧格。
		if seq>0 and Duel.CheckLocation(1-tp,LOCATION_MZONE,seq-1) then zone=bit.replace(zone,0x1,seq-1) end
		-- 若右侧相邻区域可用，则将可转移区域zone的第seq+1位设为1，指定转移到右侧格。
		if seq<4 and Duel.CheckLocation(1-tp,LOCATION_MZONE,seq+1) then zone=bit.replace(zone,0x1,seq+1) end
		-- 尝试将这张「寝青蛙」的控制权转移给对方玩家，且只能转移到指定的相邻空位；若转移失败则结束处理。
		if Duel.GetControl(c,1-tp,0,0,zone)==0 then return end
		-- 获取对方主要怪兽区域所有表侧表示且卡名为「寝青蛙」的怪兽集合。
		local g1=Duel.GetMatchingGroup(c47346782.ctfilter2,tp,0,LOCATION_MZONE,nil)
		if g1:GetCount()==2 then
			local seq1=g1:GetFirst():GetSequence()
			local seq2=g1:GetNext():GetSequence()
			if seq1>seq2 then seq1,seq2=seq2,seq1 end
			-- 获取位于两只「寝青蛙」所在位置之间、且控制权可以被变更的全部怪兽集合。
			local g2=Duel.GetMatchingGroup(c47346782.ctfilter3,tp,0,LOCATION_MZONE,nil,seq1,seq2)
			if g2:GetCount()>0 then
				-- 中断当前效果链，使后续获得中间怪兽控制权的处理与前一步控制权转移不在同一时点（错开时点）。
				Duel.BreakEffect()
				-- 使自己获得这些中间怪兽的控制权。
				Duel.GetControl(g2,tp)
			end
		end
	end
end
