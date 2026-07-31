--Angelechy Enlisted
local s,id,o=GetID()
-- 初始化卡片效果：注册同调召唤手续、①除外怪兽转移控制权起动效果、②控制权变更特召额外卡组怪兽诱发效果
function s.initial_effect(c)
	-- 设定同调召唤手续：调整+1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽除外。那之后，这张卡的控制权转移给对方。
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
	-- ②：场上的这张卡的控制权变更的场合才能发动。这张卡回到额外卡组。那之后，可以从额外卡组把1只「Angelechy」怪兽特殊召唤。
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
-- 除外与控制权转移目标过滤条件：对方怪兽区离此卡镜像相邻位置且可除外，且对方在转移位置有空怪兽区
function s.rmfilter(c,ec,tp)
	-- 获取目标怪兽在场上的位置序号
	local seq1=aux.MZoneSequence(c:GetSequence())
	-- 获取自身在场上的位置序号
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
		-- 检查对方指定区域是否有可转移控制权的空怪兽区
		and Duel.GetMZoneCount(1-tp,c,1-tp,LOCATION_REASON_CONTROL,zone)>0
end
-- ①效果发动准备：选择对方场上1只怪兽作为对象，设置除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc,c,tp) end
	-- 发动条件检查：对方场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE,1,nil,c,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方场上选择1只满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil,c,tp)
	-- 设置连锁操作信息：除外选中的目标怪兽1张
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果处理：除外目标怪兽并转移此卡的控制权
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁关联的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER)
		-- 将目标怪兽表侧表示除外，成功时继续处理
		and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0
		and c:IsRelateToChain() then
		-- 计算转移到对方场上的镜像位置序号
		local seq=4-aux.MZoneSequence(c:GetSequence())
		local zone=0
		if seq>0 then
			zone=bit.bor(zone,1<<(seq-1))
		end
		if seq<4 then
			zone=bit.bor(zone,1<<(seq+1))
		end
		-- 将此卡的控制权转移给对方指定的位置
		Duel.GetControl(c,1-tp,0,0,zone)
	end
end
-- ②效果发动条件：此卡在场上且控制权发生变更
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	return eg:IsContains(c) and c:IsFaceup()
end
-- 额外卡组特召过滤条件：字段0x1e2（Angelechy）怪兽且可特殊召唤
function s.spfilter(c,e,tp,cp)
	return c:IsSetCard(0x1e2) and c:IsCanBeSpecialSummoned(e,0,cp,false,false,POS_FACEUP,cp)
		-- 检查从额外卡组特殊召唤怪兽所需的格子数量
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果发动准备：设置从额外卡组特殊召唤卡片的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 设置连锁操作信息：从额外卡组特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,c:GetOwner(),LOCATION_EXTRA)
end
-- ②效果处理：将此卡返回额外卡组并从额外卡组特殊召唤怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将此卡返回卡组/额外卡组，成功时继续处理
	if c:IsRelateToChain() and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_EXTRA) then
		local p=c:GetOwner()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足条件的「Angelechy」怪兽
		local g=Duel.SelectMatchingCard(p,s.spfilter,p,LOCATION_EXTRA,0,1,1,nil,e,p,p)
		if g:GetCount()>0 then
			-- 中断效果处理（前后为非同时处理）
			Duel.BreakEffect()
			-- 将选中的怪兽表侧表示特殊召唤
			Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)
		end
	end
end
