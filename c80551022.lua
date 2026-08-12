--ミミグル・スライム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。对方场上的怪兽数量比自己场上的怪兽多的场合，也能作为代替在自己场上表侧表示特殊召唤。
-- ②：这张卡在主要阶段反转的场合发动。以下效果各适用。
-- ●对方可以从自身卡组把1只「迷拟宝箱鬼」怪兽特殊召唤。
-- ●这张卡的控制权移给对方。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含反转效果和手卡特殊召唤效果
function s.initial_effect(c)
	-- ②：这张卡在主要阶段反转的场合发动。以下效果各适用。●对方可以从自身卡组把1只「迷拟宝箱鬼」怪兽特殊召唤。●这张卡的控制权移给对方。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"反转效果"
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	-- 设置发动条件为在主要阶段反转
	e1:SetCondition(aux.MimighoulFlipCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。对方场上的怪兽数量比自己场上的怪兽多的场合，也能作为代替在自己场上表侧表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 反转效果的发动准备与操作信息设置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息，表示该效果包含转移此卡控制权的操作
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
	-- 设置连锁信息，表示该效果包含对方从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_DECK)
end
-- 过滤条件：卡组中可以特殊召唤的「迷拟宝箱鬼」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1b7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 反转效果的处理逻辑：对方可选择是否从卡组特殊召唤「迷拟宝箱鬼」怪兽，随后此卡控制权转移给对方
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否有可用的怪兽区域
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查对方卡组是否存在可特殊召唤的「迷拟宝箱鬼」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_DECK,1,nil,e,1-tp)
		-- 询问对方玩家是否选择从卡组特殊召唤
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then  --"是否从卡组特殊召唤？"
		-- 提示对方玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 对方玩家从自身卡组选择1只满足条件的「迷拟宝箱鬼」怪兽
		local g=Duel.SelectMatchingCard(1-tp,s.spfilter,tp,0,LOCATION_DECK,1,1,nil,e,1-tp)
		if g:GetCount()>0 then
			-- 对方将选中的怪兽在自身场上表侧表示特殊召唤
			Duel.SpecialSummon(g,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 中断当前效果处理，使后续的控制权转移与特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 将这张卡的控制权转移给对方
		Duel.GetControl(c,1-tp)
	end
end
-- 过滤条件：检查是否满足在自己场上表侧表示特殊召唤的条件（对方场上怪兽比自己多且此卡可特殊召唤）
function s.sspfilter(c,tp,e)
	-- 检查对方场上的怪兽数量是否比自己场上的怪兽多
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 过滤条件：检查此卡是否可以往对方场上里侧守备表示特殊召唤
function s.ospfilter(c,tp,e)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
end
-- 手卡特殊召唤效果的发动准备与合法性检测
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足在自己场上表侧表示特殊召唤的条件且自己场上有空位
	if chk==0 then return s.sspfilter(c,tp,e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 或者是否满足在对方场上里侧守备表示特殊召唤的条件且对方场上有空位
		or s.ospfilter(c,tp,e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 设置连锁信息，表示该效果包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 手卡特殊召唤效果的处理逻辑：根据条件让玩家选择在自己场上表侧表示特殊召唤，或在对方场上里侧守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or (not s.sspfilter(c,tp,e) and not s.ospfilter(c,tp,e)) then return end
	-- 判断当前是否仍满足在自己场上表侧表示特殊召唤的条件
	local b1=s.sspfilter(c,tp,e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 判断当前是否仍满足在对方场上里侧守备表示特殊召唤的条件
	local b2=s.ospfilter(c,tp,e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	-- 让发动效果的玩家选择将此卡特殊召唤到哪一方的场上
	local toplayer=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,3),tp},  --"在自己场上特殊召唤"
		{b2,aux.Stringid(id,4),1-tp})  --"在对方场上特殊召唤"
	if toplayer==tp then
		-- 将此卡在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,toplayer,false,false,POS_FACEUP)
	elseif toplayer==1-tp then
		-- 将此卡在对方场上里侧守备表示特殊召唤
		Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让特殊召唤此卡的玩家确认该卡（因为是里侧特殊召唤到对方场上）
		Duel.ConfirmCards(tp,c)
	else
		-- 如果此时双方场上都没有可用的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then
			-- 根据规则将该卡送去墓地
			Duel.SendtoGrave(c,REASON_RULE)
		end
	end
end
