--ミミグル・デーモン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。场上1只里侧表示怪兽变成表侧攻击表示或表侧守备表示。
-- ③：这张卡在主要阶段反转的场合发动。以下效果各适用。
-- ●对方抽1张。
-- ●选自己1张手卡送去墓地。
-- ●这张卡的控制权移给对方。
local s,id,o=GetID()
-- 注册卡片的三个效果，分别是反转效果、特殊召唤效果和改变表示形式效果
function s.initial_effect(c)
	-- ③：这张卡在主要阶段反转的场合发动。以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"反转效果"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	-- 检查当前是否处于主要阶段以满足反转效果的发动条件
	e1:SetCondition(aux.MimighoulFlipCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。场上1只里侧表示怪兽变成表侧攻击表示或表侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"改变表示形式"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 设置反转效果的处理目标，包括对方抽卡、自己送墓地和控制权转移
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将自己手牌送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：将自身控制权移给对方
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
	-- 设置操作信息：对方抽一张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 执行反转效果的具体处理流程，包括让对方抽卡、选择送墓地的卡和转移控制权
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让对方玩家抽取一张卡
	Duel.Draw(1-tp,1,REASON_EFFECT)
	-- 获取自己手牌区域的所有卡片组
	local tg1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if tg1:GetCount()>0 then
		-- 将自己的手牌进行洗切
		Duel.ShuffleHand(tp)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local tc1=tg1:Select(tp,1,1,nil):GetFirst()
		-- 中断当前效果处理，使后续操作视为不同时处理
		Duel.BreakEffect()
		-- 将选定的卡送去墓地
		Duel.SendtoGrave(tc1,REASON_EFFECT)
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 中断当前效果处理，使后续操作视为不同时处理
		Duel.BreakEffect()
		-- 让对方获得自身控制权
		Duel.GetControl(c,1-tp)
	end
end
-- 设置特殊召唤效果的目标条件，包括是否可以特殊召唤及场上是否有空位
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤的条件：卡牌可特殊召唤且对方场上有空位
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 设置操作信息：将自身特殊召唤到对方场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤效果的具体处理流程，包括特殊召唤自身并确认其卡片内容
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 如果特殊召唤成功，则向玩家展示该卡牌内容
		if Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)>0 then Duel.ConfirmCards(tp,c) end
	end
end
-- 定义用于筛选目标怪兽的过滤函数，要求是怪兽、里侧表示且为守备表示
function s.posfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFacedown() and c:IsDefensePos()
end
-- 设置改变表示形式效果的目标条件，检查自己场上是否存在符合条件的里侧表示怪兽
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足改变表示形式的效果发动条件：自己场上有里侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置操作信息：将目标怪兽改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- 执行改变表示形式效果的具体处理流程，包括选择目标怪兽并设定其表示形式
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 从自己场上选择符合条件的1只怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 显示所选怪兽被选为对象的动画效果
		Duel.HintSelection(g)
		-- 让玩家选择目标怪兽变为表侧攻击表示
		local pos=Duel.SelectPosition(tp,tc,POS_FACEUP)
		-- 将目标怪兽改变为指定表示形式
		Duel.ChangePosition(tc,pos)
	end
end
