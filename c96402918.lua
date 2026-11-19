--氷霊山の龍祖 ランセア
-- 效果：
-- 水属性调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合可以使用最多2次。
-- ①：对方把怪兽特殊召唤的场合才能发动（同一连锁上最多1次）。从自己的手卡·卡组·额外卡组·墓地把1只「冰结界」怪兽特殊召唤。那之后，可以把对方场上1只攻击表示怪兽变成守备表示。
-- ②：同调召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。从额外卡组把1只「冰结界」同调怪兽当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：设置苏生限制与同调召唤手续，并注册响应对方特召的①效果与离场特召同调怪兽的②效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 定义同调召唤素材要求：1只水属性调整＋1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),aux.NonTuner(nil),1)
	-- 这个卡名的①的效果1回合可以使用最多2次。①：对方把怪兽特殊召唤的场合才能发动（同一连锁上最多1次）。从自己的手卡·卡组·额外卡组·墓地把1只「冰结界」怪兽特殊召唤。那之后，可以把对方场上1只攻击表示怪兽变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：同调召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。从额外卡组把1只「冰结界」同调怪兽当作同调召唤作特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤同调怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件函数：判断本次特殊召唤事件中是否包含对方玩家特殊召唤的怪兽（排除自身）
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),1-tp)
end
-- 过滤条件函数：筛选可被特殊召唤的「冰结界」怪兽，并根据其来自额外卡组还是其他区域分别检查对应怪兽区空位
function s.spfilter1(c,e,tp)
	if not (c:IsSetCard(0x2f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 检查自己场上是否存在供额外卡组怪兽特殊召唤出场的可用空位
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 检查自己场上主要怪兽区是否存在可用的空位
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end
-- ①效果的发动检查与同一连锁限制函数：确认本连锁尚未发动过此效果且手卡·卡组·额外·墓地有可特召的「冰结界」怪兽
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0
		-- 检查自己的手卡·卡组·墓地·额外卡组中是否存在至少1只可特殊召唤的「冰结界」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向系统登记操作信息：将会从手卡·卡组·墓地·额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
-- 过滤条件函数：筛选当前为攻击表示且能够改变表示形式的怪兽
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- ①效果的处理函数：从手卡·卡组·额外卡组·墓地选1只「冰结界」怪兽特殊召唤，之后可任意将对方场上1只攻击表示怪兽变为表侧守备表示
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组·墓地·额外卡组选择1只不受王家长眠之谷限制的「冰结界」怪兽
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	-- 将选择的「冰结界」怪兽以表侧表示特殊召唤，并确认特召成功
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查对方怪兽区是否存在至少1只可改变表示形式的攻击表示怪兽
		and Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 询问玩家是否执行后续的将对方1只攻击表示怪兽变成守备表示的处理
		and Duel.SelectYesNo(tp,aux.Stringid(id,2))then  --"是否把1只对方怪兽变成守备表示？"
		-- 中断当前处理，将特殊召唤与改变对方怪兽表示形式分为不同时点处理
		Duel.BreakEffect()
		-- 向玩家发送选择提示：请选择要改变表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 让玩家从对方怪兽区选择1只可改变表示形式的攻击表示怪兽
		local tg=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 向双方玩家展示所选将要改变表示形式的对方怪兽
		Duel.HintSelection(tg)
		-- 将所选的对方攻击表示怪兽变成表侧守备表示
		Duel.ChangePosition(tg:GetFirst(),POS_FACEUP_DEFENSE)
	end
end
-- ②效果的发动条件函数：判断这张卡是否为同调召唤出场、离场前由自己控制且表侧表示，并因对方原因从场上离开
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp
end
-- 过滤条件函数：筛选额外卡组中可当作同调召唤特殊召唤且场地有空位的「冰结界」同调怪兽
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查自己场上是否有供该「冰结界」同调怪兽从额外卡组出场的可用空位
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的发动检查函数：确认玩家不受必须作为同调素材的限制，且额外卡组存在可同调召唤的「冰结界」同调怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否不受“必须作为同调素材”的限制影响
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查自己额外卡组是否存在至少1只符合条件的「冰结界」同调怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向系统登记操作信息：将会从自己额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理函数：校验素材限制后，从自己额外卡组选择1只「冰结界」同调怪兽当作同调召唤特殊召唤并完成正规召唤程序
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认玩家不受“必须作为同调素材”的限制，若受限则中止处理
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 向玩家发送选择提示：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己额外卡组选择1只可当作同调召唤特召的「冰结界」同调怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选择的「冰结界」同调怪兽以表侧表示当作同调召唤特殊召唤，若成功则完成召唤程序标记
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
