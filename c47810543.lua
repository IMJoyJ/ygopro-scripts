--魔弾－ブラッディ・クラウン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「魔弹-血色之冠」在自己场上只能有1张表侧表示存在。
-- ②：自己·对方的主要阶段才能发动。从手卡把1只「魔弹」怪兽特殊召唤。和这个效果让怪兽特殊召唤的区域相同纵列的对方的主要怪兽区域没有使用的场合，那个区域直到回合结束时不能使用。
function c47810543.initial_effect(c)
	c:SetUniqueOnField(1,0,47810543)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段才能发动。从手卡把1只「魔弹」怪兽特殊召唤。和这个效果让怪兽特殊召唤的区域相同纵列的对方的主要怪兽区域没有使用的场合，那个区域直到回合结束时不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47810543,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,47810543)
	e2:SetCondition(c47810543.condition)
	e2:SetTarget(c47810543.target)
	e2:SetOperation(c47810543.operation)
	c:RegisterEffect(e2)
end
-- 判断当前是否为自己的主要阶段1或主要阶段2
function c47810543.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤手卡中满足条件的「魔弹」怪兽（可特殊召唤）
function c47810543.filter(c,e,tp)
	return c:IsSetCard(0x108) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：己方场上存在空位且手卡有符合条件的怪兽
function c47810543.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断己方场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在符合条件的「魔弹」怪兽
		and Duel.IsExistingMatchingCard(c47810543.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行效果处理：选择并特殊召唤1只「魔弹」怪兽
function c47810543.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若己方场上无空位则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只符合条件的「魔弹」怪兽
	local g=Duel.SelectMatchingCard(tp,c47810543.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若成功特殊召唤了怪兽，则继续执行后续处理
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local seq=4-g:GetFirst():GetSequence()
		-- 检查对方该纵列是否为空
		if Duel.CheckLocation(1-tp,LOCATION_MZONE,seq) then
			-- 将对方该纵列转换为全局位掩码值
			local val=aux.SequenceToGlobal(1-tp,LOCATION_MZONE,seq)
			-- ②：自己·对方的主要阶段才能发动。从手卡把1只「魔弹」怪兽特殊召唤。和这个效果让怪兽特殊召唤的区域相同纵列的对方的主要怪兽区域没有使用的场合，那个区域直到回合结束时不能使用。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE_FIELD)
			e1:SetValue(val)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将无效区域效果注册到场上，使对应区域在回合结束前无法使用
			Duel.RegisterEffect(e1,tp)
		end
	end
end
