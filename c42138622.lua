--Vortex of Time
-- 效果：
-- 自己场上有不死族怪兽以及「活死人的呼声」存在，对方把通常·速攻魔法卡的效果或者怪兽效果发动时（伤害步骤除外）：对方进行1次投掷硬币，那个发动的效果变成以下效果。
-- ●表：「对方必须把自身场上1只怪兽除外」
-- ●里：「自己必须把自身场上的怪兽全部除外」
-- 「时间漩涡」在1回合只能发动1张。
local s,id,o=GetID()
-- 初始化卡片效果主函数，注册记载活死人的呼声的卡片关系，以及在连锁中发动时改变对方效果处理的卡片发动效果。
function s.initial_effect(c)
	-- 将「活死人的呼声」（卡号97077563）加入本卡的关联卡片列表中。
	aux.AddCodeList(c,97077563)
	-- 自己场上有不死族怪兽以及「活死人的呼声」存在，对方把通常·速攻魔法卡的效果或者怪兽效果发动时（伤害步骤除外）：对方进行1次投掷硬币，那个发动的效果变成以下效果。●表：「对方必须把自身场上1只怪兽除外」 ●里：「自己必须把自身场上的怪兽全部除外」 「时间漩涡」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.chtg)
	e1:SetOperation(s.chop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：对方在伤害步骤以外发动怪兽效果、通常魔法或速攻魔法的效果，且自己场上同时存在表侧表示的不死族怪兽和表侧表示的「活死人的呼声」。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
	local check=g:IsExists(Card.IsRace,1,nil,RACE_ZOMBIE) and g:IsExists(Card.IsCode,1,nil,97077563)
	return rp==1-tp and check and
		(re:IsActiveType(TYPE_MONSTER) or re:GetActiveType()==TYPE_SPELL or re:IsActiveType(TYPE_QUICKPLAY))
end
-- 效果发动的Target函数：在效果发动时检查是否存在可以除外的怪兽，确保效果能够合法执行。
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时的合法性检查：检查自己场上是否存在至少1只可以通过规则除外的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,nil,tp,REASON_RULE)
		-- 或者检查对方场上是否存在至少1只可以通过规则除外的怪兽。
		or Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil,1-tp,REASON_RULE)
	end
end
-- 效果发动的Operation函数：让对方进行1次投掷硬币，清空原发动的连锁对象，并根据投掷硬币的正反面结果，将该连锁的效果分别替换为对应的规则除外效果。
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 让对方玩家投掷1次硬币，并获取投掷结果。
	local res=Duel.TossCoin(1-tp,1)
	local g=Group.CreateGroup()
	-- 将原连锁的效果对象更改为清空后的空怪兽组。
	Duel.ChangeTargetCard(ev,g)
	if res==1 then
		-- 将原发动的效果更改为：让对方（这里的对方是指发动效果的玩家的对手，即原效果发动玩家的对方）必须把自身场上1只怪兽除外。
		Duel.ChangeChainOperation(ev,s.repop1)
	else
		-- 将原发动的效果更改为：自己（指原效果发动玩家）必须把自身场上的怪兽全部除外。
		Duel.ChangeChainOperation(ev,s.repop2)
	end
end
-- 替换效果1的处理：让对方玩家（即该效果的承受方）选择自身场上1只怪兽，并根据规则将其除外。
function s.repop1(e,tp,eg,ep,ev,re,r,rp)
	local op=1-tp
	-- 提示需要进行选择的玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,op,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让被施加效果的玩家选择自身场上1只满足规则除外条件的怪兽。
	local g=Duel.SelectMatchingCard(op,Card.IsAbleToRemove,op,LOCATION_MZONE,0,1,1,nil,op,REASON_RULE)
	-- 显式显示所选卡片的选中状态。
	Duel.HintSelection(g)
	-- 迫使该玩家将其选择的怪兽因规则除外。
	Duel.Remove(g,POS_FACEUP,REASON_RULE,op)
end
-- 替换效果2的处理：获取被施加效果的玩家场上所有的怪兽，并强制将这些怪兽全部除外。
function s.repop2(e,tp,eg,ep,ev,re,r,rp)
	local op=tp
	-- 获取施加效果对象玩家场上所有可以进行规则除外的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,nil,op,REASON_RULE)
	-- 将获取到的怪兽全部以表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_RULE)
end
