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
-- 该效果只能在主要阶段发动，因此检查当前阶段是否为主要阶段1或主要阶段2（满足②效果的发动时点限制）。
function c47810543.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于后续与主要阶段1/2比较以判定发动时机。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 筛选可以作为特殊召唤对象的手卡怪兽：必须是「魔弹」系列怪兽，且可以被当前效果特殊召唤（满足特殊召唤条件、苏生限制等）。
function c47810543.filter(c,e,tp)
	return c:IsSetCard(0x108) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的合法检测：自己场上有空余的主要怪兽区域，且手卡存在1只可特殊召唤的「魔弹」怪兽；满足则通过检查并在效果处理时设置特殊召唤的操作信息。
function c47810543.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区，若无则无法发动（因为特殊召唤需要格子）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足筛选条件的「魔弹」怪兽（可用于特殊召唤）。
		and Duel.IsExistingMatchingCard(c47810543.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将为1只怪兽进行特殊召唤的操作信息，以供相关卡片/效果连锁判定（如星尘龙等会检索特殊召唤信息）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：先确认自己场上仍有空余主要怪兽区；然后由玩家从手卡选择1只「魔弹」怪兽特殊召唤；若特殊召唤成功，则计算对方场上与所召唤怪兽相同纵列的格子，若该空格未被使用，则用无效区域效果使其直到回合结束时不能使用。
function c47810543.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次检查自己场上是否有空余主要怪兽区，若没有则本次处理中止（防止处理时格子被占用）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给操作玩家弹出选择提示，告知需要从手卡选择要特殊召唤的「魔弹」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1张满足条件的「魔弹」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c47810543.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若成功选择了怪兽且将其表侧攻击表示特殊召唤到自己场上，则继续处理后续封锁对方纵列的效果。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local seq=4-g:GetFirst():GetSequence()
		-- 计算对方场上与召唤区相同纵列的主要怪兽区（位置序号一致）是否为空且可用；只有未使用的场合才需要封锁。
		if Duel.CheckLocation(1-tp,LOCATION_MZONE,seq) then
			-- 将对方场上该纵列的格子转换为全局区域掩码值，用于指定要被无效的具体怪兽区域。
			local val=aux.SequenceToGlobal(1-tp,LOCATION_MZONE,seq)
			-- 和这个效果让怪兽特殊召唤的区域相同纵列的对方的主要怪兽区域没有使用的场合，那个区域直到回合结束时不能使用。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE_FIELD)
			e1:SetValue(val)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将‘对方该纵列怪兽区域不能使用’的持续无效区域效果注册到当前场上，持续到回合结束。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
