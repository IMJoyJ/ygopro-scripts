--時空の渦
-- 效果：
-- 自己场上有不死族怪兽以及「活死人的呼声」存在，对方把通常·速攻魔法卡的效果或者怪兽效果发动时（伤害步骤除外）：对方进行1次投掷硬币，那个发动的效果变成以下效果。
-- ●表：「对方必须把自身场上1只怪兽除外」
-- ●里：「自己必须把自身场上的怪兽全部除外」
-- 「时间漩涡」在1回合只能发动1张。
local s,id,o=GetID()
-- 初始化这张卡的效果：记录「活死人的呼声」的卡名，并注册一个连锁对方效果发动时的魔陷发动效果，设定其发动条件、目标检查与操作处理
function s.initial_effect(c)
	-- 记录这张卡上记载着「活死人的呼声」（卡号97077563）这一卡名
	aux.AddCodeList(c,97077563)
	-- 自己场上有不死族怪兽以及「活死人的呼声」存在，对方把通常·速攻魔法卡的效果或者怪兽效果发动时（伤害步骤除外）：对方进行1次投掷硬币，那个发动的效果变成以下效果。●表：「对方必须把自身场上1只怪兽除外」●里：「自己必须把自身场上的怪兽全部除外」「时间漩涡」在1回合只能发动1张。
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
-- 过滤函数：判断一张卡是否为表侧表示的不死族怪兽
function s.mfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 发动条件：自己场上存在表侧表示的不死族怪兽以及「活死人的呼声」，且是对方把怪兽效果、通常魔法或速攻魔法卡的效果发动
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上所有表侧表示的卡，用于后续条件判定
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
	local check=g:IsExists(s.mfilter,1,nil) and g:IsExists(Card.IsCode,1,nil,97077563)
	return rp==1-tp and check and
		(re:IsActiveType(TYPE_MONSTER) or re:GetActiveType()==TYPE_SPELL or re:IsActiveType(TYPE_QUICKPLAY))
end
-- 发动时的目标检查：确认自己或对方的主要怪兽区至少有一方存在可以除外的怪兽
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可以以规则原因除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,nil,tp,REASON_RULE)
		-- 或者检查对方场上主要怪兽区是否存在可以以规则原因除外的怪兽
		or Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil,1-tp,REASON_RULE)
	end
end
-- 发动处理：让对方进行1次投掷硬币，清除该连锁效果原本的对象，并根据硬币结果把那个发动的效果替换为对应的除外处理
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 让对方玩家进行1次投掷硬币，记录其结果（1为正面即表，0为反面即里）
	local res=Duel.TossCoin(1-tp,1)
	local g=Group.CreateGroup()
	-- 把连锁中对方那个发动效果的对象换成空组，即清除其原本的对象
	Duel.ChangeTargetCard(ev,g)
	if res==1 then
		-- 硬币结果为表时，把那个发动的效果变成「对方必须把自身场上1只怪兽除外」的处理
		Duel.ChangeChainOperation(ev,s.repop1)
	else
		-- 硬币结果为里时，把那个发动的效果变成「自己必须把自身场上的怪兽全部除外」的处理
		Duel.ChangeChainOperation(ev,s.repop2)
	end
end
-- 表效果的处理函数：让对方从自身主要怪兽区选择1只可以除外的怪兽，并将其除外
function s.repop1(e,tp,eg,ep,ev,re,r,rp)
	local op=1-tp
	-- 向对方玩家显示「请选择要除外的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,op,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让对方从自身主要怪兽区选择1只可以以规则原因除外的怪兽
	local g=Duel.SelectMatchingCard(op,Card.IsAbleToRemove,op,LOCATION_MZONE,0,1,1,nil,op,REASON_RULE)
	-- 为所选怪兽显示被选为对象的动画并记录这些卡被选为对象
	Duel.HintSelection(g)
	-- 把对方选择的怪兽以正面表示除外（视为规则原因的除外）
	Duel.Remove(g,POS_FACEUP,REASON_RULE,op)
end
-- 里效果的处理函数：把自己场上主要怪兽区所有可以除外的怪兽全部除外
function s.repop2(e,tp,eg,ep,ev,re,r,rp)
	local op=tp
	-- 取得自己主要怪兽区所有可以以规则原因除外的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,nil,op,REASON_RULE)
	-- 把那些怪兽全部以正面表示除外（视为规则原因的除外）
	Duel.Remove(g,POS_FACEUP,REASON_RULE)
end
