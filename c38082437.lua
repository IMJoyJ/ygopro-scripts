--D・テレホン
-- 效果：
-- ①：这张卡得到表示形式的以下效果。
-- ●攻击表示：1回合1次，自己主要阶段才能发动。掷1次骰子。自己回复出现的数目×100基本分。那之后，可以从自己墓地选持有出现的数目以下的等级的1只「变形斗士」怪兽特殊召唤。
-- ●守备表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面翻开。可以从那之中选1张「变形斗士」卡送去墓地。剩余用喜欢的顺序回到卡组上面或下面。
function c38082437.initial_effect(c)
	-- 攻击表示时的起动效果，1回合1次，自己主要阶段才能发动。掷1次骰子。自己回复出现的数目×100基本分。那之后，可以从自己墓地选持有出现的数目以下的等级的1只「变形斗士」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38082437,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c38082437.cona)
	e1:SetTarget(c38082437.tga)
	e1:SetOperation(c38082437.opa)
	c:RegisterEffect(e1)
	-- 守备表示时的起动效果，1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面翻开。可以从那之中选1张「变形斗士」卡送去墓地。剩余用喜欢的顺序回到卡组上面或下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38082437,2))
	e2:SetCategory(CATEGORY_DICE+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c38082437.cond)
	e2:SetTarget(c38082437.tgd)
	e2:SetOperation(c38082437.opd)
	c:RegisterEffect(e2)
end
-- 效果发动条件：此卡在攻击表示
function c38082437.cona(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 效果处理准备：设置操作信息，准备骰子效果和回复效果
function c38082437.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：准备骰子效果
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	-- 设置操作信息：准备回复效果
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
-- 特殊召唤过滤器：筛选墓地中的「变形斗士」怪兽，等级不超过骰子点数
function c38082437.spfilter(c,e,tp,dc)
	return c:IsSetCard(0x26) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(dc)
end
-- 效果处理：投掷骰子，计算回复基本分，检索满足条件的墓地怪兽，若满足条件则询问是否特殊召唤
function c38082437.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 投掷一次骰子，结果为1-6的整数
	local dc=Duel.TossDice(tp,1)
	local rec=dc*100
	-- 检索满足条件的墓地怪兽组，包括等级限制和种族限制
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c38082437.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,dc)
	-- 判断是否满足回复基本分、墓地有怪兽、场上空位等条件
	if Duel.Recover(tp,rec,REASON_EFFECT)>0 and g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否从墓地特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(38082437,1)) then  --"是否从墓地特殊召唤？"
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动条件：此卡在守备表示
function c38082437.cond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDefensePos()
end
-- 效果处理准备：设置操作信息，准备骰子效果
function c38082437.tgd(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组是否为空
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 设置操作信息：准备骰子效果
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 翻开卡组顶部卡的过滤器：筛选「变形斗士」卡
function c38082437.tgfilter(c)
	return c:IsSetCard(0x26) and c:IsAbleToGrave()
end
-- 效果处理：投掷骰子，翻开卡组顶部卡，筛选「变形斗士」卡，若存在则询问是否送去墓地，然后排序剩余卡
function c38082437.opd(e,tp,eg,ep,ev,re,r,rp)
	-- 判断卡组是否为空
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 投掷一次骰子，结果为1-6的整数
	local dc=Duel.TossDice(tp,1)
	-- 确认卡组最上方的骰子点数张卡
	Duel.ConfirmDecktop(tp,dc)
	-- 获取卡组最上方的骰子点数张卡
	local dg=Duel.GetDecktopGroup(tp,dc)
	local ct=dg:GetCount()
	local g=dg:Filter(c38082437.tgfilter,nil)
	-- 判断是否有「变形斗士」卡，询问是否选择送去墓地
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(38082437,3)) then  --"是否选卡送去墓地？"
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 禁止洗切卡组检查
		Duel.DisableShuffleCheck()
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REVEAL)
		ct=ct-1
	end
	-- 选择将剩余卡放回卡组的顺序
	local op=Duel.SelectOption(tp,aux.Stringid(38082437,4),aux.Stringid(38082437,5))  --"回到卡组上面/回到卡组下面"
	-- 对卡组最上方的卡进行排序
	Duel.SortDecktop(tp,tp,ct)
	if op==0 then return end
	for i=1,ct do
		-- 获取卡组最上方的卡
		local tg=Duel.GetDecktopGroup(tp,1)
		-- 将卡移动到卡组最下方
		Duel.MoveSequence(tg:GetFirst(),SEQ_DECKBOTTOM)
	end
end
