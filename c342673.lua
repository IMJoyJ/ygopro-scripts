--黒き魔術師－ブラック・マジシャン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：场上有「光之黄金柜」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡只要在怪兽区域存在，卡名当作「黑魔术师」使用。
-- ③：这张卡被效果破坏的场合，若场上有5星以上的怪兽存在则能发动。这张卡特殊召唤。那之后，可以从卡组把有「黑魔术师」的卡名记述的1张魔法·陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个效果：①特殊召唤和③被破坏时特殊召唤并盖放魔陷
function s.initial_effect(c)
	-- 记录该卡效果文本上记载着「光之黄金柜」（卡号79791878）
	aux.AddCodeList(c,79791878)
	-- 设置该卡在特定条件下卡号视为「黑魔术师」（卡号46986414）
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
-- 过滤函数：检查场上是否存在「光之黄金柜」且正面表示的怪兽
function s.cfilter1(c)
	return c:IsCode(79791878) and c:IsFaceup()
end
-- 效果①的发动条件：场上存在「光之黄金柜」
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「光之黄金柜」且正面表示的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 效果①的发动时的处理：判断是否满足特殊召唤条件
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：将该卡加入特殊召唤的处理目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动效果：将该卡从手卡特殊召唤到场上
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：检查场上是否存在5星以上的正面表示怪兽
function s.cfilter2(c)
	return c:IsLevelAbove(5) and c:IsFaceup()
end
-- 效果③的发动条件：该卡因效果被破坏
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
-- 效果③的发动时的处理：判断是否满足特殊召唤并盖放魔陷的条件
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在5星以上的正面表示怪兽
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：将该卡加入特殊召唤的处理目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数：检查卡组中是否存在有「黑魔术师」卡名记述的魔法或陷阱卡
function s.setfilter(c)
	-- 判断该卡是否记载着「黑魔术师」（卡号46986414）且为魔法或陷阱卡且可盖放
	return aux.IsCodeListed(c,46986414) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果③的发动效果：将该卡特殊召唤并选择是否盖放一张魔陷
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否满足特殊召唤条件、场上是否有5星以上怪兽、卡组中是否存在魔陷可盖放且玩家选择盖放
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把魔陷盖放？"
		-- 提示玩家选择要盖放的魔陷卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 从卡组中选择一张符合条件的魔陷卡
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的魔陷卡盖放到场上
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
