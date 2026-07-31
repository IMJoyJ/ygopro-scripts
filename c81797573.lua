--Angelechy Enlisted
local s,id,o=GetID()
-- 初始化卡片效果：注册同调召唤手续、①除外对手怪兽并转移自身控制权、②控制权转移时回额外特召「安杰莱琪」怪兽效果
function s.initial_effect(c)
	-- 同调召唤手续：调整+调整以外的怪兽1只
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽除外，这张卡的控制权转移给对方。
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
	-- ②：场上的卡控制权变更的场合发动。这张卡回到额外卡组，从额外卡组把1只「安杰莱琪」怪兽特殊召唤。
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
-- 除外及转移控制权过滤条件：对方场上与自身位置相邻的怪兽且可除外，且转移后对方场上有空置区域
function s.rmfilter(c,ec,tp)
	-- 获取目标怪兽的怪兽区域序号
	local seq1=aux.MZoneSequence(c:GetSequence())
	-- 获取自身怪兽的怪兽区域序号
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
		-- 检查对方场上指定区域是否有空位接收控制权转移
		and Duel.GetMZoneCount(1-tp,c,1-tp,LOCATION_REASON_CONTROL,zone)>0
end
-- ①效果发动准备：选择对方场上相邻位置的1只怪兽为对象并设置除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc,c,tp) end
	-- 发动条件检查：对方场上是否存在满足条件的相邻怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE,1,nil,c,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil,c,tp)
	-- 设置连锁操作信息：除外目标怪兽1只
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果处理：除外目标怪兽并将自身控制权转移给对方
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁设定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER)
		-- 将目标怪兽表侧表示除外
		and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0
		and c:IsRelateToChain() then
		-- 计算自身转移到对方场上后对应的相邻格子区域
		local seq=4-aux.MZoneSequence(c:GetSequence())
		local zone=0
		if seq>0 then
			zone=bit.bor(zone,1<<(seq-1))
		end
		if seq<4 then
			zone=bit.bor(zone,1<<(seq+1))
		end
		-- 将自身控制权转移给对方
		Duel.GetControl(c,1-tp,0,0,zone)
	end
end
-- ②效果发动条件：控制权变更的卡中包含表侧表示的此卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	return eg:IsContains(c) and c:IsFaceup()
end
-- 特召过滤条件：从额外卡组可特殊召唤的「安杰莱琪」怪兽
function s.spfilter(c,e,tp,cp)
	return c:IsSetCard(0x1e2) and c:IsCanBeSpecialSummoned(e,0,cp,false,false,POS_FACEUP,cp)
		-- 检查额外卡组怪兽区域是否有空位
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果发动准备：设置自身回到额外卡组并特召怪兽的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 设置连锁操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,c:GetOwner(),LOCATION_EXTRA)
end
-- ②效果处理：自身洗回额外卡组并从额外卡组特殊召唤1只「安杰莱琪」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将自身卡片洗回额外卡组
	if c:IsRelateToChain() and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_EXTRA) then
		local p=c:GetOwner()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足条件的「安杰莱琪」怪兽
		local g=Duel.SelectMatchingCard(p,s.spfilter,p,LOCATION_EXTRA,0,1,1,nil,e,p,p)
		if g:GetCount()>0 then
			-- 中断效果处理流程
			Duel.BreakEffect()
			-- 将选中的怪兽表侧表示特殊召唤
			Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)
		end
	end
end
