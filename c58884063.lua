--GP－Nブラスター
-- 效果：
-- 等级不同的「黄金荣耀」怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽破坏。自己基本分比对方少的场合，可以再把在那只怪兽破坏的区域的前面·后面·相邻的区域（怪兽区域·魔法与陷阱区域）存在的卡全部破坏。
-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-氮氧头领」特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 将「黄金荣耀-氮氧头领」加入该卡的关联卡片密码列表中
	aux.AddCodeList(c,59900655)
	-- 添加连接召唤手续：需要2只满足过滤条件且等级不同的怪兽作为连接素材
	aux.AddLinkProcedure(c,s.mfilter,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽破坏。自己基本分比对方少的场合，可以再把在那只怪兽破坏的区域的前面·后面·相邻的区域（怪兽区域·魔法与陷阱区域）存在的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-氮氧头领」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤条件：等级在0以上的「黄金荣耀」怪兽
function s.mfilter(c)
	return c:IsLevelAbove(0) and c:IsLinkSetCard(0x192)
end
-- 连接素材检测：要求作为素材的怪兽等级各不相同
function s.lcheck(g,lc)
	return g:GetClassCount(Card.GetLevel)==g:GetCount()
end
-- ①的效果的发动准备，包括取对象、检查合法性、设置破坏操作信息以及注册发动标记
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为破坏对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置破坏操作信息，表明此效果将破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 用于判定卡片是否处于指定格子的相邻区域（前、后、左、右）的辅助过滤函数
function s.desfilter(c,tp,seq)
	local sseq=c:GetSequence()
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) then
		return sseq==5 and seq==3 or sseq==6 and seq==1 or sseq==3 and seq==5 or sseq==1 and seq==6
	end
	if c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) then
		return sseq<5 and sseq==seq
	end
	if sseq<5 then
		return math.abs(sseq-seq)==1 or sseq==1 and seq==5 or sseq==3 and seq==6
	end
	if sseq>=5 then
		return sseq==5 and seq==1 or sseq==6 and seq==3
	end
end
-- ①的效果的处理，执行破坏对象怪兽，并在满足条件时可选破坏其相邻区域的所有卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 获取对象怪兽在场上的全局网格坐标（行与列）
		local row,column=aux.GetFieldIndex(tc)
		-- 破坏对象怪兽，若破坏失败或无法获取其坐标，则结束效果处理
		if Duel.Destroy(tc,REASON_EFFECT)==0 or row<0 or column<0 then
			return
		end
		-- 获取被破坏怪兽所在格子的前、后、相邻区域存在的卡片集合
		local cg=aux.GetAdjacentGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,row,column)
		-- 检查自身基本分是否比对方少，且相邻区域有卡存在，并询问玩家是否发动追加破坏效果
		if Duel.GetLP(tp)<Duel.GetLP(1-tp) and #cg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把范围内的卡全部破坏？"
			-- 中断当前效果处理，使后续的破坏处理与前面的破坏不视为同时进行
			Duel.BreakEffect()
			-- 破坏相邻区域内的所有卡
			Duel.Destroy(cg,REASON_EFFECT)
		end
	end
end
-- ②的效果的发动条件：这张卡的①的效果在当前回合已发动过
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- ②的效果的发动准备，设置回到额外卡组和特殊召唤的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回到额外卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
	-- 设置特殊召唤的操作信息，表明将从卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 特殊召唤的过滤条件：卡名为「黄金荣耀-氮氧头领」且可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCode(59900655) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的效果的处理，将自身送回额外卡组，并从卡组或墓地特殊召唤1只「黄金荣耀-氮氧头领」
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsExtraDeckMonster()
		-- 将自身送回额外卡组，并确认已成功回到额外卡组
		and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA)
		-- 检查自身场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向发动效果的玩家提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的卡组或墓地选择1只满足特殊召唤条件的「黄金荣耀-氮氧头领」
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
