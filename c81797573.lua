--Angelechy Enlisted
-- 效果：
-- 调整+调整以外的怪兽1只
-- 可以以这张卡相邻纵列的1只对方怪兽为对象；那只怪兽除外，那之后，这张卡向相邻纵列的对方主要怪兽区域转移控制权。
-- 表侧表示的这张卡的控制权变更的场合：让这张卡回到额外卡组，那之后，这张卡的原本持有者从自身的额外卡组把1只「具象天使」怪兽特殊召唤。
-- 「应召之具象天使」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果，注册同调召唤手续、除外移权效果以及回额外特召效果
function s.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- 可以以这张卡相邻纵列的1只对方怪兽为对象；那只怪兽除外，那之后，这张卡向相邻纵列的对方主要怪兽区域转移控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外效果"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- 表侧表示的这张卡的控制权变更的场合：让这张卡回到额外卡组，那之后，这张卡的原本持有者从自身的额外卡组把1只「具象天使」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
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
-- 过滤条件：与该卡相邻纵列、可以除外且对方场上相邻位置有空位的怪兽
function s.rmfilter(c,ec,tp)
	-- 获取目标怪兽在怪兽区域的列序号
	local seq1=aux.MZoneSequence(c:GetSequence())
	-- 获取自身在怪兽区域的列序号
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
		-- 判断对方场上相邻的主要怪兽区域是否有可用于转移控制权的空位
		and Duel.GetMZoneCount(1-tp,c,1-tp,LOCATION_REASON_CONTROL,zone)>0
end
-- 效果目标选择及操作信息设置：以相邻纵列的对方怪兽为对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc,c,tp) end
	-- 检查对方场上是否存在满足条件的相邻怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE,1,nil,c,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上相邻纵列的1只怪兽作为对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil,c,tp)
	-- 设置操作信息：将选中的对象怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：除外对象怪兽，并将自身转移至相邻纵列的对方主要怪兽区域
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER)
		-- 将对象怪兽表侧表示除外并判断自身是否仍与连锁有联系
		and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and c:IsRelateToChain()
		and (tc:IsLocation(LOCATION_REMOVED) or tc:IsType(TYPE_TOKEN)) then
		-- 中断当前效果
		Duel.BreakEffect()
		-- 计算自身从对方视角来看的区域列序号
		local seq=4-aux.MZoneSequence(c:GetSequence())
		local zone=0
		if seq>0 then
			zone=bit.bor(zone,1<<(seq-1))
		end
		if seq<4 then
			zone=bit.bor(zone,1<<(seq+1))
		end
		-- 将自身的控制权转移至对方相邻的主要怪兽区域
		Duel.GetControl(c,1-tp,0,0,zone)
	end
end
-- 效果发动条件：表侧表示的自身控制权发生变更
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	return eg:IsContains(c) and c:IsFaceup()
end
-- 过滤条件：「具象天使」怪兽且能由原本持有者从额外卡组特殊召唤
function s.spfilter(c,e,tp,cp)
	return c:IsSetCard(0x1e2) and c:IsCanBeSpecialSummoned(e,0,cp,false,false,POS_FACEUP,cp)
		-- 判断额外卡组是否有可用于特殊召唤该怪兽的空位
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果操作信息设置：从额外卡组特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 设置操作信息：原本持有者从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,c:GetOwner(),LOCATION_EXTRA)
end
-- 效果处理：自身回到额外卡组，原本持有者从额外卡组特殊召唤1只「具象天使」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将自身返回额外卡组并判断是否成功
	if c:IsRelateToChain() and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_EXTRA) then
		local p=c:GetOwner()
		-- 提示原本持有者选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 原本持有者从额外卡组选择1只「具象天使」怪兽
		local g=Duel.SelectMatchingCard(p,s.spfilter,p,LOCATION_EXTRA,0,1,1,nil,e,p,p)
		if g:GetCount()>0 then
			-- 中断当前效果
			Duel.BreakEffect()
			-- 原本持有者将选中的怪兽表侧表示特殊召唤
			Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)
		end
	end
end
