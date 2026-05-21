--D・モバホン
-- 效果：
-- ①：这张卡得到表示形式的以下效果。
-- ●攻击表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面翻开。从那之中选1只4星以下的「变形斗士」怪兽无视召唤条件特殊召唤，剩余回到卡组。
-- ●守备表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面确认。
function c93542102.initial_effect(c)
	-- ●攻击表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面翻开。从那之中选1只4星以下的「变形斗士」怪兽无视召唤条件特殊召唤，剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93542102,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_DICE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c93542102.cona)
	e1:SetTarget(c93542102.tga)
	e1:SetOperation(c93542102.opa)
	c:RegisterEffect(e1)
	-- ●守备表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面确认。
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
-- 检查此卡是否未被无效且处于攻击表示，作为攻击表示效果的发动条件
function c93542102.cona(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
end
-- 检查此卡是否未被无效且处于守备表示，作为守备表示效果的发动条件
function c93542102.cond(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
end
-- 攻击表示效果的发动准备与可行性检测
function c93542102.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以进行特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp)
		-- 检查自己场上是否有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否未受到无法掷骰子的效果（如「出千」）的影响
		and not Duel.IsPlayerAffectedByEffect(tp,63060238)
		-- 检查自己卡组是否有卡
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 设置连锁信息，表明该效果包含掷1次骰子的操作
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 守备表示效果的发动准备与可行性检测
function c93542102.tgd(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否有卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 设置连锁信息，表明该效果包含掷1次骰子的操作
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 过滤出等级4以下、属于「变形斗士」系列且可以特殊召唤的怪兽
function c93542102.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 攻击表示效果的处理：掷骰子，翻开对应数量的卡，特殊召唤其中1只符合条件的「变形斗士」怪兽，其余卡洗回卡组
function c93542102.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 若卡组没有卡，则不处理效果
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 玩家掷1次骰子，并获取出现的数目
	local dc=Duel.TossDice(tp,1)
	-- 翻开自己卡组最上方对应骰子数目的卡片给双方确认
	Duel.ConfirmDecktop(tp,dc)
	-- 若此时自己场上没有空余的怪兽区域，则无法特殊召唤，直接结束处理（剩余卡片会洗回卡组）
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取卡组最上方对应骰子数目的卡片组
	local g=Duel.GetDecktopGroup(tp,dc)
	-- 给玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:FilterSelect(tp,c93542102.filter,1,1,nil,e,tp)
	-- 将选中的怪兽以表侧表示无视召唤条件特殊召唤到自己场上
	Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
	-- 将卡组（包含未被特殊召唤的剩余翻开卡片）洗牌
	Duel.ShuffleDeck(tp)
end
-- 守备表示效果的处理：掷骰子，确认对应数量的卡
function c93542102.opd(e,tp,eg,ep,ev,re,r,rp)
	-- 若卡组没有卡，则不处理效果
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 玩家掷1次骰子，并获取出现的数目
	local dc=Duel.TossDice(tp,1)
	-- 获取卡组最上方对应骰子数目的卡片组
	local g=Duel.GetDecktopGroup(tp,dc)
	-- 给发动效果的玩家确认这些卡片
	Duel.ConfirmCards(tp,g)
end
