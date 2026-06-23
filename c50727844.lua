--シンクロ・フォースバック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以最多有自己场上的同调怪兽种类数量的场上的怪兽为对象才能发动。那些怪兽回到手卡。
local s,id,o=GetID()
-- 注册同调推回的发动效果，设置其为自由连锁、可取对象、发动次数限制为1次
function s.initial_effect(c)
	-- ①：以最多有自己场上的同调怪兽种类数量的场上的怪兽为对象才能发动。那些怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上表侧表示的同调怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 效果的取对象阶段，判断是否满足发动条件，即场上有同调怪兽且有可返回手牌的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	-- 统计自己场上同调怪兽数量（按卡号分类）
	local ct=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
	if chk==0 then return ct>0
		-- 检查是否有至少一张怪兽可以被选为效果对象
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择最多与场上同调怪兽数量相同的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,ct,nil)
	-- 设置效果处理时的操作信息，确定将要返回手牌的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 效果发动时执行的操作函数，将选中的怪兽送回手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 将连锁中涉及的目标怪兽送回手牌
	Duel.SendtoHand(Duel.GetTargetsRelateToChain(),nil,REASON_EFFECT)
end
