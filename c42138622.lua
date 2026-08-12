--時空の渦
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有不死族怪兽以及「活死人的呼声」存在，对方把怪兽或通常·速攻魔法卡的效果发动时才能发动。对方进行1次投掷硬币，那个里表让那个效果变成以下效果。
-- ●表：「对方必须把自身场上1只怪兽除外」
-- ●里：「自己必须把自己场上的怪兽全部除外」
local s,id,o=GetID()
-- 初始化效果：注册这张卡的发动效果，设置描述、硬币效果分类、连锁时点、次数限制及条件/目标/操作函数
function s.initial_effect(c)
	-- 记录这张卡上记载着卡名「活死人的呼声」（卡号97077563）
	aux.AddCodeList(c,97077563)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有不死族怪兽以及「活死人的呼声」存在，对方把怪兽或通常·速攻魔法卡的效果发动时才能发动。对方进行1次投掷硬币，那个里表让那个效果变成以下效果。
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
-- 过滤条件：返回是否为正面表示的不死族怪兽
function s.mfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 发动条件：对方发动效果，且自己场上存在正面表示的不死族怪兽和「活死人的呼声」，且该效果为怪兽或通常·速攻魔法卡的效果
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索自己场上所有正面表示的卡
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
	local check=g:IsExists(s.mfilter,1,nil) and g:IsExists(Card.IsCode,1,nil,97077563)
	return rp==1-tp and check and
		(re:IsActiveType(TYPE_MONSTER) or re:GetActiveType()==TYPE_SPELL or re:IsActiveType(TYPE_QUICKPLAY))
end
-- 发动目标检查：自己或对方的怪兽区域存在可以被规则除外的怪兽
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区域存在至少1只可以被规则除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,nil,tp,REASON_RULE)
		-- 或检查对方怪兽区域存在至少1只可以被规则除外的怪兽
		or Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil,1-tp,REASON_RULE)
	end
end
-- 效果处理：让对方投掷1次硬币，清空该连锁效果的对象，并按硬币里表将其效果替换为对应的除外效果
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 让对方（发动方）投掷1次硬币，正面为1反面为0
	local res=Duel.TossCoin(1-tp,1)
	local g=Group.CreateGroup()
	-- 将该连锁效果的对象替换为空组（清除原对象）
	Duel.ChangeTargetCard(ev,g)
	if res==1 then
		-- 硬币为正面时，把该连锁效果的处理替换为「对方必须把自身场上1只怪兽除外」
		Duel.ChangeChainOperation(ev,s.repop1)
	else
		-- 硬币为反面时，把该连锁效果的处理替换为「自己必须把自己场上的怪兽全部除外」
		Duel.ChangeChainOperation(ev,s.repop2)
	end
end
-- 替换处理（表）：对方从自己怪兽区域选1只怪兽并除外
function s.repop1(e,tp,eg,ep,ev,re,r,rp)
	local op=1-tp
	-- 向对方提示「请选择要除外的卡」
	Duel.Hint(HINT_SELECTMSG,op,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让对方从自己的怪兽区域选择1只可以被规则除外的怪兽
	local g=Duel.SelectMatchingCard(op,Card.IsAbleToRemove,op,LOCATION_MZONE,0,1,1,nil,op,REASON_RULE)
	-- 显示所选怪兽被选中的动画并记录
	Duel.HintSelection(g)
	-- 以规则原因将所选怪兽正面表示除外
	Duel.Remove(g,POS_FACEUP,REASON_RULE,op)
end
-- 替换处理（里）：自己把自己怪兽区域的怪兽全部除外
function s.repop2(e,tp,eg,ep,ev,re,r,rp)
	local op=tp
	-- 检索自己怪兽区域全部可以被规则除外的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,nil,op,REASON_RULE)
	-- 以规则原因将这些怪兽全部正面表示除外
	Duel.Remove(g,POS_FACEUP,REASON_RULE)
end
