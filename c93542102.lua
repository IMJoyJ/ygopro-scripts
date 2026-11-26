--D・モバホン
-- 效果：
-- ①：这张卡得到表示形式的以下效果。
-- ●攻击表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面翻开。从那之中选1只4星以下的「变形斗士」怪兽无视召唤条件特殊召唤，剩余回到卡组。
-- ●守备表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面确认。
function c93542102.initial_effect(c)
	-- ①：这张卡得到表示形式的以下效果。●攻击表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面翻开。从那之中选1只4星以下的「变形斗士」怪兽无视召唤条件特殊召唤，剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93542102,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_DICE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c93542102.cona)
	e1:SetTarget(c93542102.tga)
	e1:SetOperation(c93542102.opa)
	c:RegisterEffect(e1)
	-- ①：这张卡得到表示形式的以下效果。●守备表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面确认。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93542102,1))  --"确认卡组"
	e2:SetCategory(CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c93542102.cond)
	e2:SetTarget(c93542102.tgd)
	e2:SetOperation(c93542102.opd)
	c:RegisterEffect(e2)
end
-- 检查攻击表示效果的发动条件：此卡未被无效化且当前为攻击表示
function c93542102.cona(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
end
-- 检查守备表示效果的发动条件：此卡未被无效化且当前为守备表示
function c93542102.cond(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
end
-- 攻击表示效果发动前校验：确认己方能特殊召唤、怪兽区有空位、未受「元素英雄 烈焰侠」限制及卡组仍有卡，并登记掷骰子操作信息
function c93542102.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方玩家当前是否可以进行特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp)
		-- 检查己方怪兽区是否至少有1个可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方是否未处于「元素英雄 烈焰侠」限制只能特殊召唤融合怪兽的效果影响下
		and not Duel.IsPlayerAffectedByEffect(tp,63060238)
		-- 检查己方卡组剩余卡片数量是否大于0
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 登记需要投掷1次骰子的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 守备表示效果发动前确认己方卡组仍有卡并登记掷骰子操作信息
function c93542102.tgd(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组剩余卡片数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 登记需要投掷1次骰子的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 过滤4星以下、卡名含有「变形斗士」且可无视召唤条件特殊召唤的怪兽
function c93542102.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 攻击表示效果处理：掷1次骰子并翻开卡组上方对应张数的卡，从中选1只4星以下「变形斗士」怪兽无视召唤条件表侧特召，其余洗回卡组
function c93542102.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时确认己方卡组仍有卡，若为空则中止
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 让己方投掷1次骰子，取得结果点数dc
	local dc=Duel.TossDice(tp,1)
	-- 从己方卡组最上方翻开并向双方确认dc张卡
	Duel.ConfirmDecktop(tp,dc)
	-- 检查己方怪兽区是否仍有空位，无空位则中止
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取己方卡组最上方刚翻开的dc张卡组成卡片组
	local g=Duel.GetDecktopGroup(tp,dc)
	-- 向己方发送从翻开的卡中选择要特殊召唤的怪兽的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:FilterSelect(tp,c93542102.filter,1,1,nil,e,tp)
	-- 将选中的「变形斗士」怪兽无视召唤条件以表侧表示特殊召唤到己方场上
	Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
	-- 洗切己方卡组，将翻开的其余卡片回到卡组
	Duel.ShuffleDeck(tp)
end
-- 守备表示效果处理：掷1次骰子，获取卡组上方对应张数的卡并仅向己方确认（不改变卡组顺序）
function c93542102.opd(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时确认己方卡组仍有卡，若为空则中止
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 让己方投掷1次骰子，取得结果点数dc
	local dc=Duel.TossDice(tp,1)
	-- 获取己方卡组最上方的dc张卡
	local g=Duel.GetDecktopGroup(tp,dc)
	-- 向己方玩家展示并确认卡组最上方的这dc张卡
	Duel.ConfirmCards(tp,g)
end
