--サイコ・トリガー
-- 效果：
-- 自己基本分比对方低的场合才能发动。把自己墓地存在的2只念动力族怪兽从游戏中除外，从自己卡组抽2张卡。
function c55673611.initial_effect(c)
	-- 自己基本分比对方低的场合才能发动。把自己墓地存在的2只念动力族怪兽从游戏中除外，从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c55673611.condition)
	e1:SetTarget(c55673611.target)
	e1:SetOperation(c55673611.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定
function c55673611.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己当前基本分是否低于对方
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 过滤自己墓地中可除外的念动力族怪兽
function c55673611.filter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemove()
end
-- 效果发动时的目标选择与操作信息设置
function c55673611.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c55673611.filter(chkc) end
	-- 判定墓地是否存在2只念动力族怪兽且玩家是否能抽卡
	if chk==0 then return Duel.IsExistingTarget(c55673611.filter,tp,LOCATION_GRAVE,0,2,nil) and Duel.IsPlayerCanDraw(tp,2) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地2只念动力族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c55673611.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置除外操作的连锁信息，涉及墓地的2张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,tp,LOCATION_GRAVE)
	-- 设置抽卡操作的连锁信息，涉及抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理的执行
function c55673611.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象卡片表侧表示除外，并确认是否成功除外了2张
	if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)==2 then
		-- 从自己卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
