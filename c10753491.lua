--森羅の神芽 スプラウト
-- 效果：
-- 这张卡特殊召唤成功时，可以从自己卡组上面把最多2张卡翻开。翻开的卡之中有植物族怪兽的场合，那些怪兽全部送去墓地。剩下的卡用喜欢的顺序回到卡组最下面。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以从卡组把1只植物族·1星怪兽特殊召唤。「森罗的神芽 幼芽」的这个效果1回合只能使用1次。
function c10753491.initial_effect(c)
	-- 这张卡特殊召唤成功时，可以从自己卡组上面把最多2张卡翻开。翻开的卡之中有植物族怪兽的场合，那些怪兽全部送去墓地。剩下的卡用喜欢的顺序回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10753491,0))  --"翻开卡组"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c10753491.target)
	e1:SetOperation(c10753491.operation)
	c:RegisterEffect(e1)
	-- 卡组的这张卡被卡的效果翻开送去墓地的场合，可以从卡组把1只植物族·1星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10753491,2))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,10753491)
	e2:SetCondition(c10753491.spcon)
	e2:SetTarget(c10753491.sptg)
	e2:SetOperation(c10753491.spop)
	c:RegisterEffect(e2)
end
-- 效果作用
function c10753491.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以将卡组顶端1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果作用
function c10753491.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以将卡组顶端1张卡送去墓地
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 获取玩家卡组中卡的数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	local ac=1
	if ct>1 then
		-- 提示玩家选择要翻开卡组的数量
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(10753491,1))  --"请选择要翻开卡组的数量"
		-- 让玩家宣言翻开卡组的数量（1或2）
		ac=Duel.AnnounceNumber(tp,1,2)
	end
	-- 确认玩家卡组最上方的指定数量张卡
	Duel.ConfirmDecktop(tp,ac)
	-- 获取玩家卡组最上方的指定数量张卡
	local g=Duel.GetDecktopGroup(tp,ac)
	local sg=g:Filter(Card.IsRace,nil,RACE_PLANT)
	if sg:GetCount()>0 then
		-- 禁止接下来的操作进行洗切卡组检测
		Duel.DisableShuffleCheck()
		-- 将满足条件的卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REVEAL)
	end
	ac=ac-sg:GetCount()
	if ac>0 then
		-- 让玩家对卡组最上方的指定数量张卡进行排序
		Duel.SortDecktop(tp,tp,ac)
		for i=1,ac do
			-- 获取玩家卡组最上方的1张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将指定卡移动到卡组最下方
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 效果作用
function c10753491.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 过滤函数，用于筛选满足条件的卡
function c10753491.filter(c,e,tp)
	return c:IsLevel(1) and c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用
function c10753491.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家卡组中是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(c10753491.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理中要特殊召唤的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用
function c10753491.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c10753491.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
