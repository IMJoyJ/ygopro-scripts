--黒き魔術師－ブラック・マジシャン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：场上有「光之黄金柜」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡只要在怪兽区域存在，卡名当作「黑魔术师」使用。
-- ③：这张卡被效果破坏的场合，若场上有5星以上的怪兽存在则能发动。这张卡特殊召唤。那之后，可以从卡组把有「黑魔术师」的卡名记述的1张魔法·陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片初始效果：先记录本卡卡名记载了「光之黄金柜」，并设置其在怪兽区域卡名视为「黑魔术师」；随后注册①效果（手卡存在光之黄金柜时发动特招）和③效果（被效果破坏时特招并可选盖放魔陷）。
function s.initial_effect(c)
	-- 记录这张卡的效果文本上记载着卡号79791878（光之黄金柜），使后续可通过aux.IsCodeListed等判断此记载关系。
	aux.AddCodeList(c,79791878)
	-- 为这张卡注册卡名变更效果：在怪兽区域存在时卡名当作「黑魔术师」（46986414）使用。
	aux.EnableChangeCode(c,46986414)
	-- ①：场上有「光之黄金柜」存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ③：这张卡被效果破坏的场合，若场上有5星以上的怪兽存在则能发动。这张卡特殊召唤。那之后，可以从卡组把有「黑魔术师」的卡名记述的1张魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 判定一张卡是否为表侧表示的「光之黄金柜」（79791878），用于①效果的发动条件。
function s.cfilter1(c)
	return c:IsCode(79791878) and c:IsFaceup()
end
-- ①效果的发动条件：检索场上是否存在表侧表示的「光之黄金柜」。
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1张表侧表示的「光之黄金柜」。
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- ①效果的发动目标合法性：自己怪兽区域有空位，且这张卡能够以效果进行特殊召唤。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有可用的空格用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次效果包含特殊召唤的操作信息，使相关卡（如星尘龙等）能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与发动效果关联，则将其从手卡表侧表示特殊召唤到自己场上。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以表侧攻击表示形式将这张卡特殊召唤到自己怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判定一张卡是否为表侧表示且等级在5星以上，用于③效果的发动条件。
function s.cfilter2(c)
	return c:IsLevelAbove(5) and c:IsFaceup()
end
-- ③效果的发动条件：这张卡是被效果破坏的场合（reason中包含效果破坏）。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
-- ③效果的发动目标合法性：自己怪兽区域有空位、场上有表侧5星以上怪兽、且这张卡可以被特殊召唤。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有可用的空格用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在至少1只表侧表示且等级5以上的怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次效果包含特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义盖放检索的过滤条件：从卡组中选出卡名记载着「黑魔术师」、类型为魔法·陷阱且可以盖放的卡。
function s.setfilter(c)
	-- 判定卡片是否满足：效果文本记载有「黑魔术师」（46986414），属于魔法·陷阱卡，且可以盖放到魔法陷阱区。
	return aux.IsCodeListed(c,46986414) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ③效果处理：若这张卡仍与效果关联则先特殊召唤；召唤成功且卡组有可盖放魔陷时，询问玩家是否盖放；选择后将那张魔陷盖放到自己场上。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 进入③效果的后段处理条件：该卡仍与效果关联且特殊召唤成功，卡组存在符合条件的魔陷，并且玩家选择同意盖放。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把魔陷盖放？"
		-- 弹出选择提示“请选择要盖放的卡”，将选择消息缓存供玩家从符合条件的卡中选择。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 中断当前效果链，使特殊召唤与后续盖放视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 从自己卡组选择1张满足s.setfilter条件的魔法·陷阱卡。
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选出的卡盖放到自己的魔法陷阱区。
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
