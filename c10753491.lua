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
	-- 此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以从卡组把1只植物族·1星怪兽特殊召唤。「森罗的神芽 幼芽」的这个效果1回合只能使用1次。
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
-- 第一个效果的发动条件判定函数：在效果发动时检查自己卡组顶端是否有至少1张卡可以送去墓地，从而满足“翻开最多2张卡”的操作前提。
function c10753491.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动判定时，检测自己能否把卡组最上方1张卡送去墓地，作为能否发动翻开卡组效果的前提条件。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 第一个效果的处理函数：先确认仍能从卡组送墓且卡组有卡；若卡组超过1张，则让玩家宣言翻开1或2张；公开卡组顶端对应张数，取出其中的植物族怪兽以“效果并翻开”的理由送去墓地；剩余卡经过玩家排序后依次放回卡组最下面。
function c10753491.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次检查自己能否从卡组送墓，若不能则直接终止效果处理，避免无效操作。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 统计自己卡组当前卡片数量，用于确定可翻开的张数上限（若卡组只有1张则只能翻开1张）。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	local ac=1
	if ct>1 then
		-- 显示选择提示消息，让玩家选择要翻开的卡组数量（1或2）。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(10753491,1))  --"请选择要翻开卡组的数量"
		-- 让玩家在1和2中宣言一个数字，作为实际翻开的卡组张数。
		ac=Duel.AnnounceNumber(tp,1,2)
	end
	-- 将玩家卡组最上方ac张卡公开给双方确认（翻开展示）。
	Duel.ConfirmDecktop(tp,ac)
	-- 获取刚才公开的卡组最上方ac张卡，组成卡组对象g供后续筛选。
	local g=Duel.GetDecktopGroup(tp,ac)
	local sg=g:Filter(Card.IsRace,nil,RACE_PLANT)
	if sg:GetCount()>0 then
		-- 关闭本次效果处理后的自动洗切卡组检测，避免因从卡组送墓或移动卡而触发不必要的卡组洗切。
		Duel.DisableShuffleCheck()
		-- 将翻开的卡中的植物族怪兽全部送去墓地，送墓原因标记为“效果”和“翻开（REASON_REVEAL）”。
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REVEAL)
	end
	ac=ac-sg:GetCount()
	if ac>0 then
		-- 让当前玩家对剩下的ac张卡进行排序，以决定它们放回卡组最下面的顺序（玩家先选的卡在前）。
		Duel.SortDecktop(tp,tp,ac)
		for i=1,ac do
			-- 每次取出当前卡组最上方的1张卡，作为待移动至卡组底部的卡。
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到卡组最下面，循环后使剩余卡按玩家指定的顺序依次排列在卡组底部。
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 第二个效果的发动条件判断：本卡之前的所在位置必须是卡组，并且被送去墓地的原因包含“翻开”（即被卡的效果从卡组翻开并送墓）时才能发动。
function c10753491.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 特殊召唤对象的筛选条件：等级为1、种族为植物族，并且能够被当前效果特殊召唤（满足召唤条件与苏生限制）。
function c10753491.filter(c,e,tp)
	return c:IsLevel(1) and c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 第二个效果的发动条件与处理信息设置：效果发动时检查自己场上是否有可用的怪兽区域，且卡组中存在至少1只符合条件的植物族·1星怪兽；满足后登记本次操作包含从卡组特殊召唤1只怪兽的信息。
function c10753491.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动判定时先检查自己场上的主要怪兽区域是否有空位，若无空位则不能发动特召效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在至少1只满足筛选条件的植物族·1星怪兽，若场上无空位或卡组无目标则不能发动。
		and Duel.IsExistingMatchingCard(c10753491.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记操作信息：本效果将从卡组特殊召唤1只怪兽（对象在效果处理时确定，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 第二个效果的实际处理：再次确认场上仍有可用怪兽区；提示玩家选择要特殊召唤的卡；从自己卡组选择1只符合条件的植物族·1星怪兽，并表侧表示特殊召唤到自己场上。
function c10753491.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若场上的主要怪兽区域没有空位，则中止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示，将选择消息提供给玩家。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组中筛选并让玩家选择1只满足植物族·1星且可特殊召唤条件的怪兽，作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c10753491.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上（正常检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
