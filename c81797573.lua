--Angelechy Enlisted
local s,id,o=GetID()
-- 初始化效果，添加同调召唤手续，注册除外对方并转移控制权的起动效果，以及控制权变更时弹回额外并特召卡组怪兽的必发诱发效果
function s.initial_effect(c)
	-- 为这张卡添加需要1只调整以外的怪兽为素材的同调召唤手续
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- 自己的主要阶段才能发动。以对方怪兽区域1只和这张卡相邻的怪兽为对象；那只怪兽除外，这张卡的控制权转移给对方。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- 这张卡的控制权转移的场合必定发动。这张卡回到额外卡组，从自己的额外卡组把1只「Angelechy」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CONTROL_CHANGED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 计算自身所处的反向格子，判断对象是否与自身相邻，并且能够被除外，并且对方在转移所需的相应位置有空位
function s.rmfilter(c,ec,tp)
	-- 获取待判定怪兽所处的怪兽区序号
	local seq1=aux.MZoneSequence(c:GetSequence())
	-- 获取这张卡本身所处的怪兽区序号
	local seq2=aux.MZoneSequence(ec:GetSequence())
	local seq3=4-seq2
	local zone=0
	if seq3>0 then
		zone=bit.bor(zone,1<<(seq3-1))
	end
	if seq3<4 then
		zone=bit.bor(zone,1<<(seq3+1))
	end
	return math.abs(4-seq1-seq2)==1 and c:IsAbleToRemove()
		-- 并且对方场上存在能够用来转移控制权的指定相邻怪兽区域空位
		and Duel.GetMZoneCount(1-tp,c,1-tp,LOCATION_REASON_CONTROL,zone)>0
end
-- 选取对象阶段：判断是否存在满足相邻除外且自身可转移控制权条件的目标，有则选择1个目标，并设置除外的操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc,c,tp) end
	-- 检查对方场上是否存在满足相邻条件的怪兽对象
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE,1,nil,c,tp) end
	-- 给玩家发送提示：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1只满足相邻除外条件的对方怪兽作为对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil,c,tp)
	-- 设定操作信息：将选中的目标怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行阶段：成功除外对象怪兽后，将自身控制权转移到被除外怪兽原本相邻的可用格子
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁所选择的唯一对象怪兽卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER)
		-- 并且确保该怪兽被效果成功除外（返回值不为0）
		and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0
		and c:IsRelateToChain() then
		-- 获取这张卡对于对方而言的怪兽区序号，用于计算应当转移至的相邻格子
		local seq=4-aux.MZoneSequence(c:GetSequence())
		local zone=0
		if seq>0 then
			zone=bit.bor(zone,1<<(seq-1))
		end
		if seq<4 then
			zone=bit.bor(zone,1<<(seq+1))
		end
		-- 将这张卡的控制权转移给对方，放置在事先计算好的指定区域
		Duel.GetControl(c,1-tp,0,0,zone)
	end
end
-- 判断这张卡的控制权是否发生变更，并且依然表侧表示存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	return eg:IsContains(c) and c:IsFaceup()
end
-- 过滤条件：属于「Angelechy」字段，且可以被特殊召唤，且场上有提供给额外卡组怪兽出场的空位
function s.spfilter(c,e,tp,cp)
	return c:IsSetCard(0x1e2) and c:IsCanBeSpecialSummoned(e,0,cp,false,false,POS_FACEUP,cp)
		-- 并且检查如果以这张卡离场为前提，场上是否有让额外卡组怪兽出场的空位
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 检查条件后设定操作信息：将自身弹回额外卡组，之后特殊召唤1只怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 设定操作信息：将这张卡返回持有者的额外卡组，同时设定包含特殊召唤的预备处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,c:GetOwner(),LOCATION_EXTRA)
end
-- 执行阶段：自身回到额外卡组后，从额外卡组选择1只符合条件的同系列怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡与连锁关联，且成功返回了额外卡组
	if c:IsRelateToChain() and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_EXTRA) then
		local p=c:GetOwner()
		-- 给原控制者发送提示：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 原控制者从额外卡组选择1只符合特殊召唤条件的「Angelechy」怪兽
		local g=Duel.SelectMatchingCard(p,s.spfilter,p,LOCATION_EXTRA,0,1,1,nil,e,p,p)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续的特殊召唤视为不同时发生，用于调整时点
			Duel.BreakEffect()
			-- 将选中的怪兽表侧表示特殊召唤到原控制者场上
			Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)
		end
	end
end
