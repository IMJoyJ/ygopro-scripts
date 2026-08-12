--三幻魔の操世者
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。选自己1张手卡丢弃，从手卡把1只8星以外的「三幻魔」怪兽守备表示特殊召唤。
-- ②：丢弃1张手卡才能发动。除丢弃的卡外的1只8星以外的「三幻魔」怪兽从自己的手卡·墓地守备表示特殊召唤。
-- ③：把墓地的这张卡除外才能发动。从自己墓地把1只8星以外的「三幻魔」怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化函数：为这张卡注册三个起动效果——e1在手卡生效（公开此卡并丢弃手卡从手卡特召三幻魔）、e2在场上生效（丢弃手卡从手卡·墓地特召三幻魔）、e3在墓地生效（除外此卡从墓地特召三幻魔），三者分别用id、id+o、id+o*2设置同名卡1回合1次的次数限制
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。选自己1张手卡丢弃，从手卡把1只8星以外的「三幻魔」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：丢弃1张手卡才能发动。除丢弃的卡外的1只8星以外的「三幻魔」怪兽从自己的手卡·墓地守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。从自己墓地把1只8星以外的「三幻魔」怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	-- 设置③效果的代价：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg3)
	e3:SetOperation(s.spop3)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件（代价检查）：手卡的这张卡尚未公开（未给对方观看）时才能发动
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 手卡过滤条件：这张卡可以因效果被丢弃，且丢弃后手卡中仍存在其他可特殊召唤的三幻魔怪兽
function s.hfilter(c,e,tp)
	return c:IsDiscardable(REASON_EFFECT+REASON_DISCARD)
		-- 检查手卡中是否存在除这张卡以外满足特召条件的三幻魔怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
-- 特召对象过滤条件：「三幻魔」系列（0x1144）且8星以外的怪兽，并且能够以表侧守备表示特殊召唤
function s.spfilter(c,e,tp)
	if not c:IsSetCard(0x1144) or c:IsLevel(8) then return false end
	-- 检查该卡能否按三幻魔的特殊召唤类型以表侧守备表示特殊召唤
	return c:IsCanBeSpecialSummoned(e,0,tp,false,aux.PhantasmsSpSummonType(c),POS_FACEUP_DEFENSE)
end
-- 将目标怪兽以表侧守备表示特殊召唤；特殊召唤成功且属于需要完成召唤手续的三幻魔时，为其完成正规召唤手续
function s.spsummon(c,tp)
	-- 取得该三幻魔怪兽的特殊召唤类型标记（用于判断是否需要无视苏生限制并完成召唤手续）
	local flag=aux.PhantasmsSpSummonType(c)
	-- 将该卡以表侧守备表示特殊召唤，且特殊召唤成功并带有三幻魔召唤手续标记时
	if Duel.SpecialSummon(c,0,tp,tp,false,flag,POS_FACEUP_DEFENSE)>0 and flag then
		c:CompleteProcedure()
	end
end
-- ①效果的目标设定：确认自己主要怪兽区有可用空格，且手卡中存在满足条件的可丢弃卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己主要怪兽区有1格以上的可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡中存在既能被丢弃、丢弃后又能配合特召三幻魔的卡
		and Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：预计从自己手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置连锁操作信息：预计自己丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- ①效果处理：先让玩家丢弃1张手卡（优先选择丢弃后仍能特召的卡），丢弃成功且怪兽区有空位时从手卡选1只三幻魔怪兽守备表示特殊召唤；若未能丢弃则仍强制丢弃1张手卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local dres=0
	-- 若手卡中不存在既能丢弃、丢弃后又留有可特召三幻魔的卡
	if not Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then
		-- 让玩家不加过滤条件地任选1张手卡丢弃，并记录丢弃数量
		dres=Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	else
		-- 让玩家选择1张满足条件（可丢弃且丢弃后仍能特召三幻魔）的手卡丢弃，并记录丢弃数量
		dres=Duel.DiscardHand(tp,s.hfilter,1,1,REASON_EFFECT+REASON_DISCARD,nil,e,tp)
	end
	if dres>0 then
		-- 若自己主要怪兽区没有可用空格则中断效果处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向玩家发送提示消息：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己手卡选择1只满足条件的三幻魔怪兽作为特殊召唤对象
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			s.spsummon(tc,tp)
		end
	else
		-- 让玩家丢弃1张手卡（前面丢弃失败时仍执行的强制丢弃）
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
-- ②效果代价的手卡过滤条件：这张卡可以被丢弃，且手卡·墓地中存在除这张卡外可特殊召唤的三幻魔怪兽
function s.hfilter2(c,e,tp)
	return c:IsDiscardable()
		-- 检查自己的手卡·墓地是否存在除该丢弃卡以外满足特召条件的三幻魔怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp)
end
-- ②效果的代价处理：确认手卡有满足条件的卡后丢弃1张作为代价，并把被丢弃的卡设为本连锁的对象（效果处理时用于将其排除在特召范围外）
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：手卡中存在可丢弃且丢弃后仍能特召三幻魔怪兽的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.hfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 让玩家选择1张满足条件的手卡作为代价丢弃
	Duel.DiscardHand(tp,s.hfilter2,1,1,REASON_COST+REASON_DISCARD,nil,e,tp)
	-- 取得刚才实际被丢弃的卡片组
	local og=Duel.GetOperatedGroup()
	-- 把被丢弃的卡设置为当前连锁的对象，供效果处理时排除出特召选择范围
	Duel.SetTargetCard(og)
end
-- ②效果的目标设定：确认自己主要怪兽区有可用空格，且手卡·墓地中存在可特殊召唤的三幻魔怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己主要怪兽区有1格以上的可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己的手卡·墓地中存在满足特召条件的三幻魔怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：预计从自己的手卡·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果处理：确认怪兽区有空位后取得作为代价丢弃的卡（若已与连锁无关则忽略），再从手卡·墓地选1只除该卡外的三幻魔怪兽守备表示特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有可用空格则中断效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得当前连锁的对象卡（即作为代价丢弃的那张卡）
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then tc=nil end
	-- 向玩家发送提示消息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·墓地选择1只除丢弃的卡以外、不受王家长眠之谷影响的满足条件的三幻魔怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,tc,e,tp)
	local sc=g:GetFirst()
	if sc then
		s.spsummon(sc,tp)
	end
end
-- ③效果的目标设定：确认自己主要怪兽区有可用空格，且墓地中存在除这张卡本身外可特殊召唤的三幻魔怪兽
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己主要怪兽区有1格以上的可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地中存在除这张卡本身以外满足特召条件的三幻魔怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置连锁操作信息：预计从自己墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果处理：确认怪兽区有空位后，从自己墓地选1只满足条件的三幻魔怪兽以表侧守备表示特殊召唤
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有可用空格则中断效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示消息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只不受王家长眠之谷影响的满足条件的三幻魔怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		s.spsummon(tc,tp)
	end
end
