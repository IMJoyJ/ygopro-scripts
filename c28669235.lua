--登竜華海瀧門
-- 效果：
-- ①：「登龙华海泷门」在自己场上只能有1张表侧表示存在。
-- ②：只要这张卡在魔法与陷阱区域存在，自己的「龙华」怪兽不会被战斗破坏。
-- ③：自己场上的「龙华」灵摆怪兽以及10星以上而原本种族是海龙族的怪兽得到以下效果。
-- ●对方回合1次，让自己场上1张表侧表示的「龙华」永续魔法卡回到卡组最下面，以场上1张卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 注册本卡全部效果：①「登龙华海泷门」在自己场上只能有1张表侧表示存在；②己方「龙华」怪兽不会被战斗破坏；③为符合条件的己方怪兽赋予‘对方回合1次回1张「龙华」永续魔法卡到卡组底并取场上1卡回手’的效果，并使其变为效果怪兽；另注册魔陷发动所需效果。
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，自己的「龙华」怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 为②效果设置目标筛选：仅卡名含「龙华」的己方怪兽受到‘不会被战斗破坏’保护。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1c0))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己场上的「龙华」灵摆怪兽以及10星以上而原本种族是海龙族的怪兽得到以下效果。●对方回合1次，让自己场上1张表侧表示的「龙华」永续魔法卡回到卡组最下面，以场上1张卡为对象才能发动。那张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"让场上的卡回到手卡（「登龙华海泷门」）"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.thcon)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	-- ③：自己场上的「龙华」灵摆怪兽以及10星以上而原本种族是海龙族的怪兽得到以下效果。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	-- ③：自己场上的「龙华」灵摆怪兽以及10星以上而原本种族是海龙族的怪兽得到以下效果。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_ADD_TYPE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.eftg)
	e5:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_REMOVE_TYPE)
	e6:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e6)
end
-- 定义获得效果的发动条件函数：仅允许在对方回合发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果控制者的对方玩家，满足时条件为真。
	return Duel.GetTurnPlayer()==1-tp
end
-- 定义代价筛选函数：从自己场上选出表侧表示的「龙华」永续魔法卡作为可返回卡组底端的代价，且场上还需存在另一张可回手牌的卡以保证有合法对象。
function s.costfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1c0) and c:IsAbleToDeckAsCost()
		and bit.band(c:GetType(),TYPE_SPELL+TYPE_CONTINUOUS)==TYPE_SPELL+TYPE_CONTINUOUS
		-- 确认场上存在除候选代价卡以外至少1张可回手牌的卡，保证发动时有合法对象可选。
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 定义代价处理函数：检查代价是否可支付，若可则提示对方发动，并让己方选择1张符合条件的「龙华」永续魔法卡送回持有者卡组最下面作为代价。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价判定阶段：检查自己场上是否存在至少1张满足条件的「龙华」永续魔法卡可作为回卡组底端的代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 向对方玩家发送‘对方选择了：’提示并显示该效果的描述，宣告本效果的发动。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 向己方玩家显示“请选择要返回卡组的卡”的提示信息，用于选择作为代价的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让己方玩家从自己场上选择1张满足s.costfilter的「龙华」永续魔法卡，作为将要送回卡组底端的代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 为选中的代价卡播放被选择动画，展示并记录所选择的卡。
	Duel.HintSelection(g)
	-- 将所选择的代价卡以‘代价’形式送回其持有者卡组最下面。
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 定义效果对象选择函数：确认合法对象存在后，提示玩家选择场上1张可回手牌的卡作为对象，并登记回手操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 效果发动判定阶段：确认双方场上是否存在至少1张可以被送回手牌的卡作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向己方玩家显示“请选择要返回手牌的卡”的提示信息，用于选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让己方玩家从双方场上选择1张可回手牌的卡，并将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将本次连锁处理标记为‘使1张卡回手’，供时点和连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果处理函数：获取效果对象，若对象仍与该效果关联，则将其送回持有者手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将对象卡送回其持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 定义自己场上可获得③效果的怪兽范围：卡名含「龙华」的灵摆怪兽，或10星以上且原本种族为海龙族的怪兽。
function s.eftg(e,c)
	return c:IsLevelAbove(10) and c:GetOriginalRace()==RACE_SEASERPENT
		or c:IsSetCard(0x1c0) and c:IsType(TYPE_PENDULUM)
end
